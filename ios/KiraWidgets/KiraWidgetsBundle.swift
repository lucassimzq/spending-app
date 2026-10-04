import SwiftUI
import WidgetKit

@main
struct KiraWidgetsBundle: WidgetBundle {
    var body: some Widget {
        TodayWidget()
        MonthWidget()
        LeftPerDayWidget()
        LogByVoiceControl()
        ScanScreenshotControl()
    }
}
