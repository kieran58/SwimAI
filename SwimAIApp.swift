import SwiftUI

@main
struct SwimAIApp: App {
    @StateObject private var store = SwimStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
