import SwiftUI
import Combine

@MainActor
final class UserProfileViewModel: ObservableObject {
    @Published var profile: UserProfile
    @Published var quizResults: [QuizResult]
    @Published var leaderboard: [LeaderboardEntry]

    private let store = DataStore.shared

    init() {
        self.profile = DataStore.shared.loadProfile()
        self.quizResults = DataStore.shared.loadQuizResults()
        self.leaderboard = DataStore.shared.loadLeaderboard()
        updateStreak()
    }

    func save() {
        store.saveProfile(profile)
    }

    func addXP(_ amount: Int) {
        profile.xp += amount
        while profile.xp >= profile.xpForNextLevel {
            profile.xp -= profile.xpForNextLevel
            profile.level += 1
        }
        checkBadges()
        save()
        updateLeaderboard()
    }

    func recordQuiz(_ result: QuizResult) {
        quizResults.append(result)
        store.saveQuizResult(result)
        let xpEarned = Int(Double(result.score * 10) * result.difficulty.multiplier)
        addXP(xpEarned)
    }

    func updateStreak() {
        guard let lastDate = profile.lastActiveDate else {
            profile.streak = 1
            profile.lastActiveDate = Date()
            save()
            return
        }
        let calendar = Calendar.current
        if calendar.isDateInToday(lastDate) {
            return
        } else if calendar.isDateInYesterday(lastDate) {
            profile.streak += 1
        } else {
            profile.streak = 1
        }
        profile.lastActiveDate = Date()
        save()
    }

    func updateLeaderboard() {
        let entry = LeaderboardEntry(
            id: UUID(), name: profile.name,
            xp: profile.xp + (profile.level - 1) * 150,
            level: profile.level, date: Date()
        )
        var board = leaderboard
        board.removeAll { $0.name == profile.name }
        board.append(entry)
        board.sort { $0.xp > $1.xp }
        if board.count > 20 { board = Array(board.prefix(20)) }
        leaderboard = board
        store.saveLeaderboard(board)
    }

    var totalAccuracy: Double {
        guard !quizResults.isEmpty else { return 0 }
        let total = quizResults.reduce(0.0) { $0 + $1.accuracy }
        return total / Double(quizResults.count)
    }

    var totalQuizzesTaken: Int { quizResults.count }

    func accuracyFor(category: QuizCategory) -> Double {
        let filtered = quizResults.filter { $0.category == category }
        guard !filtered.isEmpty else { return 0 }
        return filtered.reduce(0.0) { $0 + $1.accuracy } / Double(filtered.count)
    }

    private func checkBadges() {
        var badges = profile.badges
        let allBadges = BadgeDefinitions.all
        for def in allBadges {
            if !badges.contains(where: { $0.id == def.id }) {
                if def.requirement(profile, quizResults) {
                    var badge = Badge(id: def.id, name: def.title,
                                     icon: def.icon, description: def.description,
                                     isUnlocked: true, unlockedDate: Date())
                    badges.append(badge)
                }
            }
        }
        profile.badges = badges
    }

    func resetProgress() {
        store.resetAllData()
        profile = UserProfile()
        quizResults = []
        leaderboard = []
    }
}

@MainActor
enum BadgeDefinitions {
    static let all: [Achievement] = [
        Achievement(id: "first_quiz", title: "First Steps",
                    description: "Complete your first quiz", icon: "star.fill",
                    requirement: { _, results in results.count >= 1 }),
        Achievement(id: "ten_quizzes", title: "Quiz Master",
                    description: "Complete 10 quizzes", icon: "rosette",
                    requirement: { _, results in results.count >= 10 }),
        Achievement(id: "perfect_score", title: "Perfectionist",
                    description: "Get 100% on any quiz", icon: "crown.fill",
                    requirement: { _, results in results.contains { $0.accuracy >= 1.0 } }),
        Achievement(id: "level_5", title: "Rising Star",
                    description: "Reach level 5", icon: "star.circle.fill",
                    requirement: { profile, _ in profile.level >= 5 }),
        Achievement(id: "level_10", title: "Network Ninja",
                    description: "Reach level 10", icon: "bolt.circle.fill",
                    requirement: { profile, _ in profile.level >= 10 }),
        Achievement(id: "streak_7", title: "Week Warrior",
                    description: "7-day streak", icon: "flame.fill",
                    requirement: { profile, _ in profile.streak >= 7 }),
        Achievement(id: "xp_1000", title: "XP Hunter",
                    description: "Earn 1000+ total XP", icon: "sparkles",
                    requirement: { p, _ in p.xp + (p.level - 1) * 150 >= 1000 }),
        Achievement(id: "all_categories", title: "Well Rounded",
                    description: "Try every quiz category", icon: "circle.grid.cross.fill",
                    requirement: { _, results in
                        let cats = Set(results.map { $0.category })
                        return cats.count >= QuizCategory.allCases.count
                    }),
    ]
}
