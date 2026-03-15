import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "quote.opening")
                .font(.system(size: 60))
                .foregroundStyle(.purple)

            Text("InspireMe")
                .font(.largeTitle.bold())

            Text("홈 화면에 명언 위젯을 추가하고\n매일 영감을 받아보세요")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 16) {
                OnboardingFeatureRow(
                    icon: "widget.small",
                    title: "위젯 추가",
                    description: "홈 화면을 길게 누르고 InspireMe 위젯을 추가하세요"
                )
                OnboardingFeatureRow(
                    icon: "arrow.clockwise",
                    title: "자동 갱신",
                    description: "설정한 주기마다 새로운 명언이 표시됩니다"
                )
                OnboardingFeatureRow(
                    icon: "paintpalette",
                    title: "테마 선택",
                    description: "5가지 테마로 나만의 위젯을 꾸며보세요"
                )
            }
            .padding(.horizontal)

            Spacer()

            Button {
                hasSeenOnboarding = true
            } label: {
                Text("시작하기")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.purple)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }
}

private struct OnboardingFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.purple)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    OnboardingView(hasSeenOnboarding: .constant(false))
}
