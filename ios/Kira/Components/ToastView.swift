import SwiftUI

/// The glass note at the bottom after saving or deleting, with Undo. Tap it to open the saved entry.
struct ToastView: View {
    let toast: Toast
    @Environment(AppModel.self) private var model

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: toast.style == .done ? "checkmark.circle.fill" : "info.circle.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(toast.style == .done ? Theme.green : Theme.accentDeep)
                .accessibilityHidden(true)
            Text(toast.message)
                .figtree(16, weight: 550)
                .foregroundStyle(Theme.ink)
                .lineLimit(2)
            Spacer(minLength: 8)
            if let undo = toast.undo {
                Button {
                    undo()
                    model.dismissToast()
                } label: {
                    Text("Undo")
                        .figtree(16, weight: 700)
                        .foregroundStyle(Theme.accentDeep)
                        .frame(minWidth: 44, minHeight: 44)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.leading, 18)
        .padding(.trailing, 10)
        .frame(minHeight: 56)
        .glassEffect(.regular, in: .capsule)
        .contentShape(.capsule)
        .onTapGesture {
            guard let id = toast.editID else { return }
            model.dismissToast()
            model.sheet = .edit(id)
        }
        .accessibilityElement(children: .contain)
    }
}
