import SwiftUI

struct QuizPlayView: View {
    let category: QuizCategory
    let difficulty: Difficulty
    let questionCount: Int

    @EnvironmentObject var quizEngine: QuizEngine
    @EnvironmentObject var userVM: UserProfileViewModel
    @Environment(\.dismiss) var dismiss

    @State private var showConfetti = false
    @State private var shakeWrong = false

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            if quizEngine.isFinished {
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
        .onAppear {
            quizEngine.startQuiz(category: category, difficulty: difficulty, count: questionCount)
        }
    }

    private func questionView(_ question: QuizQuestion) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Progress & Timer
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

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.white.opacity(0.1))
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Theme.primaryGradient)
                            .frame(width: geo.size.width * CGFloat(quizEngine.currentIndex) / CGFloat(quizEngine.questions.count), height: 6)
                            .animation(.spring(), value: quizEngine.currentIndex)
                    }
                }
                .frame(height: 6)

                // Score
                XPBadge(xp: quizEngine.score * 10)

                // Question
                GlassCard {
                    Text(question.question)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }

                // Options
                ForEach(question.options, id: \.self) { option in
                    optionButton(option, question: question)
                }

                // Explanation
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

    private func optionButton(_ option: String, question: QuizQuestion) -> some View {
        Button(action: {
            quizEngine.selectAnswer(option)
            if option == question.correctAnswer {
                showConfetti = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showConfetti = false }
            }
        }) {
            HStack {
                Text(option)
                    .font(.system(size: 17, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
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
            .background(optionBackground(option, question: question))
            .clipShape(RoundedRectangle(cornerRadius: Theme.buttonRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.buttonRadius)
                    .stroke(optionBorder(option, question: question), lineWidth: 2)
            )
        }
        .disabled(quizEngine.selectedAnswer != nil)
    }

    private func optionBackground(_ option: String, question: QuizQuestion) -> some ShapeStyle {
        if quizEngine.selectedAnswer == nil { return AnyShapeStyle(.ultraThinMaterial) }
        if option == question.correctAnswer { return AnyShapeStyle(Theme.mintGreen.opacity(0.2)) }
        if option == quizEngine.selectedAnswer { return AnyShapeStyle(Theme.coral.opacity(0.2)) }
        return AnyShapeStyle(.ultraThinMaterial)
    }

    private func optionBorder(_ option: String, question: QuizQuestion) -> Color {
        if quizEngine.selectedAnswer == nil { return .white.opacity(0.1) }
        if option == question.correctAnswer { return Theme.mintGreen }
        if option == quizEngine.selectedAnswer { return Theme.coral }
        return .white.opacity(0.1)
    }

    private var resultView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 40)

                Text(quizEngine.score >= quizEngine.questions.count / 2 ? "🎉" : "💪")
                    .font(.system(size: 70))

                Text(quizEngine.score >= quizEngine.questions.count / 2 ? "Great Job!" : "Keep Practicing!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                // Score card
                GradientCard(gradient: Theme.primaryGradient) {
                    VStack(spacing: 16) {
                        Text("\(quizEngine.score)/\(quizEngine.questions.count)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("Questions Correct")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))

                        HStack(spacing: 20) {
                            VStack {
                                Text("\(Int(Double(quizEngine.score) / Double(quizEngine.questions.count) * 100))%")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Text("Accuracy")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            VStack {
                                Text("+\(Int(Double(quizEngine.score * 10) * difficulty.multiplier))")
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
                    let result = quizEngine.makeResult()
                    userVM.recordQuiz(result)
                    dismiss()
                }

                BouncyButton("Try Again", icon: "arrow.counterclockwise") {
                    quizEngine.startQuiz(category: category, difficulty: difficulty, count: questionCount)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}
