import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding", store: UserDefaults(suiteName: AppGroupManager.suiteName))
    private var hasSeenOnboarding = false

    var body: some View {
        if hasSeenOnboarding {
            MainTabView()
        } else {
            OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
        }
    }
}

#Preview {
    ContentView()
}
