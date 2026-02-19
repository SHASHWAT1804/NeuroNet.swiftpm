import Foundation
import Combine

@MainActor
final class DataStore {
    static let shared = DataStore()
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let userProfile = "neuronet_user_profile"
        static let quizResults = "neuronet_quiz_results"
        static let leaderboard = "neuronet_leaderboard"
        static let dailyChallengeDate = "neuronet_daily_challenge_date"
        static let dailyChallengeCompleted = "neuronet_daily_challenge_completed"
    }

    func saveProfile(_ profile: UserProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            defaults.set(data, forKey: Keys.userProfile)
        }
    }

    func loadProfile() -> UserProfile {
        guard let data = defaults.data(forKey: Keys.userProfile),
              let profile = try? JSONDecoder().decode(UserProfile.self, from: data)
        else { return UserProfile() }
        return profile
    }

    func saveQuizResult(_ result: QuizResult) {
        var results = loadQuizResults()
        results.append(result)
        if let data = try? JSONEncoder().encode(results) {
            defaults.set(data, forKey: Keys.quizResults)
        }
    }

    func loadQuizResults() -> [QuizResult] {
        guard let data = defaults.data(forKey: Keys.quizResults),
              let results = try? JSONDecoder().decode([QuizResult].self, from: data)
        else { return [] }
        return results
    }

    func saveLeaderboard(_ entries: [LeaderboardEntry]) {
        if let data = try? JSONEncoder().encode(entries) {
            defaults.set(data, forKey: Keys.leaderboard)
        }
    }

    func loadLeaderboard() -> [LeaderboardEntry] {
        guard let data = defaults.data(forKey: Keys.leaderboard),
              let entries = try? JSONDecoder().decode([LeaderboardEntry].self, from: data)
        else { return [] }
        return entries
    }

    func isDailyChallengeCompleted() -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        guard let savedDate = defaults.object(forKey: Keys.dailyChallengeDate) as? Date else {
            return false
        }
        return Calendar.current.isDate(savedDate, inSameDayAs: today) &&
               defaults.bool(forKey: Keys.dailyChallengeCompleted)
    }

    func markDailyChallengeCompleted() {
        defaults.set(Date(), forKey: Keys.dailyChallengeDate)
        defaults.set(true, forKey: Keys.dailyChallengeCompleted)
    }

    func resetAllData() {
        let domain = Bundle.main.bundleIdentifier ?? ""
        defaults.removePersistentDomain(forName: domain)
    }
}
