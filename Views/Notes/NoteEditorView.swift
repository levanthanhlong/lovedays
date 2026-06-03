import SwiftUI

struct NoteEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: LoveViewModel
    var note: Note?

    @State private var title = ""
    @State private var content = ""
    @State private var selectedColor: NoteColor = .cream
    @FocusState private var contentFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                selectedColor.background.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    // Color picker
                    colorPicker
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 8)

                    Divider().opacity(0.3)

                    // Title
                    TextField("Tiêu đề", text: $title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(selectedColor.accent)
                        .padding(.horizontal, 20)
                        .padding(.top, 14)
                        .padding(.bottom, 8)

                    Divider().opacity(0.3)

                    // Formatting toolbar
                    formattingToolbar
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)

                    Divider().opacity(0.3)

                    // Content editor
                    TextEditor(text: $content)
                        .font(.system(size: 16, design: .rounded))
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
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
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(isEmpty ? .secondary : selectedColor.accent)
                        .disabled(isEmpty)
                }
            }
        }
        .onAppear {
            if let note {
                title = note.title
                content = note.content
                selectedColor = note.color
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { contentFocused = true }
            }
        }
    }

    // MARK: - Color Picker
    private var colorPicker: some View {
        HStack(spacing: 10) {
            Text("Màu:").font(.system(size: 13, design: .rounded)).foregroundStyle(.secondary)
            ForEach(NoteColor.allCases, id: \.self) { color in
                Button {
                    HapticManager.selection()
                    withAnimation(.spring(response: 0.3)) { selectedColor = color }
                } label: {
                    ZStack {
                        Circle().fill(color.dot).frame(width: 28, height: 28)
                        if selectedColor == color {
                            Circle().stroke(color.accent, lineWidth: 2).frame(width: 28, height: 28)
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(color.accent)
                        }
                    }
                }
            }
            Spacer()
        }
    }

    // MARK: - Formatting Toolbar
    private var formattingToolbar: some View {
        HStack(spacing: 4) {
            formatButton(icon: "list.bullet", label: "•") {
                insertFormatting("• ")
            }
            formatButton(icon: "list.number", label: "1.") {
                insertNumberedItem()
            }
            Divider().frame(height: 20).padding(.horizontal, 4)
            formatButton(icon: "bold", label: "B") {
                insertFormatting("**", suffix: "**")
            }
            Spacer()
        }
    }

    private func formatButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 14))
                Text(label).font(.system(size: 13, weight: .medium, design: .rounded))
            }
            .foregroundStyle(selectedColor.accent)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedColor.accent.opacity(0.1))
            )
        }
    }

    // MARK: - Helpers
    private var isEmpty: Bool {
        title.trimmingCharacters(in: .whitespaces).isEmpty &&
        content.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func insertFormatting(_ prefix: String, suffix: String = "") {
        let newLine = content.isEmpty || content.hasSuffix("\n") ? "" : "\n"
        content += "\(newLine)\(prefix)\(suffix)"
        contentFocused = true
    }

    private func insertNumberedItem() {
        let lines = content.components(separatedBy: "\n")
        let count = lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return trimmed.range(of: #"^\d+\."#, options: .regularExpression) != nil
        }.count
        insertFormatting("\(count + 1). ")
    }

    private func save() {
        let t = title.trimmingCharacters(in: .whitespaces)
        let c = content.trimmingCharacters(in: .whitespaces)
        if var existing = note {
            existing.title = t; existing.content = c
            existing.color = selectedColor; existing.updatedAt = Date()
            viewModel.updateNote(existing)
        } else {
            viewModel.addNote(Note(title: t, content: c, color: selectedColor))
        }
    }
}
