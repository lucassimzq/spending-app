import SwiftUI

/// A round Liquid Glass button with an icon: ×, ✓, back, more. `prominent` tints it tangerine.
struct GlassIconButton: View {
    let systemImage: String
    let label: String
    var prominent = false
    var size: CGFloat = 48
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundStyle(Theme.ink)
                .frame(width: size, height: size)
                .contentShape(.circle)
        }
        .buttonStyle(.plain)
        .glassEffect(prominent ? .regular.tint(Theme.accent).interactive() : .regular.interactive(), in: .circle)
        .accessibilityLabel(label)
    }
}

/// A Liquid Glass capsule with an icon and a title: "Type it", "Screenshot".
struct GlassCapsuleButton: View {
    let title: String
    var systemImage: String?
    var height: CGFloat = 58
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            GlassCapsuleLabel(title: title, systemImage: systemImage, height: height)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .capsule)
    }
}

/// The inside of a glass capsule button, for controls that bring their own button (such as the photo picker).
struct GlassCapsuleLabel: View {
    let title: String
    var systemImage: String?
    var height: CGFloat = 58

    var body: some View {
        HStack(spacing: 10) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 19, weight: .medium))
                    .accessibilityHidden(true)
            }
            Text(title)
                .figtree(19, weight: 550)
        }
        .foregroundStyle(Theme.ink)
        .frame(maxWidth: .infinity, minHeight: height)
        .padding(.horizontal, 16)
        .contentShape(.capsule)
    }
}

/// The one filled button on a screen: tangerine with ink text.
struct AccentButton: View {
    let title: String
    var systemImage: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 18, weight: .semibold))
                        .accessibilityHidden(true)
                }
                Text(title)
                    .figtree(19, weight: 650)
            }
            .foregroundStyle(Theme.ink)
            .frame(maxWidth: .infinity, minHeight: 56)
            .padding(.horizontal, 18)
            .background(Theme.accentFill, in: .capsule)
            .shadow(color: Theme.accent.opacity(0.35), radius: 12, y: 5)
            .contentShape(.capsule)
        }
        .buttonStyle(PressableStyle())
    }
}

/// The top of a sheet: × on the left, the title in the middle, and ✓ on the right when there is something to save.
struct SheetHeader: View {
    let title: String
    var closeLabel = "Close"
    let onClose: () -> Void
    var confirmLabel = "Save"
    var canConfirm = true
    var onConfirm: (() -> Void)?

    var body: some View {
        ZStack {
            Text(title)
                .fraunces(26, weight: 640, wonky: true, relativeTo: .title2, maximumScale: 1.2)
                .foregroundStyle(Theme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 64)
                .accessibilityAddTraits(.isHeader)
            HStack {
                GlassIconButton(systemImage: "xmark", label: closeLabel, action: onClose)
                Spacer()
                if let onConfirm {
                    GlassIconButton(systemImage: "checkmark", label: confirmLabel, prominent: true, action: onConfirm)
                        .disabled(!canConfirm)
                        .opacity(canConfirm ? 1 : 0.45)
                }
            }
        }
        .padding(.horizontal, Theme.gutter)
        .padding(.top, 18)
        .padding(.bottom, 10)
    }
}
