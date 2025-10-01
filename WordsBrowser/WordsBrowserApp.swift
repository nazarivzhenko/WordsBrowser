import SwiftUI

@main
struct WordsBrowserApp: App {
    @StateObject var storeProvider = StoreProvider.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(storeProvider)
        }
    }
}
