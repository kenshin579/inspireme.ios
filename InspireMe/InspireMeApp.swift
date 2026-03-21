import SwiftUI

@main
struct InspireMeApp: App {
    @Environment(\.openURL) private var openURL
    @State private var widgetURL: URL?

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    if ProcessInfo.processInfo.isiOSAppOnMac {
                        openURL(url)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                        }
                    } else {
                        widgetURL = url
                    }
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
