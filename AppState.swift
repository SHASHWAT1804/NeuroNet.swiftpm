import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    @AppStorage("isDarkMode") var isDarkMode = false

    @Published var selectedTab: AppTab = .home

    enum AppTab: Int, CaseIterable {
        case home, numeric, network, challenges, profile
        var title: String {
            switch self {
            case .home: return "Home"
            case .numeric: return "Numbers"
            case .network: return "Network"
            case .challenges: return "Challenges"
            case .profile: return "Profile"
            }
        }
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .numeric: return "number.circle.fill"
            case .network: return "network"
            case .challenges: return "trophy.fill"
            case .profile: return "person.crop.circle.fill"
            }
        }
    }
}
