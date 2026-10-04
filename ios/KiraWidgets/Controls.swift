import AppIntents
import SwiftUI
import WidgetKit

/// Control Center and Lock Screen buttons. Both open the app on the matching screen.
struct LogByVoiceControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "com.example.kira.log-by-voice") {
            ControlWidgetButton(action: OpenURLIntent(DeepLink.listen)) {
                Label("Log by voice", systemImage: "mic.fill")
            }
        }
        .displayName("Log by voice")
        .description("Say what you spent.")
    }
}

struct ScanScreenshotControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "com.example.kira.scan-screenshot") {
            ControlWidgetButton(action: OpenURLIntent(DeepLink.scan)) {
                Label("Log a screenshot", systemImage: "text.viewfinder")
            }
        }
        .displayName("Log a screenshot")
        .description("Pick a banking or e-wallet screenshot to read.")
    }
}

private enum DeepLink {
    static let listen = URL(string: "kira://listen") ?? URL(fileURLWithPath: "/")
    static let scan = URL(string: "kira://scan") ?? URL(fileURLWithPath: "/")
}
