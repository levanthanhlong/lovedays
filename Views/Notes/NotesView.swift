import SwiftUI

struct NotesView: View {
    @ObservedObject var viewModel: LoveViewModel
    @State private var showEditor = false
    @State private var selectedNote: Note? = nil
    @State private var editMode = false
    @State private var selectedIDs: Set<UUID> = []

    var body: some View {
        ZStack {
            AppTheme.mainGradient.ignoresSafeArea()
            VStack(spacing: 0) {
                TabHeader(emoji: "📝", title: "Ghi chú",
                          subtitle: viewModel.notes.isEmpty ? nil : "\(viewModel.notes.count) ghi chú") {
                    HStack(spacing: 10) {
                        if editMode {
                            Button {
                                guard !selectedIDs.isEmpty else { return }
                                selectedIDs.forEach { viewModel.deleteNote(id: $0) }
                                selectedIDs = []
                                editMode = false
                                HapticManager.notification(.success)
                            } label: {
                                Label("Xóa (\(selectedIDs.count))", systemImage: "trash")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10).padding(.vertical, 6)
                                    .background(Capsule().fill(Color.red.opacity(selectedIDs.isEmpty ? 0.4 : 0.85)))
                            }
                            .disabled(selectedIDs.isEmpty)

                            Button("Xong") {
                                editMode = false; selectedIDs = []
                            }
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                        } else {
                            if !viewModel.notes.isEmpty {
                                Button {
                                    editMode = true
                                } label: {
                                    Image(systemName: "checkmark.circle")
                                        .font(.system(size: 22, weight: .medium))
                                        .foregroundStyle(.white)
                                }
                            }
                            Button {
                                HapticManager.impact(.light)
                                selectedNote = nil; showEditor = true
                            } label: {
                                ZStack {
                                    Circle().fill(.white.opacity(0.25)).frame(width: 34, height: 34)
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20).padding(.top, 8)

                if viewModel.notes.isEmpty {
                    emptyState
                } else {
                    notesList
                }
            }
        }
        .sheet(isPresented: $showEditor, onDismiss: { selectedNote = nil }) {
            NoteEditorView(viewModel: viewModel, note: selectedNote)
        }
    }

    private var emptyState: some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                Text("📝").font(.system(size: 52))
                Text("Chưa có ghi chú nào")
                    .font(AppTheme.headlineFont()).foregroundStyle(AppTheme.deepRose)
                Text("Nhấn + để tạo ghi chú đầu tiên")
                    .font(AppTheme.bodyFont()).foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private var notesList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.notes) { note in
                    noteCard(note)
                }
            }
            .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 40)
        }
    }

    private func noteCard(_ note: Note) -> some View {
        HStack(spacing: 0) {
            // Checkbox in edit mode
            if editMode {
                Button {
                    if selectedIDs.contains(note.id) { selectedIDs.remove(note.id) }
                    else { selectedIDs.insert(note.id) }
                    HapticManager.selection()
                } label: {
                    Image(systemName: selectedIDs.contains(note.id) ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundStyle(selectedIDs.contains(note.id) ? note.color.accent : .secondary)
                        .padding(.trailing, 12)
                }
            }

            Button {
                guard !editMode else { return }
                selectedNote = note; showEditor = true
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        // Color dot
                        Circle().fill(note.color.dot).frame(width: 10, height: 10).padding(.top, 4)
                        Text(note.title.isEmpty ? "Ghi chú" : note.title)
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(note.color.accent).lineLimit(1)
                        Spacer()
                        Text(relativeDate(note.updatedAt))
                            .font(.system(size: 11, design: .rounded)).foregroundStyle(.secondary)
                    }
                    if !note.content.isEmpty {
                        Text(note.content)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundStyle(.secondary).lineLimit(3).multilineTextAlignment(.leading)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(note.color.background)
                        .shadow(color: note.color.accent.opacity(0.12), radius: 8, y: 3)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(note.color.dot.opacity(0.6), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .contextMenu {
                Button(role: .destructive) {
                    viewModel.deleteNote(id: note.id)
                } label: { Label("Xóa", systemImage: "trash") }
            }
        }
        .animation(.spring(response: 0.3), value: editMode)
    }

    private func relativeDate(_ date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "Hôm nay" }
        if cal.isDateInYesterday(date) { return "Hôm qua" }
        return DateCalculator.formattedDate(date)
    }
}
