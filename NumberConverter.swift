import Foundation

enum NumberConverter {
    // MARK: - Basic Conversions

    static func decimalToBinary(_ decimal: Int) -> String {
        guard decimal >= 0 else { return "0" }
        return decimal == 0 ? "0" : String(decimal, radix: 2)
    }

    static func binaryToDecimal(_ binary: String) -> Int? {
        Int(binary, radix: 2)
    }

    static func decimalToHex(_ decimal: Int) -> String {
        String(decimal, radix: 16).uppercased()
    }

    static func hexToDecimal(_ hex: String) -> Int? {
        Int(hex, radix: 16)
    }

    static func decimalToOctal(_ decimal: Int) -> String {
        String(decimal, radix: 8)
    }

    static func octalToDecimal(_ octal: String) -> Int? {
        Int(octal, radix: 8)
    }

    static func binaryToHex(_ binary: String) -> String? {
        guard let dec = Int(binary, radix: 2) else { return nil }
        return String(dec, radix: 16).uppercased()
    }

    static func hexToBinary(_ hex: String) -> String? {
        guard let dec = Int(hex, radix: 16) else { return nil }
        return dec == 0 ? "0" : String(dec, radix: 2)
    }

    // MARK: - Step-by-step for ALL conversions

    static func stepsDecimalToBinary(_ decimal: Int) -> [(step: String, result: String)] {
        guard decimal > 0 else { return [("0 in binary is", "0")] }
        var steps: [(String, String)] = []
        var num = decimal
        var bits: [String] = []
        while num > 0 {
            let remainder = num % 2
            bits.insert("\(remainder)", at: 0)
            steps.append(("\(num) ÷ 2 = \(num/2), remainder \(remainder)", bits.joined()))
            num /= 2
        }
        steps.append(("Read remainders bottom→top", bits.joined()))
        return steps
    }

    static func stepsBinaryToDecimal(_ binary: String) -> [(step: String, result: String)] {
        guard let _ = Int(binary, radix: 2) else { return [] }
        let chars = Array(binary)
        var steps: [(String, String)] = []
        var runningTotal = 0
        let bitCount = chars.count
        for (i, ch) in chars.enumerated() {
            let power = bitCount - 1 - i
            let bitVal = ch == "1" ? 1 : 0
            let contribution = bitVal * (1 << power)
            runningTotal += contribution
            if bitVal == 1 {
                steps.append(("Bit \(i): \(bitVal) × 2^\(power) = \(contribution)", "Running total: \(runningTotal)"))
            } else {
                steps.append(("Bit \(i): 0 × 2^\(power) = 0", "Running total: \(runningTotal)"))
            }
        }
        steps.append(("Sum all values", "\(runningTotal)"))
        return steps
    }

    static func stepsDecimalToHex(_ decimal: Int) -> [(step: String, result: String)] {
        guard decimal > 0 else { return [("0 in hex is", "0")] }
        var steps: [(String, String)] = []
        var num = decimal
        var digits: [String] = []
        let hexChars = "0123456789ABCDEF"
        while num > 0 {
            let remainder = num % 16
            let hexChar = String(hexChars[hexChars.index(hexChars.startIndex, offsetBy: remainder)])
            digits.insert(hexChar, at: 0)
            steps.append(("\(num) ÷ 16 = \(num/16), remainder \(remainder) → '\(hexChar)'", digits.joined()))
            num /= 16
        }
        steps.append(("Read remainders bottom→top", digits.joined()))
        return steps
    }

    static func stepsHexToDecimal(_ hex: String) -> [(step: String, result: String)] {
        guard let _ = Int(hex, radix: 16) else { return [] }
        let chars = Array(hex.uppercased())
        var steps: [(String, String)] = []
        var runningTotal = 0
        let digitCount = chars.count
        for (i, ch) in chars.enumerated() {
            let power = digitCount - 1 - i
            let digitVal = hexDigitValue(ch)
            let contribution = digitVal * pow16(power)
            runningTotal += contribution
            steps.append(("'\(ch)' (\(digitVal)) × 16^\(power) = \(contribution)", "Running total: \(runningTotal)"))
        }
        steps.append(("Sum all values", "\(runningTotal)"))
        return steps
    }

    static func stepsDecimalToOctal(_ decimal: Int) -> [(step: String, result: String)] {
        guard decimal > 0 else { return [("0 in octal is", "0")] }
        var steps: [(String, String)] = []
        var num = decimal
        var digits: [String] = []
        while num > 0 {
            let remainder = num % 8
            digits.insert("\(remainder)", at: 0)
            steps.append(("\(num) ÷ 8 = \(num/8), remainder \(remainder)", digits.joined()))
            num /= 8
        }
        steps.append(("Read remainders bottom→top", digits.joined()))
        return steps
    }

