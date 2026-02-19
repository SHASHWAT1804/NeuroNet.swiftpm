import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userVM: UserProfileViewModel
    @EnvironmentObject var appState: AppState

    @State private var animateCards = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header
                headerSection
                // Stats row
                statsRow
                // Modules
                modulesSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(Theme.backgroundGradient.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.spring().delay(0.2)) { animateCards = true }
        }
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hello, \(userVM.profile.name)!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Ready to learn something new?")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(Theme.primaryGradient)
                    .frame(width: 50, height: 50)
                Text(UserProfile.avatars[userVM.profile.avatarIndex])
                    .font(.system(size: 26))
            }
        }
        .padding(.top, 20)
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            StatCard(title: "Level", value: "\(userVM.profile.level)",
                     icon: "bolt.fill", color: Theme.electricBlue)
            StatCard(title: "XP", value: "\(userVM.profile.xp)",
                     icon: "star.fill", color: Theme.softYellow)
            StatCard(title: "Streak", value: "\(userVM.profile.streak)🔥",
                     icon: "flame.fill", color: Theme.coral)
        }
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 20)
    }

    private var modulesSection: some View {
        VStack(spacing: 16) {
            Text("Learning Modules")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            ModuleCard(title: "Numeric Playground",
                       subtitle: "Binary, Hex, Octal conversions",
                       icon: "number.circle.fill",
                       gradient: Theme.primaryGradient) {
                appState.selectedTab = .numeric
            }
            .opacity(animateCards ? 1 : 0)
            .offset(y: animateCards ? 0 : 30)

            ModuleCard(title: "Network Playground",
                       subtitle: "Routers, packets, protocols",
                       icon: "network",
                       gradient: Theme.successGradient) {
                appState.selectedTab = .network
            }
            .opacity(animateCards ? 1 : 0)
            .offset(y: animateCards ? 0 : 40)

            ModuleCard(title: "Daily Challenge",
                       subtitle: "Test your skills today",
                       icon: "trophy.fill",
                       gradient: Theme.warmGradient) {
                appState.selectedTab = .challenges
            }
            .opacity(animateCards ? 1 : 0)
            .offset(y: animateCards ? 0 : 50)

            // Level progress
            GlassCard {
                VStack(spacing: 12) {
                    HStack {
                        Text("Level \(userVM.profile.level)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(userVM.profile.xp)/\(userVM.profile.xpForNextLevel) XP")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.white.opacity(0.1))
                                .frame(height: 12)
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Theme.primaryGradient)
                                .frame(width: geo.size.width * userVM.profile.levelProgress,
                                       height: 12)
                                .animation(.spring(), value: userVM.profile.levelProgress)
                        }
                    }
                    .frame(height: 12)
                }
            }
            .opacity(animateCards ? 1 : 0)
        }
    }
}
