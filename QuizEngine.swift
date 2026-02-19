import SwiftUI
import Combine

@MainActor
final class QuizEngine: ObservableObject {
    @Published var currentQuestion: QuizQuestion?
    @Published var questions: [QuizQuestion] = []
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var selectedAnswer: String?
    @Published var isCorrect: Bool?
    @Published var isFinished = false
    @Published var timeRemaining: Int = 30
    @Published var showExplanation = false
    @Published var difficulty: Difficulty = .easy
    @Published var category: QuizCategory = .binaryDecimal

    private var timer: AnyCancellable?
    private var startTime = Date()

    func startQuiz(category: QuizCategory, difficulty: Difficulty, count: Int = 10) {
        self.category = category
        self.difficulty = difficulty
        self.score = 0
        self.currentIndex = 0
        self.isFinished = false
        self.selectedAnswer = nil
        self.isCorrect = nil
        self.showExplanation = false
        self.startTime = Date()
        self.questions = generateQuestions(category: category, difficulty: difficulty, count: count)
        if !questions.isEmpty {
            currentQuestion = questions[0]
        }
        startTimer()
    }

    func selectAnswer(_ answer: String) {
        guard selectedAnswer == nil, let q = currentQuestion else { return }
        selectedAnswer = answer
        isCorrect = answer == q.correctAnswer
        if isCorrect == true { score += 1 }
        showExplanation = true
        stopTimer()
    }

    func nextQuestion() {
        currentIndex += 1
        selectedAnswer = nil
        isCorrect = nil
        showExplanation = false
        if currentIndex < questions.count {
            currentQuestion = questions[currentIndex]
            startTimer()
        } else {
            isFinished = true
        }
    }

    func makeResult() -> QuizResult {
        QuizResult(
            id: UUID(), category: category, score: score,
            totalQuestions: questions.count, difficulty: difficulty,
            date: Date(), timeTaken: Date().timeIntervalSince(startTime)
        )
    }