    static func stepsOctalToDecimal(_ octal: String) -> [(step: String, result: String)] {
        guard let _ = Int(octal, radix: 8) else { return [] }
        let chars = Array(octal)
        var steps: [(String, String)] = []
        var runningTotal = 0
        let digitCount = chars.count
        for (i, ch) in chars.enumerated() {
            let power = digitCount - 1 - i
            let digitVal = Int(String(ch)) ?? 0
            let contribution = digitVal * pow8(power)
            runningTotal += contribution
            steps.append(("\(digitVal) × 8^\(power) = \(contribution)", "Running total: \(runningTotal)"))
        }
        steps.append(("Sum all values", "\(runningTotal)"))
        return steps
    }

    static func stepsHexToBinary(_ hex: String) -> [(step: String, result: String)] {
        guard let dec = Int(hex.uppercased(), radix: 16) else { return [] }
        var steps: [(String, String)] = []
        let chars = Array(hex.uppercased())
        var fullBinary = ""
        for ch in chars {
            let val = hexDigitValue(ch)
            let bin4 = String(repeating: "0", count: 4 - String(val, radix: 2).count) + String(val, radix: 2)
            fullBinary += bin4
            steps.append(("Hex '\(ch)' → 4-bit binary: \(bin4)", fullBinary))
        }
        // Trim leading zeros
        let trimmed = String(dec, radix: 2)
        steps.append(("Combine all groups (trim leading 0s)", trimmed))
        return steps
    }

    static func stepsBinaryToHex(_ binary: String) -> [(step: String, result: String)] {
        guard let _ = Int(binary, radix: 2) else { return [] }
        // Pad to multiple of 4
        var padded = binary
        while padded.count % 4 != 0 { padded = "0" + padded }
        var steps: [(String, String)] = []
        steps.append(("Pad to groups of 4: \(padded)", padded))
        let hexChars = "0123456789ABCDEF"
        var hexResult = ""
        var i = padded.startIndex
        while i < padded.endIndex {
            let end = padded.index(i, offsetBy: 4)
            let group = String(padded[i..<end])
            let val = Int(group, radix: 2) ?? 0
            let hexChar = String(hexChars[hexChars.index(hexChars.startIndex, offsetBy: val)])
            hexResult += hexChar
            steps.append(("Group '\(group)' = \(val) → '\(hexChar)'", hexResult))
            i = end
        }
        return steps
    }

    // MARK: - Example hints per mode

    static func exampleHint(for mode: String) -> (input: String, output: String) {
        switch mode {
        case "Dec → Bin": return ("42", "101010")
        case "Bin → Dec": return ("1101", "13")
        case "Dec → Hex": return ("255", "FF")
        case "Hex → Dec": return ("1A", "26")
        case "Dec → Oct": return ("100", "144")
        case "Oct → Dec": return ("77", "63")
        case "Hex → Bin": return ("3F", "111111")
        case "Bin → Hex": return ("11010110", "D6")
        default: return ("10", "10")
        }
    }

    // MARK: - IP Utilities

    static func ipToBinary(_ ip: String) -> String? {
        let octets = ip.split(separator: ".").compactMap { Int($0) }
        guard octets.count == 4, octets.allSatisfy({ $0 >= 0 && $0 <= 255 }) else { return nil }
        return octets.map { octet in
            let binary = String(octet, radix: 2)
            return String(repeating: "0", count: 8 - binary.count) + binary
        }.joined(separator: ".")
    }

    static func cidrToSubnetMask(_ cidr: Int) -> String? {
        guard cidr >= 0 && cidr <= 32 else { return nil }
        let mask: UInt32 = cidr == 0 ? 0 : (~UInt32(0)) << (32 - cidr)
        let octets = (0..<4).map { i -> String in
            let octet = (mask >> (24 - i * 8)) & 0xFF
            return "\(octet)"
        }
        return octets.joined(separator: ".")
    }

    // MARK: - Helpers

    private static func hexDigitValue(_ ch: Character) -> Int {
        switch ch {
        case "0"..."9": return Int(String(ch))!
        case "A": return 10; case "B": return 11; case "C": return 12
        case "D": return 13; case "E": return 14; case "F": return 15
        default: return 0
        }
    }

    private static func pow16(_ exp: Int) -> Int {
        var result = 1; for _ in 0..<exp { result *= 16 }; return result
    }

    private static func pow8(_ exp: Int) -> Int {
        var result = 1; for _ in 0..<exp { result *= 8 }; return result
    }
}
