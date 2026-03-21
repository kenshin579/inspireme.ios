import SwiftUI
import WebKit

struct WebView: View {
    var body: some View {
        NavigationStack {
            InspireMeWebView(url: URL(string: "\(InspireMeAPI.baseURL)")!)
                .navigationTitle("InspireMe")
                .navigationBarTitleDisplayMode(.inline)
                .ignoresSafeArea(edges: .bottom)
        }
    }
}

struct InspireMeWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

#Preview {
    WebView()
}
