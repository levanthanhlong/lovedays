import WidgetKit
import SwiftUI

private let udStartDateKey = "ld_start_date"
private let appGroup      = "group.com.app.testcmc"

struct LoveDaysEntry: TimelineEntry {
    let date: Date
    let totalDays: Int
    let startDateFormatted: String
    let photoData: Data?
}

struct LoveDaysProvider: TimelineProvider {
    func placeholder(in context: Context) -> LoveDaysEntry {
        LoveDaysEntry(date: Date(), totalDays: 365, startDateFormatted: "01/01/2024", photoData: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (LoveDaysEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LoveDaysEntry>) -> Void) {
        let entry = makeEntry()
        let midnight = Calendar.current.nextDate(after: Date(), matching: DateComponents(hour: 0), matchingPolicy: .nextTime) ?? Date().addingTimeInterval(86400)
        completion(Timeline(entries: [entry], policy: .after(midnight)))
    }

    private func makeEntry() -> LoveDaysEntry {
        let defaults  = UserDefaults(suiteName: appGroup) ?? .standard
        let startDate = (defaults.object(forKey: udStartDateKey) as? Date) ?? Date()
        let totalDays = max(0, Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0)
        let fmt       = DateFormatter(); fmt.dateFormat = "dd/MM/yyyy"

        var photoData: Data? = nil
        if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup)?
            .appendingPathComponent("couple_photo.jpg") {
            photoData = try? Data(contentsOf: url)
        }

        return LoveDaysEntry(date: Date(), totalDays: totalDays,
                             startDateFormatted: fmt.string(from: startDate), photoData: photoData)
    }
}

struct LoveDaysWidgetEntryView: View {
    var entry: LoveDaysEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:  smallView
        case .systemMedium: mediumView
        default:            smallView
        }
    }

    // MARK: - Small
    private var smallView: some View {
        ZStack {
            background
            VStack(spacing: 4) {
                Text("💕").font(.system(size: 28))
                Text("\(entry.totalDays)")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                Text("ngày yêu")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
    }

    // MARK: - Medium
    private var mediumView: some View {
        ZStack {
            background
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("💕").font(.system(size: 32))
                    Text("LoveDays")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

                Divider().background(.white.opacity(0.5))

                VStack(alignment: .leading, spacing: 6) {
                    Text("\(entry.totalDays)")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                    Text("ngày yêu nhau ❤️")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                    Text("Từ \(entry.startDateFormatted)")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(.white.opacity(0.75))
                }
            }
            .padding()
        }
    }

    // MARK: - Background
    @ViewBuilder
    private var background: some View {
        if let data = entry.photoData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .overlay(Color.black.opacity(0.35))
        } else {
            LinearGradient(colors: [Color(red:0.84,green:0.20,blue:0.42),
                                    Color(red:0.97,green:0.55,blue:0.72)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

private struct WidgetBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            content.containerBackground(for: .widget) { Color(red:1,green:0.97,blue:0.95) }
        } else {
            content.background(Color(red:1,green:0.97,blue:0.95))
        }
    }
}

@main
struct LoveDaysWidget: Widget {
    let kind = "LoveDaysWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LoveDaysProvider()) { entry in
            LoveDaysWidgetEntryView(entry: entry)
                .modifier(WidgetBackground())
        }
        .configurationDisplayName("LoveDays")
        .description("Hiển thị số ngày yêu nhau trên màn hình chính")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
