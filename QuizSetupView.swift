import SwiftUI

struct QuizSetupView: View {
    let category: QuizCategory
    @State private var difficulty: Difficulty = .easy
    @State private var questionCount = 10
    @State private var startQuiz = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: category.icon)
                .font(.system(size: 60))
                .foregroundColor(.white)
                .padding(30)
                .background(Theme.primaryGradient)
                .clipShape(Circle())

            Text(category.rawValue)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            // Difficulty
            GlassCard {
                VStack(spacing: 12) {
                    Text("Difficulty")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(Difficulty.allCases, id: \.self) { d in
                            Text(d.rawValue).tag(d)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }

            // Question count
            GlassCard {
                VStack(spacing: 12) {
                    Text("Questions: \(questionCount)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Slider(value: Binding(
                        get: { Double(questionCount) },
                        set: { questionCount = Int($0) }
                    ), in: 5...20, step: 5)
                    .tint(Theme.electricBlue)
                }
            }

            Spacer()

            NavigationLink(destination: QuizPlayView(category: category,
                                                      difficulty: difficulty,
                                                      questionCount: questionCount)) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start Quiz")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Theme.primaryGradient)
                .clipShape(RoundedRectangle(cornerRadius: Theme.buttonRadius))
                .shadow(color: Theme.electricBlue.opacity(0.4), radius: 10, y: 5)
            }
            .padding(.horizontal, 20)

            Spacer().frame(height: 20)
        }
        .padding(.horizontal, 20)
        .background(Theme.backgroundGradient.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}
