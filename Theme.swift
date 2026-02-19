import SwiftUI

enum Theme {
    static let electricBlue = Color(red: 0.0, green: 0.48, blue: 1.0)
    static let neonPurple = Color(red: 0.58, green: 0.25, blue: 0.98)
    static let mintGreen = Color(red: 0.2, green: 0.88, blue: 0.7)
    static let softYellow = Color(red: 1.0, green: 0.85, blue: 0.3)
    static let darkNavy = Color(red: 0.07, green: 0.07, blue: 0.18)
    static let cardBackground = Color(red: 0.12, green: 0.12, blue: 0.25)
    static let coral = Color(red: 1.0, green: 0.42, blue: 0.42)

    static let primaryGradient = LinearGradient(
        colors: [electricBlue, neonPurple],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let successGradient = LinearGradient(
        colors: [mintGreen, electricBlue],
        startPoint: .leading, endPoint: .trailing
    )
    static let warmGradient = LinearGradient(
        colors: [softYellow, coral],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let backgroundGradient = LinearGradient(
        colors: [darkNavy, Color(red: 0.1, green: 0.08, blue: 0.28)],
        startPoint: .top, endPoint: .bottom
    )

    static let cardRadius: CGFloat = 24
    static let buttonRadius: CGFloat = 16
    static let smallRadius: CGFloat = 12
}
