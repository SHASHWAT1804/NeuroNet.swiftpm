import SwiftUI

@main
struct NeuroNetKidsApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var userVM = UserProfileViewModel()
    @StateObject private var quizEngine = QuizEngine()
    @StateObject private var networkVM = NetworkPlaygroundViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(userVM)
                .environmentObject(quizEngine)
                .environmentObject(networkVM)
                .preferredColorScheme(appState.isDarkMode ? .dark : .none)
        }
    }
}
