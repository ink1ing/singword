import SwiftUI

@main
struct singwordApp: App {
    @StateObject private var appModel = AppModel()

    init() {
        SingWordFontRegistrar.registerAll()
        SingWordAppearance.applyGlobalTypography()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(appModel: appModel)
                .environment(\.font, SingWordTypography.bodyMedium)
                .preferredColorScheme(appModel.themeMode.colorScheme)
        }
    }
}
