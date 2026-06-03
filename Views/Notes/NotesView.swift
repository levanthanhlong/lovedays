import SwiftUI

struct NotesView: View {
    @ObservedObject var viewModel: LoveViewModel
    @State private var showEditor = false
    @State private var selectedNote: Note? = nil

    var body: some View {
        ZStack {
            AppTheme.mainGradient.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                if viewModel.notes.isEmpty { emptyState } else { notesList }
            }
        }
        .sheet(isPresented: $showEditor, onDismiss: { selectedNote = nil }) {
            NoteEditorView(viewModel: viewModel, note: selectedNote)
        }
    }

    private var header: some View {
        TabHeader(emoji: "📝", title: "Ghi chú",
                  subtitle: viewModel.notes.isEmpty ? nil : "\(viewModel.notes.count) ghi chú") {
            Button {
                HapticManager.impact(.light)
                showEditor = true
            } label: {
                ZStack {
                    Circle()
                        .fill(AppTheme.deepRose)
                        .frame(width: 36, height: 36)
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack { Spacer(); VStack(spacing: 12) {
            Text("📝").font(.system(size: 52))
            Text("Chưa có ghi chú nào").font(AppTheme.headlineFont()).foregroundStyle(AppTheme.deepRose)
            Text("Nhấn ✏️ để tạo ghi chú đầu tiên").font(AppTheme.bodyFont()).foregroundStyle(.secondary)
        }; Spacer() }
    }

    private var notesList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.notes) { note in noteCard(note) }
            }
            .padding(.horizontal, 20).padding(.bottom, 40)
        }
    }

    private func noteCard(_ note: Note) -> some View {
        Button {
            selectedNote = note; showEditor = true
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text(note.title.isEmpty ? "Ghi chú" : note.title)
                        .font(AppTheme.headlineFont()).foregroundStyle(AppTheme.deepRose).lineLimit(1)
                    Spacer()
                    Text(relativeDate(note.updatedAt)).font(AppTheme.captionFont()).foregroundStyle(.secondary)
                }
                if !note.content.isEmpty {
                    Text(note.content).font(AppTheme.bodyFont()).foregroundStyle(.secondary)
                        .lineLimit(3).multilineTextAlignment(.leading)
                }
            }.cardStyle()
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) { viewModel.deleteNote(id: note.id) } label: {
                Label("Xóa ghi chú", systemImage: "trash")
            }
        }
    }

    private func relativeDate(_ date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "Hôm nay" }
        if cal.isDateInYesterday(date) { return "Hôm qua" }
        return DateCalculator.formattedDate(date)
    }
}
