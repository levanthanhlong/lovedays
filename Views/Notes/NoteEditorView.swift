import SwiftUI

struct NoteEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: LoveViewModel
    var note: Note?

    @State private var title = ""
    @State private var content = ""
    @FocusState private var contentFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.mainGradient.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 0) {
                    TextField("Tiêu đề", text: $title)
                        .font(AppTheme.headlineFont())
                        .foregroundStyle(AppTheme.deepRose)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 12)
                    Divider()
                    TextEditor(text: $content)
                        .font(AppTheme.bodyFont())
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, 16)
                        .focused($contentFocused)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") { dismiss() }.foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") { save(); dismiss() }
                        .font(AppTheme.bodyFont())
                        .foregroundStyle(isEmpty ? .secondary : AppTheme.deepRose)
                        .disabled(isEmpty)
                }
            }
        }
        .onAppear {
            if let note { title = note.title; content = note.content }
            else { DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { contentFocused = true } }
        }
    }

    private var isEmpty: Bool { title.trimmingCharacters(in: .whitespaces).isEmpty && content.trimmingCharacters(in: .whitespaces).isEmpty }

    private func save() {
        let t = title.trimmingCharacters(in: .whitespaces)
        let c = content.trimmingCharacters(in: .whitespaces)
        if var existing = note {
            existing.title = t; existing.content = c; existing.updatedAt = Date()
            viewModel.updateNote(existing)
        } else {
            viewModel.addNote(Note(title: t, content: c))
        }
    }
}
