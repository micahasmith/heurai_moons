import SwiftUI

@main
struct HeuraiMoonsApp: App {
    @StateObject private var store = ObservatoryStore()
    @AppStorage(InterfaceScale.storageKey) private var uiScale = InterfaceScale.default

    var body: some Scene {
        WindowGroup {
            AppShellView()
                .frame(minWidth: 1040, minHeight: 760)
                .environmentObject(store)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandMenu("View") {
                Button("Zoom In") {
                    uiScale = InterfaceScale.increased(from: uiScale)
                }
                .keyboardShortcut("=", modifiers: .command)

                Button("Zoom Out") {
                    uiScale = InterfaceScale.decreased(from: uiScale)
                }
                .keyboardShortcut("-", modifiers: .command)

                Button("Actual Size") {
                    uiScale = InterfaceScale.default
                }
                .keyboardShortcut("0", modifiers: .command)
            }
        }
    }
}
