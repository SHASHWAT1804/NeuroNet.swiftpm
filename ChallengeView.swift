import SwiftUI

struct ChallengeView: View {
    @EnvironmentObject var userVM: UserProfileViewModel
    @State private var showDailyChallenge = false

    private let store = DataStore.shared

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                Text("Challenges")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)

                // Daily Challenge
                dailyChallengeCard

                // Quick challenges
                Text("Quick Challenges")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                NavigationLink(destination: QuizSetupView(category: .mixed)) {
                    ModuleCardContent(title: "Mixed Challenge",
                                      subtitle: "Random questions from all categories",
                                      icon: "shuffle",
                                      gradient: Theme.warmGradient)
                }
                .buttonStyle(.plain)

                // High Scores
                Text("Recent Scores")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if userVM.quizResults.isEmpty {
                    GlassCard {
                        VStack(spacing: 8) {
                            Image(systemName: "trophy")
                                .font(.system(size: 36))
                                .foregroundColor(.white.opacity(0.3))
                            Text("No scores yet")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.5))
                            Text("Complete a quiz to see your scores here")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                } else {
                    ForEach(userVM.quizResults.suffix(10).reversed()) { result in
                        scoreRow(result)
                    }
                }

                // Leaderboard
                if !userVM.leaderboard.isEmpty {
                    Text("Leaderboard")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ForEach(Array(userVM.leaderboard.prefix(10).enumerated()), id: \.element.id) { index, entry in
                        leaderboardRow(index: index, entry: entry)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(Theme.backgroundGradient.ignoresSafeArea())
    }

    private var dailyChallengeCard: some View {
        let completed = store.isDailyChallengeCompleted()
        return NavigationLink(destination: DailyChallengePlayView()) {
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("🏆")
                        .font(.system(size: 36))
                    if completed {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Theme.mintGreen)
                    }
                }
                .frame(width: 56)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Challenge")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(completed ? "Completed! Come back tomorrow" : "Test your skills with today's challenge")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                if !completed {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(20)
            .background(
                LinearGradient(colors: completed ? [.gray.opacity(0.3), .gray.opacity(0.2)] :
                                [Theme.softYellow.opacity(0.8), Theme.coral.opacity(0.8)],
                               startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
        }
        .buttonStyle(.plain)
        .disabled(completed)
    }

    private func scoreRow(_ result: QuizResult) -> some View {
        HStack(spacing: 14) {
            Image(systemName: result.category.icon)
                .font(.system(size: 20))
                .foregroundColor(Theme.electricBlue)
                .frame(width: 40, height: 40)
                .background(Theme.electricBlue.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(result.category.rawValue)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("\(result.difficulty.rawValue) • \(result.date.formatted(date: .abbreviated, time: .shortened))")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(result.score)/\(result.totalQuestions)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("\(Int(result.accuracy * 100))%")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(result.accuracy >= 0.7 ? Theme.mintGreen : Theme.coral)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.smallRadius))
    }

    private func leaderboardRow(index: Int, entry: LeaderboardEntry) -> some View {
        HStack(spacing: 14) {
            Text(index == 0 ? "🥇" : index == 1 ? "🥈" : index == 2 ? "🥉" : "#\(index + 1)")
                .font(.system(size: index < 3 ? 22 : 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 36)

            Text(entry.name)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(entry.xp) XP")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.softYellow)
                Text("Lv.\(entry.level)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.smallRadius))
    }
}
