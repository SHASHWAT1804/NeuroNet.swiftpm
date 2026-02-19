import SwiftUI

struct NumericPlaygroundView: View {
    @State private var selectedSection: NumericSection?

    enum NumericSection: String, CaseIterable, Identifiable {
        case converter = "Converter"
        case quiz = "Quiz Mode"
        var id: String { rawValue }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                Text("Numeric Playground")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)

                Text("Master number systems through interactive tools and quizzes")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Interactive Converter
                NavigationLink(destination: ConverterView()) {
                    ModuleCardContent(title: "Interactive Converter",
                                      subtitle: "Convert between number systems with step-by-step visuals",
                                      icon: "arrow.left.arrow.right.circle.fill",
                                      gradient: Theme.primaryGradient)
                }
                .buttonStyle(.plain)

                // Quiz categories
                Text("Quiz Modes")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach([QuizCategory.binaryDecimal, .decimalHex, .decimalOctal, .hexBinary], id: \.self) { cat in
                        NavigationLink(destination: QuizSetupView(category: cat)) {
                            QuizCategoryCard(category: cat)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(Theme.backgroundGradient.ignoresSafeArea())
    }
}

struct ModuleCardContent: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: LinearGradient

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(.white.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(20)
        .background(gradient)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
        .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
    }
}

struct QuizCategoryCard: View {
    let category: QuizCategory

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: category.icon)
                .font(.system(size: 28))
                .foregroundColor(.white)
            Text(category.rawValue)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardRadius)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
    }
}
