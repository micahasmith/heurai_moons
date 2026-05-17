import SwiftUI

@main
struct HeuraiMoonsApp: App {
    var body: some Scene {
        WindowGroup {
            AppShellView()
                .frame(minWidth: 1040, minHeight: 760)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
