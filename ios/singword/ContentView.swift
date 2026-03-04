import SwiftUI

struct ContentView: View {
    @ObservedObject var appModel: AppModel

    var body: some View {
        RootTabView(appModel: appModel)
    }
}
