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
                // Mixed: random from ALL numeric + network categories
                let allCats: [QuizCategory] = [.binaryDecimal, .decimalHex, .decimalOctal, .hexBinary,
                                               .ipAddressing, .subnetting, .protocols]
                let picked = allCats.randomElement()!
                qs.append(generateQuestions(category: picked, difficulty: difficulty, count: 1).first!)
            case .dailyChallenge:
                // Daily: seeded by day, harder, uses tricky questions
                qs.append(genDailyChallengeQuestion(difficulty, index: qs.count))
            }
        }
        return qs.shuffled()
    }
    
    // MARK: - Binary ↔ Decimal (expanded)
    
    private func genBinaryDecimal(_ d: Difficulty) -> QuizQuestion {
        let maxVal = d == .easy ? 31 : d == .medium ? 127 : 255
        let num = Int.random(in: 1...maxVal)
        let variant = Int.random(in: 0...3)
        
        switch variant {
        case 0:
            let correct = String(num, radix: 2)
            let opts = generateOptions(correct: correct) { String(Int.random(in: 1...maxVal), radix: 2) }
            return QuizQuestion(
                question: "What is \(num) in binary?",
                correctAnswer: correct, options: opts,
                explanation: "To convert \(num) to binary, divide by 2 repeatedly. \(num) = \(correct) in binary.",
                category: .binaryDecimal)
        case 1:
            let binary = String(num, radix: 2)
            let correct = "\(num)"
            let opts = generateOptions(correct: correct) { "\(Int.random(in: 1...maxVal))" }
            return QuizQuestion(
                question: "What decimal number does binary \(binary) represent?",
                correctAnswer: correct, options: opts,
                explanation: "Each bit position is a power of 2. Binary \(binary) = \(num) in decimal.",
                category: .binaryDecimal)
        case 2:
            let binary = String(num, radix: 2)
            let bitCount = binary.count
            let correct = "\(bitCount)"
            let opts = generateOptions(correct: correct) {
                "\(Int.random(in: max(1, bitCount-2)...bitCount+3))"
            }
            return QuizQuestion(
                question: "How many bits are needed to represent \(num) in binary?",
                correctAnswer: correct, options: opts,
                explanation: "\(num) in binary is \(binary), which has \(bitCount) bits.",
                category: .binaryDecimal)
        default:
            let a = Int.random(in: 1...maxVal/2)
            let b = Int.random(in: 1...maxVal/2)
            let sum = a + b
            let correct = String(sum, radix: 2)
            let binA = String(a, radix: 2)
            let binB = String(b, radix: 2)
            let opts = generateOptions(correct: correct) { String(Int.random(in: 1...maxVal), radix: 2) }
            return QuizQuestion(
                question: "What is \(binA) + \(binB) in binary?",
                correctAnswer: correct, options: opts,
                explanation: "\(binA) is \(a), \(binB) is \(b). \(a) + \(b) = \(sum) = \(correct) in binary.",
                category: .binaryDecimal)
        }
    }
    
    // MARK: - Decimal ↔ Hex (expanded)
    
    private func genDecimalHex(_ d: Difficulty) -> QuizQuestion {
        let maxVal = d == .easy ? 31 : d == .medium ? 255 : 4095
        let num = Int.random(in: 1...maxVal)
        let variant = Int.random(in: 0...3)
        
        switch variant {
        case 0:
            let correct = String(num, radix: 16).uppercased()
            let opts = generateOptions(correct: correct) { String(Int.random(in: 1...maxVal), radix: 16).uppercased() }
            return QuizQuestion(
                question: "Convert decimal \(num) to hexadecimal.",
                correctAnswer: correct, options: opts,
                explanation: "Divide \(num) by 16 repeatedly. \(num) in hex is \(correct).",
                category: .decimalHex)
        case 1:
            let hex = String(num, radix: 16).uppercased()
            let correct = "\(num)"
            let opts = generateOptions(correct: correct) { "\(Int.random(in: 1...maxVal))" }
            return QuizQuestion(
                question: "What is hex \(hex) in decimal?",
                correctAnswer: correct, options: opts,
                explanation: "Multiply each hex digit by its power of 16. Hex \(hex) = \(num).",
                category: .decimalHex)
        case 2:
            let hexDigits = ["A", "B", "C", "D", "E", "F"]
            let digit = hexDigits.randomElement()!
            let val = 10 + hexDigits.firstIndex(of: digit)!
            let correct = "\(val)"
            let opts = generateOptions(correct: correct) { "\(Int.random(in: 8...17))" }
            return QuizQuestion(
                question: "What decimal value does hex digit '\(digit)' represent?",
                correctAnswer: correct, options: opts,
                explanation: "In hexadecimal: A=10, B=11, C=12, D=13, E=14, F=15. So '\(digit)' = \(val).",
                category: .decimalHex)
        default:
            let correct = String(num, radix: 16).uppercased()
            let digitCount = correct.count
            let opts = generateOptions(correct: "\(digitCount)") { "\(Int.random(in: 1...digitCount+2))" }
            return QuizQuestion(
                question: "How many hex digits are needed to represent decimal \(num)?",
                correctAnswer: "\(digitCount)", options: opts,
                explanation: "\(num) in hex is \(correct), which has \(digitCount) digit(s).",
                category: .decimalHex)
        }
    }
    
    // MARK: - Decimal ↔ Octal (expanded)
    
    private func genDecimalOctal(_ d: Difficulty) -> QuizQuestion {
        let maxVal = d == .easy ? 31 : d == .medium ? 127 : 511
        let num = Int.random(in: 1...maxVal)
        let variant = Int.random(in: 0...2)
        
        switch variant {
        case 0:
            let correct = String(num, radix: 8)
            let opts = generateOptions(correct: correct) { String(Int.random(in: 1...maxVal), radix: 8) }
            return QuizQuestion(
                question: "Convert decimal \(num) to octal.",
                correctAnswer: correct, options: opts,
                explanation: "Divide \(num) by 8 repeatedly. \(num) in octal is \(correct).",
                category: .decimalOctal)
        case 1:
            let octal = String(num, radix: 8)
            let correct = "\(num)"
            let opts = generateOptions(correct: correct) { "\(Int.random(in: 1...maxVal))" }
            return QuizQuestion(
                question: "What is octal \(octal) in decimal?",
                correctAnswer: correct, options: opts,
                explanation: "Multiply each octal digit by its power of 8. Octal \(octal) = \(num).",
                category: .decimalOctal)
        default:
            let correct = "8"
            let opts = ["2", "8", "10", "16"].shuffled()
            return QuizQuestion(
                question: "What is the base of the octal number system?",
                correctAnswer: correct, options: opts,
                explanation: "Octal uses base 8, meaning it has digits 0 through 7.",
                category: .decimalOctal)
        }
    }
    
    // MARK: - Hex ↔ Binary (expanded)
    
    private func genHexBinary(_ d: Difficulty) -> QuizQuestion {
        let maxVal = d == .easy ? 15 : d == .medium ? 255 : 4095
        let num = Int.random(in: 1...maxVal)
        let variant = Int.random(in: 0...2)
        
        switch variant {
        case 0:
            let hex = String(num, radix: 16).uppercased()
            let correct = String(num, radix: 2)
            let opts = generateOptions(correct: correct) { String(Int.random(in: 1...maxVal), radix: 2) }
            return QuizQuestion(
                question: "Convert hex \(hex) to binary.",
                correctAnswer: correct, options: opts,
                explanation: "Convert each hex digit to 4 binary bits. Hex \(hex) = \(correct) in binary.",
                category: .hexBinary)
        case 1:
            let binary = String(num, radix: 2)
            let correct = String(num, radix: 16).uppercased()
            let opts = generateOptions(correct: correct) { String(Int.random(in: 1...maxVal), radix: 16).uppercased() }
            return QuizQuestion(
                question: "Convert binary \(binary) to hexadecimal.",
                correctAnswer: correct, options: opts,
                explanation: "Group binary digits in sets of 4 from right. \(binary) = \(correct) in hex.",
                category: .hexBinary)
        default:
            let hexDigit = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"].randomElement()!
            let val = Int(hexDigit, radix: 16)!
            let bin4 = String(repeating: "0", count: 4 - String(val, radix: 2).count) + String(val, radix: 2)
            let correct = bin4
            let opts = generateOptions(correct: correct) {
                let r = Int.random(in: 0...15)
                return String(repeating: "0", count: 4 - String(r, radix: 2).count) + String(r, radix: 2)
            }
            return QuizQuestion(
                question: "What is the 4-bit binary for hex digit '\(hexDigit)'?",
                correctAnswer: correct, options: opts,
                explanation: "Hex \(hexDigit) = decimal \(val) = binary \(bin4) (always 4 bits per hex digit).",
                category: .hexBinary)
        }
    }
    
    // MARK: - IP Addressing (expanded)
    
    private func genIPQuestion(_ d: Difficulty) -> QuizQuestion {
        let pool: [(String, String, String, [String])] = [
            ("What class is IP address 10.0.0.1?", "Class A", "Class A ranges from 1.0.0.0 to 126.255.255.255. The first octet 10 falls in this range.", ["Class A", "Class B", "Class C", "Class D"]),
            ("What class is IP address 172.16.0.1?", "Class B", "Class B ranges from 128.0.0.0 to 191.255.255.255. First octet 172 is in this range.", ["Class A", "Class B", "Class C", "Class D"]),
            ("What class is IP address 192.168.1.1?", "Class C", "Class C ranges from 192.0.0.0 to 223.255.255.255.", ["Class A", "Class B", "Class C", "Class D"]),
            ("What is the IPv4 loopback address?", "127.0.0.1", "127.0.0.1 is the loopback address — it always refers to the local device itself.", ["127.0.0.1", "192.168.0.1", "10.0.0.1", "0.0.0.0"]),
            ("How many bits are in an IPv4 address?", "32", "IPv4 addresses have 4 octets × 8 bits = 32 bits total.", ["16", "32", "64", "128"]),
            ("What is the broadcast address for 192.168.1.0/24?", "192.168.1.255", "In a /24 network, the last octet is all 1s for broadcast = .255.", ["192.168.1.255", "192.168.1.0", "192.168.1.1", "192.168.0.255"]),
            ("Which IP range is reserved for private Class A networks?", "10.0.0.0/8", "RFC 1918 reserves 10.0.0.0/8 for private Class A use.", ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16", "224.0.0.0/4"]),
            ("What does the first octet of 224.0.0.1 indicate?", "Multicast", "Addresses 224.0.0.0–239.255.255.255 are Class D, used for multicast.", ["Multicast", "Broadcast", "Loopback", "Private"]),
            ("How many octets are in an IPv4 address?", "4", "IPv4 has 4 octets separated by dots (e.g., 192.168.1.1).", ["2", "4", "6", "8"]),
            ("What is the maximum value of a single IPv4 octet?", "255", "Each octet is 8 bits, so max value is 2⁸ - 1 = 255.", ["128", "255", "256", "512"]),
            ("Which address means 'this network'?", "0.0.0.0", "0.0.0.0 represents the default route or 'this network' in routing.", ["0.0.0.0", "127.0.0.1", "255.255.255.255", "10.0.0.0"]),
            ("What is 255.255.255.255 used for?", "Limited broadcast", "255.255.255.255 is the limited broadcast address — sent to all hosts on the local network.", ["Limited broadcast", "Loopback", "Default gateway", "Multicast"]),
            ("How many total IPv4 addresses exist?", "~4.3 billion", "2³² = 4,294,967,296 ≈ 4.3 billion unique addresses.", ["~4.3 billion", "~1 billion", "~16 million", "~65 thousand"]),
            ("What type of address is 169.254.x.x?", "Link-local (APIPA)", "169.254.0.0/16 is assigned automatically when DHCP fails (APIPA).", ["Link-local (APIPA)", "Multicast", "Private Class B", "Loopback"]),
            ("Which private range does 192.168.0.0 belong to?", "Class C private", "192.168.0.0/16 is the Class C private address range per RFC 1918.", ["Class A private", "Class B private", "Class C private", "Public"]),
        ]
        let q = pool.randomElement()!
        return QuizQuestion(question: q.0, correctAnswer: q.1, options: q.3.shuffled(), explanation: q.2, category: .ipAddressing)
    }
    
    // MARK: - Subnetting (expanded)
    
    private func genSubnetQuestion(_ d: Difficulty) -> QuizQuestion {
        let pool: [(String, String, String, [String])] = [
            ("How many usable hosts in a /24 network?", "254", "/24 gives 256 addresses. Subtract 2 (network + broadcast) = 254 usable hosts.", ["254", "256", "128", "252"]),
            ("What subnet mask does /16 represent?", "255.255.0.0", "/16 means the first 16 bits are 1s → 255.255.0.0.", ["255.255.0.0", "255.0.0.0", "255.255.255.0", "255.255.128.0"]),
            ("What CIDR notation equals 255.255.255.0?", "/24", "255.255.255.0 has 24 consecutive 1-bits → /24.", ["/24", "/16", "/8", "/32"]),
            ("How many subnets can you create with /26 from a /24?", "4", "/26 borrows 2 bits from the host portion of /24. 2² = 4 subnets.", ["2", "4", "8", "16"]),
            ("What is the network address of 192.168.1.130/25?", "192.168.1.128", "/25 splits at 128. Since 130 ≥ 128, the network address is 192.168.1.128.", ["192.168.1.128", "192.168.1.0", "192.168.1.64", "192.168.1.192"]),
            ("What subnet mask does /28 represent?", "255.255.255.240", "/28 = 11111111.11111111.11111111.11110000 = 255.255.255.240.", ["255.255.255.240", "255.255.255.224", "255.255.255.248", "255.255.255.192"]),
            ("How many usable hosts in a /30 network?", "2", "/30 gives 4 addresses - 2 = 2 usable hosts. Often used for point-to-point links.", ["2", "4", "6", "1"]),
            ("What is the broadcast address of 10.0.0.0/8?", "10.255.255.255", "In a /8 network, the last 3 octets are all 1s for broadcast.", ["10.255.255.255", "10.0.0.255", "10.0.255.255", "10.255.0.0"]),
            ("How many bits are borrowed for subnetting in /27?", "3", "/27 uses 27 bits for network. From a /24 base, that's 3 extra bits borrowed.", ["2", "3", "4", "5"]),
            ("What is the block size for a /26 subnet?", "64", "/26 leaves 6 host bits. 2⁶ = 64 addresses per subnet block.", ["32", "64", "128", "16"]),
            ("What CIDR notation equals 255.255.255.128?", "/25", "255.255.255.128 = 25 consecutive 1-bits → /25.", ["/24", "/25", "/26", "/27"]),
            ("How many /28 subnets fit in a /24 network?", "16", "/28 borrows 4 bits from /24. 2⁴ = 16 subnets.", ["4", "8", "16", "32"]),
            ("What is the wildcard mask for /24?", "0.0.0.255", "Wildcard = 255.255.255.255 - subnet mask. For /24: 255 - 255 = 0 for first 3, 255 - 0 = 255.", ["0.0.0.255", "0.0.255.255", "0.255.255.255", "0.0.0.127"]),
        ]
        let q = pool.randomElement()!
        return QuizQuestion(question: q.0, correctAnswer: q.1, options: q.3.shuffled(), explanation: q.2, category: .subnetting)
    }
    
    // MARK: - Protocols (expanded)
    
    private func genProtocolQuestion(_ d: Difficulty) -> QuizQuestion {
        let pool: [(String, String, String, [String])] = [
            ("What protocol resolves IP addresses to MAC addresses?", "ARP", "ARP (Address Resolution Protocol) broadcasts a request to find the MAC address for a given IP.", ["ARP", "DNS", "DHCP", "ICMP"]),
            ("What protocol does the 'ping' command use?", "ICMP", "Ping sends ICMP Echo Request packets and waits for Echo Reply.", ["ICMP", "TCP", "UDP", "ARP"]),
            ("At which OSI layer does a router operate?", "Layer 3", "Routers make forwarding decisions using IP addresses at the Network layer (Layer 3).", ["Layer 1", "Layer 2", "Layer 3", "Layer 4"]),
            ("At which OSI layer does a switch operate?", "Layer 2", "Switches forward frames using MAC addresses at the Data Link layer (Layer 2).", ["Layer 1", "Layer 2", "Layer 3", "Layer 4"]),
            ("What does DHCP automatically provide to devices?", "IP addresses", "DHCP (Dynamic Host Configuration Protocol) assigns IP addresses, subnet masks, gateways, and DNS.", ["IP addresses", "MAC addresses", "Domain names", "Encryption keys"]),
            ("What is the default port for HTTP?", "80", "HTTP uses TCP port 80 by default. HTTPS uses port 443.", ["80", "443", "21", "25"]),
            ("What does DNS translate?", "Domain names to IPs", "DNS resolves human-readable domain names (like google.com) into IP addresses.", ["Domain names to IPs", "IPs to MACs", "MACs to IPs", "Ports to IPs"]),
            ("What transport protocol does HTTP typically use?", "TCP", "HTTP runs over TCP to ensure reliable, ordered delivery of web content.", ["TCP", "UDP", "ICMP", "ARP"]),
            ("What is the default port for HTTPS?", "443", "HTTPS uses TCP port 443 for encrypted web traffic.", ["80", "443", "8080", "22"]),
            ("What protocol is used for secure remote shell access?", "SSH", "SSH (Secure Shell) provides encrypted remote terminal access on port 22.", ["SSH", "Telnet", "FTP", "HTTP"]),
            ("What does NAT stand for?", "Network Address Translation", "NAT translates private IPs to public IPs, allowing multiple devices to share one public address.", ["Network Address Translation", "Network Access Token", "Node Address Table", "Network Allocation Type"]),
            ("Which protocol sends email?", "SMTP", "SMTP (Simple Mail Transfer Protocol) is used to send emails between servers.", ["SMTP", "POP3", "IMAP", "HTTP"]),
            ("What does TCP guarantee that UDP does not?", "Reliable delivery", "TCP uses acknowledgments and retransmissions to guarantee data arrives correctly and in order.", ["Reliable delivery", "Faster speed", "Less overhead", "Broadcast support"]),
            ("What layer of the OSI model does TCP operate at?", "Layer 4", "TCP operates at the Transport layer (Layer 4) of the OSI model.", ["Layer 2", "Layer 3", "Layer 4", "Layer 5"]),
            ("What is the purpose of a default gateway?", "Route to other networks", "The default gateway is the router that forwards traffic destined for networks outside the local subnet.", ["Route to other networks", "Assign IP addresses", "Resolve DNS", "Filter packets"]),
            ("What does a firewall primarily do?", "Filter network traffic", "Firewalls inspect and filter traffic based on security rules to protect networks.", ["Filter network traffic", "Assign IPs", "Route packets", "Resolve domains"]),
            ("What protocol does traceroute primarily use?", "ICMP", "Traceroute uses ICMP Time Exceeded messages (or UDP on some systems) to map the path packets take.", ["ICMP", "TCP", "ARP", "DNS"]),
            ("What is the purpose of a VLAN?", "Segment a network logically", "VLANs divide a physical switch into separate logical networks for security and traffic management.", ["Segment a network logically", "Encrypt traffic", "Assign IP addresses", "Speed up routing"]),
            ("What does the TTL field in an IP packet prevent?", "Infinite routing loops", "TTL (Time To Live) decrements at each hop. When it reaches 0, the packet is discarded.", ["Infinite routing loops", "Packet encryption", "MAC spoofing", "DNS poisoning"]),
            ("Which protocol automatically assigns IP addresses on a network?", "DHCP", "DHCP uses a 4-step process: Discover, Offer, Request, Acknowledge (DORA).", ["DHCP", "DNS", "ARP", "ICMP"]),
        ]
        let q = pool.randomElement()!
        return QuizQuestion(question: q.0, correctAnswer: q.1, options: q.3.shuffled(), explanation: q.2, category: .protocols)
    }

    // MARK: - Daily Challenge (distinct from mixed)

    private func genDailyChallengeQuestion(_ d: Difficulty, index: Int) -> QuizQuestion {
        // Daily challenge uses a seeded rotation so each day feels unique.
        // It focuses on tricky, scenario-based questions that mix concepts.
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let seed = (dayOfYear + index) % dailyPool.count
        return dailyPool[seed]
    }

    private var dailyPool: [QuizQuestion] {
        [
            QuizQuestion(
                question: "A device has IP 192.168.1.50/26. What is its broadcast address?",
                correctAnswer: "192.168.1.63",
                options: ["192.168.1.63", "192.168.1.127", "192.168.1.255", "192.168.1.31"],
                explanation: "/26 gives blocks of 64. 50 falls in the 0–63 block, so broadcast is .63.",
                category: .dailyChallenge),
            QuizQuestion(
                question: "Convert the IP octet 192 to binary.",
                correctAnswer: "11000000",
                options: ["11000000", "10000000", "11100000", "11001000"],
                explanation: "192 = 128 + 64 = 11000000 in binary.",
                category: .dailyChallenge),
            QuizQuestion(
                question: "If a MAC address starts with FF:FF:FF:FF:FF:FF, what type of frame is it?",
                correctAnswer: "Broadcast",
                options: ["Broadcast", "Unicast", "Multicast", "Anycast"],
                explanation: "FF:FF:FF:FF:FF:FF is the broadcast MAC — the frame goes to all devices on the LAN.",
                category: .dailyChallenge),
            QuizQuestion(
                question: "What is binary 11111111 in hexadecimal?",
                correctAnswer: "FF",
                options: ["FF", "FE", "F0", "1F"],
                explanation: "11111111 = 255 in decimal = FF in hex (F=15, so 15×16 + 15 = 255).",
                category: .dailyChallenge),
            QuizQuestion(
                question: "How many usable host addresses are in a /29 subnet?",
                correctAnswer: "6",
                options: ["6", "8", "4", "2"],
                explanation: "/29 = 8 total addresses - 2 (network + broadcast) = 6 usable hosts.",
                category: .dailyChallenge),
            QuizQuestion(
                question: "A switch receives a frame for an unknown MAC. What does it do?",
                correctAnswer: "Floods all ports except source",
                options: ["Floods all ports except source", "Drops the frame", "Sends to default gateway", "Sends ARP request"],
                explanation: "When a switch doesn't know the destination MAC, it floods the frame out all ports except the one it arrived on.",
                category: .dailyChallenge),
            QuizQuestion(
                question: "What is decimal 200 in octal?",
                correctAnswer: "310",
                options: ["310", "300", "250", "308"],
                explanation: "200 ÷ 8 = 25 r0, 25 ÷ 8 = 3 r1, 3 ÷ 8 = 0 r3. Read remainders: 310.",
                category: .dailyChallenge),
            QuizQuestion(
                question: "Which OSI layer handles encryption and data formatting?",
                correctAnswer: "Layer 6 (Presentation)",
                options: ["Layer 6 (Presentation)", "Layer 5 (Session)", "Layer 7 (Application)", "Layer 4 (Transport)"],
                explanation: "The Presentation layer (Layer 6) handles encryption, compression, and data translation.",
                category: .dailyChallenge),
            QuizQuestion(
                question: "What hex value represents decimal 100?",
                correctAnswer: "64",
                options: ["64", "A0", "6E", "46"],
                explanation: "100 ÷ 16 = 6 remainder 4. So 100 decimal = 64 hex.",
                category: .dailyChallenge),
            QuizQuestion(
                question: "Two devices are on the same /24 subnet. Do they need a router to communicate?",
                correctAnswer: "No",
                options: ["No", "Yes", "Only with VLAN", "Only with NAT"],
                explanation: "Devices on the same subnet communicate directly via Layer 2 (switch/MAC) — no router needed.",
                category: .dailyChallenge),
            QuizQuestion(
                question: "What binary number is equivalent to octal 17?",
                correctAnswer: "001111",
                options: ["001111", "010111", "011100", "111000"],
                explanation: "Octal 1 = 001, Octal 7 = 111. Combined: 001111. (Octal 17 = decimal 15 = binary 1111.)",
                category: .dailyChallenge),
            QuizQuestion(
                question: "A ping returns 'TTL expired'. What happened?",
                correctAnswer: "Packet hopped too many routers",
                options: ["Packet hopped too many routers", "Destination is down", "Firewall blocked it", "DNS failed"],
                explanation: "TTL expired means the packet's Time To Live reached 0 before arriving — too many router hops.",
                category: .dailyChallenge),
            QuizQuestion(
                question: "What is the network address of 10.10.10.200/28?",
                correctAnswer: "10.10.10.192",
                options: ["10.10.10.192", "10.10.10.200", "10.10.10.208", "10.10.10.176"],
                explanation: "/28 = blocks of 16. 200 ÷ 16 = 12.5, so block starts at 12 × 16 = 192.",
                category: .dailyChallenge),
            QuizQuestion(
                question: "In the DHCP process, what does the 'D' in DORA stand for?",
                correctAnswer: "Discover",
                options: ["Discover", "Distribute", "Delegate", "Decode"],
                explanation: "DORA = Discover, Offer, Request, Acknowledge. The client first broadcasts a Discover message.",
                category: .dailyChallenge),
            QuizQuestion(
                question: "What is hex 'B' + hex '5' in hexadecimal?",
                correctAnswer: "10",
                options: ["10", "F", "G", "15"],
                explanation: "B=11, 5=5. 11+5=16 decimal = 10 in hex (1×16 + 0).",
                category: .dailyChallenge),
            QuizQuestion(
                question: "Which protocol uses a 3-way handshake to establish connections?",
                correctAnswer: "TCP",
                options: ["TCP", "UDP", "ICMP", "ARP"],
                explanation: "TCP uses SYN → SYN-ACK → ACK (3-way handshake) before data transfer begins.",
                category: .dailyChallenge),
            QuizQuestion(
                question: "What is the binary representation of subnet mask 255.255.255.192?",
                correctAnswer: "26 ones followed by 6 zeros",
                options: ["26 ones followed by 6 zeros", "24 ones followed by 8 zeros", "28 ones followed by 4 zeros", "25 ones followed by 7 zeros"],
                explanation: "255.255.255.192 = /26. That's 26 bits set to 1, then 6 bits of 0.",
                category: .dailyChallenge),
            QuizQuestion(
                question: "Convert binary 10101010 to decimal.",
                correctAnswer: "170",
                options: ["170", "180", "160", "85"],
                explanation: "10101010 = 128+32+8+2 = 170.",
                category: .dailyChallenge),
            QuizQuestion(
                question: "What happens when you ping a broadcast address?",
                correctAnswer: "All hosts on the subnet may reply",
                options: ["All hosts on the subnet may reply", "Only the router replies", "The ping fails", "Only the server replies"],
                explanation: "Pinging a broadcast address sends ICMP to all hosts. Each may respond (though many block this).",
                category: .dailyChallenge),
            QuizQuestion(
                question: "What is the hex representation of binary 1010 1100?",
                correctAnswer: "AC",
                options: ["AC", "CA", "AB", "BC"],
                explanation: "1010 = A (10), 1100 = C (12). Combined: AC.",
                category: .dailyChallenge),
        ]
    }

    // MARK: - Option Generator

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
