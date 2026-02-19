import Foundation

struct UserProfile: Codable {
    var name: String = "Explorer"
    var avatarIndex: Int = 0
    var xp: Int = 0
    var level: Int = 1
    var streak: Int = 0
    var lastActiveDate: Date? = nil
    var badges: [Badge] = []
    var completedModules: Set<String> = []

    var xpForNextLevel: Int { level * 150 }
    var levelProgress: Double {
        Double(xp % xpForNextLevel) / Double(xpForNextLevel)
    }

    static let avatars = [
        "🤖", "🧠", "🚀", "🦊", "🐱", "🦄", "🐼", "🦁",
        "🐸", "🌟", "⚡️", "🎮"
    ]
}

struct Badge: Codable, Identifiable {
    let id: String
    let name: String
    let icon: String
    let description: String
    var isUnlocked: Bool = false
    var unlockedDate: Date? = nil
}

struct QuizResult: Codable, Identifiable {
    let id: UUID
    let category: QuizCategory
    let score: Int
    let totalQuestions: Int
    let difficulty: Difficulty
    let date: Date
    let timeTaken: TimeInterval

    var accuracy: Double {
        totalQuestions > 0 ? Double(score) / Double(totalQuestions) : 0
    }
}

enum QuizCategory: String, Codable, CaseIterable {
    case binaryDecimal = "Binary ↔ Decimal"
    case decimalHex = "Decimal ↔ Hex"
    case decimalOctal = "Decimal ↔ Octal"
    case hexBinary = "Hex ↔ Binary"
    case ipAddressing = "IP Addressing"
    case subnetting = "Subnetting"
    case protocols = "Protocols"
    case mixed = "Mixed Challenge"
    case dailyChallenge = "Daily Challenge"

    var icon: String {
        switch self {
        case .binaryDecimal: return "01.square.fill"
        case .decimalHex: return "number.circle.fill"
        case .decimalOctal: return "8.circle.fill"
        case .hexBinary: return "textformat.123"
        case .ipAddressing: return "network"
        case .subnetting: return "square.grid.3x3.fill"
        case .protocols: return "arrow.triangle.branch"
        case .mixed: return "shuffle"
        case .dailyChallenge: return "calendar.circle.fill"
        }
    }

    var color: String {
        switch self {
        case .binaryDecimal: return "blue"
        case .decimalHex: return "purple"
        case .decimalOctal: return "green"
        case .hexBinary: return "orange"
        case .ipAddressing: return "teal"
        case .subnetting: return "pink"
        case .protocols: return "indigo"
        case .mixed: return "yellow"
        case .dailyChallenge: return "red"
        }
    }
}

enum Difficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var multiplier: Double {
        switch self {
        case .easy: return 1.0
        case .medium: return 1.5
        case .hard: return 2.0
        }
    }
}

struct QuizQuestion {
    let question: String
    let correctAnswer: String
    let options: [String]
    let explanation: String
    let category: QuizCategory
}

struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let requirement: (UserProfile, [QuizResult]) -> Bool
}

struct NetworkDevice: Identifiable {
    let id = UUID()
    var type: DeviceType
    var position: CGPoint
    var label: String

    enum DeviceType: String, CaseIterable {
        case computer = "Computer"
        case router = "Router"
        case switchDevice = "Switch"
        case firewall = "Firewall"
        case server = "Server"

        var icon: String {
            switch self {
            case .computer: return "desktopcomputer"
            case .router: return "wifi.router.fill"
            case .switchDevice: return "arrow.triangle.branch"
            case .firewall: return "flame.fill"
            case .server: return "server.rack"
            }
        }
    }
}

struct NetworkConnection: Identifiable {
    let id = UUID()
    let fromDeviceId: UUID
    let toDeviceId: UUID
}

struct Packet: Identifiable {
    let id = UUID()
    var sourceIP: String
    var destIP: String
    var sourceMAC: String
    var destMAC: String
    var protocol_: String
    var progress: CGFloat = 0
    let connectionId: UUID
}

struct LeaderboardEntry: Codable, Identifiable {
    let id: UUID
    let name: String
    let xp: Int
    let level: Int
    let date: Date
}
