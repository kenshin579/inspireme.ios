import SwiftUI

@main
struct InspireMeApp: App {
    @State private var widgetURL: URL?

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    widgetURL = url
                }
                .fullScreenCover(item: $widgetURL) { url in
                    SafariView(url: url)
                        .ignoresSafeArea()
                }
        }
    }
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}
