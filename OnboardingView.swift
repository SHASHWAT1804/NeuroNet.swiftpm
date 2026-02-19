import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0
    @State private var robotBounce = false
    @State private var showButton = false

    let pages: [(emoji: String, title: String, description: String)] = [
        ("🤖", "Meet Neuro",
         "Hi there! I'm Neuro, your robot guide. I'll help you explore the amazing world of numbers and networks!"),
        ("🔢", "Number Systems",
         "Did you know computers only understand 0s and 1s? You'll learn to convert between binary, decimal, hex, and octal!"),
        ("🌐", "Networks",
         "The internet is like a giant web of connected devices. You'll learn how data travels, what IP addresses are, and more!"),
        ("🏆", "Earn & Learn",
         "Complete quizzes, earn XP, unlock badges, and climb the leaderboard. Learning has never been this fun!")
    ]

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Robot mascot
                Text(pages[currentPage].emoji)
                    .font(.system(size: 80))
                    .offset(y: robotBounce ? -10 : 10)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                               value: robotBounce)
                    .onAppear { robotBounce = true }

                Text(pages[currentPage].title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(pages[currentPage].description)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Circle()
                            .fill(i == currentPage ? Theme.electricBlue : .white.opacity(0.3))
                            .frame(width: i == currentPage ? 12 : 8,
                                   height: i == currentPage ? 12 : 8)
                            .animation(.spring(), value: currentPage)
                    }
                }

                if currentPage == pages.count - 1 {
                    BouncyButton("Start Learning", icon: "rocket.fill",
                                 gradient: Theme.successGradient) {
                        withAnimation { appState.hasCompletedOnboarding = true }
                    }
                    .transition(.scale.combined(with: .opacity))
                    .padding(.bottom, 20)
                } else {
                    BouncyButton("Next", icon: "arrow.right") {
                        withAnimation(.spring()) { currentPage += 1 }
                    }
                    .padding(.bottom, 20)
                }

                if currentPage < pages.count - 1 {
                    Button("Skip") {
                        withAnimation { appState.hasCompletedOnboarding = true }
                    }
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                }

                Spacer().frame(height: 30)
            }
        }
    }
}
