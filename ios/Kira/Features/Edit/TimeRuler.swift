import SwiftUI
import KiraCore

/// A ruler from 6 AM to midnight with a knob for the time. The day's other entries are dots under the line,
/// so it's easy to see when two lunches sit close together. Snaps to five minutes.
struct TimeRuler: View {
    @Binding var date: Date
    var otherTimes: [Date] = []
    /// Called when the person moves the knob (so a guessed time counts as confirmed).
    var onChange: () -> Void = {}

    private let calendar = Calendar.current
    private let firstMinute = 6 * 60
    private let lastMinute = 24 * 60 - 5
    private let labelHours = [8, 12, 16, 20]
    private let knobWidth: CGFloat = 36
    private let trackY: CGFloat = 44

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let knobX = position(of: minutes(of: date), width: width)
            ZStack(alignment: .topLeading) {
                Capsule()
                    .fill(Theme.track)
                    .frame(width: width, height: 3)
                    .position(x: width / 2, y: trackY)

                ForEach(Array(otherTimes.enumerated()), id: \.offset) { _, time in
                    VStack(spacing: 0) {
                        Rectangle().fill(Theme.dot).frame(width: 1.5, height: 10)
                        Circle().fill(Theme.dot).frame(width: 10, height: 10)
                    }
                    .position(x: position(of: minutes(of: time), width: width), y: trackY + 11)
                }

                ForEach(labelHours, id: \.self) { hour in
                    Text(Self.hourLabel(hour))
                        .figtree(14, maximumScale: 1.3)
                        .foregroundStyle(Theme.secondary)
                        .fixedSize()
                        .position(x: position(of: hour * 60, width: width), y: trackY + 36)
                }

                Text(KiraFormat.time(date))
                    .figtree(15, weight: 650, maximumScale: 1.3)
                    .foregroundStyle(Theme.accentDeep)
                    .fixedSize()
                    .position(x: min(max(knobX, 34), width - 34), y: 10)

                Capsule()
                    .strokeBorder(Theme.accent, lineWidth: 3)
                    .background { Capsule().fill(Theme.card) }
                    .frame(width: knobWidth, height: 28)
                    .shadow(color: Theme.accent.opacity(0.35), radius: 6, y: 2)
                    .position(x: knobX, y: trackY)
            }
            .frame(width: width, height: proxy.size.height)
            .contentShape(.rect)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in setTime(atX: value.location.x, width: width) }
            )
        }
        .frame(height: 96)
        .sensoryFeedback(.selection, trigger: minutes(of: date))
        .accessibilityElement()
        .accessibilityLabel("Time")
        .accessibilityValue(KiraFormat.time(date))
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: shift(by: 15)
            case .decrement: shift(by: -15)
            @unknown default: break
            }
        }
    }

    private func minutes(of date: Date) -> Int {
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        return (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
    }

    private func position(of minutes: Int, width: CGFloat) -> CGFloat {
        let clamped = min(max(minutes, firstMinute), lastMinute)
        let fraction = CGFloat(clamped - firstMinute) / CGFloat(lastMinute - firstMinute)
        let inset = knobWidth / 2
        return inset + fraction * max(width - knobWidth, 1)
    }

    private func setTime(atX x: CGFloat, width: CGFloat) {
        let inset = knobWidth / 2
        let fraction = min(max((x - inset) / max(width - knobWidth, 1), 0), 1)
        let raw = Double(firstMinute) + Double(fraction) * Double(lastMinute - firstMinute)
        let snapped = Int((raw / 5).rounded()) * 5
        setMinutes(snapped)
    }

    private func shift(by delta: Int) {
        setMinutes(minutes(of: date) + delta)
    }

    private func setMinutes(_ value: Int) {
        let clamped = min(max(value, 0), 24 * 60 - 1)
        guard clamped != minutes(of: date),
              let newDate = calendar.date(bySettingHour: clamped / 60, minute: clamped % 60, second: 0, of: date) else { return }
        date = newDate
        onChange()
    }

    static func hourLabel(_ hour: Int) -> String {
        switch hour {
        case 0: return "12 AM"
        case 12: return "12 PM"
        case 13...23: return "\(hour - 12) PM"
        default: return "\(hour) AM"
        }
    }
}
