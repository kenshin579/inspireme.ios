import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            WidgetPreviewView()
                .tabItem {
                    Label("미리보기", systemImage: "eye")
                }

            SettingsView()
                .tabItem {
                    Label("설정", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    MainTabView()
}
