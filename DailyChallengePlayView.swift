import SwiftUI

struct DailyChallengePlayView: View {
    @EnvironmentObject var quizEngine: QuizEngine
    @EnvironmentObject var userVM: UserProfileViewModel
    @Environment(\.dismiss) var dismiss

    @State private var showConfetti = false
    @State private var hasStarted = false

    private let store = DataStore.shared

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            if !hasStarted {
                startScreen
            } else if quizEngine.isFinished {
                resultView
            } else if let question = quizEngine.currentQuestion {
                questionView(question)
            }

            if showConfetti { ConfettiView() }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 22))
                }
            }
        }
    }

    private var startScreen: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("🏆")
                .font(.system(size: 80))

            Text("Daily Challenge")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("5 tricky questions mixing numbers & networking.\nScenario-based. No setup needed. Are you ready?")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            GlassCard {
                VStack(spacing: 8) {
                    HStack(spacing: 20) {
                        VStack {
                            Text("5")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.electricBlue)
                            Text("Questions")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        VStack {
                            Text("Hard")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.coral)
                            Text("Difficulty")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        VStack {
                            Text("2×")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.softYellow)
                            Text("XP Bonus")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
            }
            .padding(.horizontal, 20)

            Spacer()

            BouncyButton("Begin Challenge", icon: "play.fill", gradient: Theme.warmGradient) {
                Haptics.heavy()
                hasStarted = true
                quizEngine.startQuiz(category: .dailyChallenge, difficulty: .hard, count: 5)
            }

            Spacer().frame(height: 40)
        }
    }

    private func questionView(_ question: QuizQuestion) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                HStack {
                    Text("Q\(quizEngine.currentIndex + 1)/\(quizEngine.questions.count)")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(quizEngine.timeRemaining <= 5 ? Theme.coral : Theme.mintGreen)
                        Text("\(quizEngine.timeRemaining)s")
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(quizEngine.timeRemaining <= 5 ? Theme.coral : .white)
                    }
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.white.opacity(0.1))
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Theme.warmGradient)
                            .frame(width: geo.size.width * CGFloat(quizEngine.currentIndex) / CGFloat(quizEngine.questions.count), height: 6)
                            .animation(.spring(), value: quizEngine.currentIndex)
                    }
                }
                .frame(height: 6)

                HStack {
                    Text("🏆 Daily Challenge")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.softYellow)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Theme.softYellow.opacity(0.15))
                        .clipShape(Capsule())
                    Spacer()
                    XPBadge(xp: quizEngine.score * 20)
                }

                GlassCard {
                    Text(question.question)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }

                ForEach(question.options, id: \.self) { option in
                    Button(action: {
                        quizEngine.selectAnswer(option)
                        if option == question.correctAnswer {
                            Haptics.success()
                            showConfetti = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showConfetti = false }
                        } else {
                            Haptics.error()
                        }
                    }) {
                        HStack {
                            Text(option)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            if quizEngine.selectedAnswer != nil {
                                if option == question.correctAnswer {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Theme.mintGreen)
                                } else if option == quizEngine.selectedAnswer {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Theme.coral)
                                }
                            }
                        }
                        .padding(16)
                        .background(optionBG(option, question: question))
                        .clipShape(RoundedRectangle(cornerRadius: Theme.buttonRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.buttonRadius)
                                .stroke(optionStroke(option, question: question), lineWidth: 2)
                        )
                    }
                    .disabled(quizEngine.selectedAnswer != nil)
                }

                if quizEngine.showExplanation {
                    GlassCard {
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: quizEngine.isCorrect == true ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(quizEngine.isCorrect == true ? Theme.mintGreen : Theme.coral)
                                Text(quizEngine.isCorrect == true ? "Correct!" : "Not quite!")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(quizEngine.isCorrect == true ? Theme.mintGreen : Theme.coral)
                            }
                            Text(question.explanation)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .transition(.scale.combined(with: .opacity))

                    BouncyButton("Next", icon: "arrow.right") {
                        quizEngine.nextQuestion()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }

    private func optionBG(_ option: String, question: QuizQuestion) -> some ShapeStyle {
        if quizEngine.selectedAnswer == nil { return AnyShapeStyle(.ultraThinMaterial) }
        if option == question.correctAnswer { return AnyShapeStyle(Theme.mintGreen.opacity(0.2)) }
        if option == quizEngine.selectedAnswer { return AnyShapeStyle(Theme.coral.opacity(0.2)) }
        return AnyShapeStyle(.ultraThinMaterial)
    }

    private func optionStroke(_ option: String, question: QuizQuestion) -> Color {
        if quizEngine.selectedAnswer == nil { return .white.opacity(0.1) }
        if option == question.correctAnswer { return Theme.mintGreen }
        if option == quizEngine.selectedAnswer { return Theme.coral }
        return .white.opacity(0.1)
    }

    private var resultView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 40)

                Text(quizEngine.score >= 3 ? "🎉" : "💪")
                    .font(.system(size: 70))

                Text(quizEngine.score >= 4 ? "Amazing!" : quizEngine.score >= 3 ? "Well Done!" : "Keep Going!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                GradientCard(gradient: Theme.warmGradient) {
                    VStack(spacing: 16) {
                        Text("\(quizEngine.score)/\(quizEngine.questions.count)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("Daily Challenge Complete")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))

                        HStack(spacing: 20) {
                            VStack {
                                Text("\(Int(Double(quizEngine.score) / Double(max(quizEngine.questions.count, 1)) * 100))%")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Text("Accuracy")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            VStack {
                                Text("+\(quizEngine.score * 20)")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(Theme.softYellow)
                                Text("XP Earned")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                BouncyButton("Save & Exit", icon: "checkmark.circle.fill",
                              gradient: Theme.successGradient) {
                    Haptics.success()
                    let result = quizEngine.makeResult()
                    userVM.recordQuiz(result)
                    store.markDailyChallengeCompleted()
                    dismiss()
                }
            }
            .padding(.horizontal, 20)
        }
    }
}
