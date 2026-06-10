import SwiftUI

struct GameHistoryView: View {
    let history: [Game2048Record]
    @Environment(\.dismiss) private var dismiss

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.18, green: 0.18, blue: 0.22).ignoresSafeArea()

                if history.isEmpty {
                    Text("Chưa có lịch sử")
                        .foregroundColor(.white.opacity(0.5))
                } else {
                    List(history) { record in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(dateFormatter.string(from: record.date))
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                                Text("Max: \(record.maxTile)")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("\(record.score)")
                                    .font(.title3.bold())
                                    .foregroundColor(.white)
                                Text(record.won ? "Thắng" : "Thua")
                                    .font(.caption.bold())
                                    .foregroundColor(record.won ? .green : .red)
                            }
                        }
                        .listRowBackground(Color.white.opacity(0.08))
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Lịch sử")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Đóng") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
}
