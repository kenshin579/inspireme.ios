import SwiftUI

struct ToastView: View {
    let message: String
    @Binding var isPresented: Bool

    var body: some View {
        if isPresented {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundStyle(.white)
                Text(message)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.green.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)
            .transition(.move(edge: .top).combined(with: .opacity))
            .task {
                try? await Task.sleep(for: .seconds(3))
                guard !Task.isCancelled else { return }
                withAnimation { isPresented = false }
            }
        }
    }
}

struct ToastModifier: ViewModifier {
    let message: String
    @Binding var isPresented: Bool

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            ToastView(message: message, isPresented: $isPresented)
        }
        .animation(.spring(duration: 0.3), value: isPresented)
    }
}

extension View {
    func toast(message: String, isPresented: Binding<Bool>) -> some View {
        modifier(ToastModifier(message: message, isPresented: isPresented))
    }
}

#Preview {
    @Previewable @State var show = true
    VStack {
        Text("Preview")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .toast(message: "새로운 명언이 위젯에 표시되고 있습니다", isPresented: $show)
}
