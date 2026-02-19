import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var userVM: UserProfileViewModel

    var body: some View {
        Group {
            if !appState.hasCompletedOnboarding {
                OnboardingView()
                    .transition(.opacity)
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: appState.hasCompletedOnboarding)
    }
}

struct MainTabView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            NavigationStack { HomeView() }
                .tabItem {
                    Label(AppState.AppTab.home.title,
                          systemImage: AppState.AppTab.home.icon)
                }
                .tag(AppState.AppTab.home)

            NavigationStack { NumericPlaygroundView() }
                .tabItem {
                    Label(AppState.AppTab.numeric.title,
                          systemImage: AppState.AppTab.numeric.icon)
                }
                .tag(AppState.AppTab.numeric)

            NavigationStack { NetworkHubView() }
                .tabItem {
                    Label(AppState.AppTab.network.title,
                          systemImage: AppState.AppTab.network.icon)
                }
                .tag(AppState.AppTab.network)

            NavigationStack { ChallengeView() }
                .tabItem {
                    Label(AppState.AppTab.challenges.title,
                          systemImage: AppState.AppTab.challenges.icon)
                }
                .tag(AppState.AppTab.challenges)

            NavigationStack { ProfileView() }
                .tabItem {
                    Label(AppState.AppTab.profile.title,
                          systemImage: AppState.AppTab.profile.icon)
                }
                .tag(AppState.AppTab.profile)
        }
        .tint(Theme.electricBlue)
    }
}