    private func startTimer() {
        timeRemaining = difficulty == .easy ? 30 : difficulty == .medium ? 20 : 15
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.selectAnswer("")
                }
            }
    }

    private func stopTimer() { timer?.cancel() }

    // MARK: - Question Generation

    private func generateQuestions(category: QuizCategory, difficulty: Difficulty, count: Int) -> [QuizQuestion] {
        var qs: [QuizQuestion] = []
        for _ in 0..<count {
            switch category {
            case .binaryDecimal: qs.append(genBinaryDecimal(difficulty))
            case .decimalHex: qs.append(genDecimalHex(difficulty))
            case .decimalOctal: qs.append(genDecimalOctal(difficulty))
            case .hexBinary: qs.append(genHexBinary(difficulty))
            case .ipAddressing: qs.append(genIPQuestion(difficulty))
            case .subnetting: qs.append(genSubnetQuestion(difficulty))
            case .protocols: qs.append(genProtocolQuestion(difficulty))
            case .mixed:
                let cats: [QuizCategory] = [.binaryDecimal, .decimalHex, .ipAddressing, .protocols]
                qs.append(generateQuestions(category: cats.randomElement()!, difficulty: difficulty, count: 1).first!)
            }
        }
        return qs.shuffled()
    }

    private func genBinaryDecimal(_ d: Difficulty) -> QuizQuestion {
        let max = d == .easy ? 15 : d == .medium ? 63 : 255
        let num = Int.random(in: 1...max)
        let isToBinary = Bool.random()
        if isToBinary {
            let correct = String(num, radix: 2)
            let opts = generateOptions(correct: correct) { String(Int.random(in: 1...max), radix: 2) }
            return QuizQuestion(
                question: "Convert decimal \(num) to binary",
                correctAnswer: correct, options: opts,
                explanation: "\(num) in binary is \(correct). Each bit represents a power of 2.",
                category: .binaryDecimal)
        } else {
            let binary = String(num, radix: 2)
            let correct = "\(num)"
            let opts = generateOptions(correct: correct) { "\(Int.random(in: 1...max))" }
            return QuizQuestion(
                question: "Convert binary \(binary) to decimal",
                correctAnswer: correct, options: opts,
                explanation: "Binary \(binary) = \(num) in decimal.",
                category: .binaryDecimal)
        }
    }

    private func genDecimalHex(_ d: Difficulty) -> QuizQuestion {
        let max = d == .easy ? 15 : d == .medium ? 127 : 255
        let num = Int.random(in: 1...max)
        let isToHex = Bool.random()
        if isToHex {
            let correct = String(num, radix: 16).uppercased()
            let opts = generateOptions(correct: correct) { String(Int.random(in: 1...max), radix: 16).uppercased() }
            return QuizQuestion(
                question: "Convert decimal \(num) to hexadecimal",
                correctAnswer: correct, options: opts,
                explanation: "\(num) in hex is \(correct).",
                category: .decimalHex)
        } else {
            let hex = String(num, radix: 16).uppercased()
            let correct = "\(num)"
            let opts = generateOptions(correct: correct) { "\(Int.random(in: 1...max))" }
            return QuizQuestion(
                question: "Convert hex \(hex) to decimal",
                correctAnswer: correct, options: opts,
                explanation: "Hex \(hex) = \(num) in decimal.",
                category: .decimalHex)
        }
    }

    private func genDecimalOctal(_ d: Difficulty) -> QuizQuestion {
        let max = d == .easy ? 15 : d == .medium ? 63 : 255
        let num = Int.random(in: 1...max)
        let correct = String(num, radix: 8)
        let opts = generateOptions(correct: correct) { String(Int.random(in: 1...max), radix: 8) }
        return QuizQuestion(
            question: "Convert decimal \(num) to octal",
            correctAnswer: correct, options: opts,
            explanation: "\(num) in octal is \(correct).",
            category: .decimalOctal)
    }

    private func genHexBinary(_ d: Difficulty) -> QuizQuestion {
        let max = d == .easy ? 15 : d == .medium ? 127 : 255
        let num = Int.random(in: 1...max)
        let hex = String(num, radix: 16).uppercased()
        let correct = String(num, radix: 2)
        let opts = generateOptions(correct: correct) { String(Int.random(in: 1...max), radix: 2) }
        return QuizQuestion(
            question: "Convert hex \(hex) to binary",
            correctAnswer: correct, options: opts,
            explanation: "Hex \(hex) → decimal \(num) → binary \(correct).",
            category: .hexBinary)
    }

    private func genIPQuestion(_ d: Difficulty) -> QuizQuestion {
        let questions: [(String, String, String, [String])] = [
            ("What class is IP 10.0.0.1?", "Class A", "IPs 1-126 are Class A.", ["Class A", "Class B", "Class C", "Class D"]),
            ("What class is IP 172.16.0.1?", "Class B", "IPs 128-191 are Class B.", ["Class A", "Class B", "Class C", "Class D"]),
            ("What class is IP 192.168.1.1?", "Class C", "IPs 192-223 are Class C.", ["Class A", "Class B", "Class C", "Class D"]),
            ("What is the loopback address?", "127.0.0.1", "127.0.0.1 is reserved for loopback.", ["127.0.0.1", "192.168.0.1", "10.0.0.1", "0.0.0.0"]),
            ("How many bits in an IPv4 address?", "32", "IPv4 uses 32 bits (4 octets × 8 bits).", ["16", "32", "64", "128"]),
            ("What is the broadcast address for 192.168.1.0/24?", "192.168.1.255", "With /24, the last octet is all 1s = 255.", ["192.168.1.255", "192.168.1.0", "192.168.1.1", "192.168.0.255"]),
        ]
        let q = questions.randomElement()!
        return QuizQuestion(question: q.0, correctAnswer: q.1, options: q.3.shuffled(), explanation: q.2, category: .ipAddressing)
    }

    private func genSubnetQuestion(_ d: Difficulty) -> QuizQuestion {
        let questions: [(String, String, String, [String])] = [
            ("How many hosts in a /24 network?", "254", "/24 = 256 addresses - 2 (network + broadcast) = 254.", ["254", "256", "128", "252"]),
            ("What subnet mask is /16?", "255.255.0.0", "/16 means first 16 bits are 1s.", ["255.255.0.0", "255.0.0.0", "255.255.255.0", "255.255.128.0"]),
            ("What CIDR is 255.255.255.0?", "/24", "255.255.255.0 has 24 bits set to 1.", ["/24", "/16", "/8", "/32"]),
            ("How many subnets with /26?", "4", "/26 borrows 2 bits from /24, giving 2² = 4 subnets.", ["2", "4", "8", "16"]),
            ("What is the network address of 192.168.1.130/25?", "192.168.1.128", "/25 splits at 128. 130 > 128, so network is .128.", ["192.168.1.128", "192.168.1.0", "192.168.1.64", "192.168.1.192"]),
        ]
        let q = questions.randomElement()!
        return QuizQuestion(question: q.0, correctAnswer: q.1, options: q.3.shuffled(), explanation: q.2, category: .subnetting)
    }

    private func genProtocolQuestion(_ d: Difficulty) -> QuizQuestion {
        let questions: [(String, String, String, [String])] = [
            ("What protocol resolves IP to MAC?", "ARP", "ARP (Address Resolution Protocol) maps IP → MAC.", ["ARP", "DNS", "DHCP", "ICMP"]),
            ("What protocol does ping use?", "ICMP", "Ping uses ICMP Echo Request/Reply.", ["ICMP", "TCP", "UDP", "ARP"]),
            ("What layer does a router operate at?", "Layer 3", "Routers work at the Network layer (Layer 3).", ["Layer 1", "Layer 2", "Layer 3", "Layer 4"]),
            ("What layer does a switch operate at?", "Layer 2", "Switches work at the Data Link layer (Layer 2).", ["Layer 1", "Layer 2", "Layer 3", "Layer 4"]),
            ("What does DHCP provide?", "IP addresses", "DHCP automatically assigns IP addresses.", ["IP addresses", "MAC addresses", "Domain names", "Encryption"]),
            ("What port does HTTP use?", "80", "HTTP uses port 80 by default.", ["80", "443", "21", "25"]),
            ("What does DNS resolve?", "Domain to IP", "DNS translates domain names to IP addresses.", ["Domain to IP", "IP to MAC", "MAC to IP", "Port to IP"]),
        ]
        let q = questions.randomElement()!
        return QuizQuestion(question: q.0, correctAnswer: q.1, options: q.3.shuffled(), explanation: q.2, category: .protocols)
    }

    private func generateOptions(correct: String, generator: () -> String) -> [String] {
        var opts = Set<String>([correct])
        var attempts = 0
        while opts.count < 4 && attempts < 50 {
            opts.insert(generator())
            attempts += 1
        }
        while opts.count < 4 { opts.insert("N/A\(opts.count)") }
        return Array(opts).shuffled()
    }
}
