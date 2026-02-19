import Foundation

enum NumberConverter {
    static func decimalToBinary(_ decimal: Int) -> String {
        guard decimal >= 0 else { return "0" }
        return String(decimal, radix: 2)
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
        return String(dec, radix: 2)
    }

    static func stepsDecimalToBinary(_ decimal: Int) -> [(step: String, result: String)] {
        guard decimal > 0 else { return [("0 in binary is", "0")] }
        var steps: [(String, String)] = []
        var num = decimal
        var bits: [String] = []
        while num > 0 {
            let remainder = num % 2
            bits.insert("\(remainder)", at: 0)
            steps.append(("\(num) ÷ 2 = \(num/2) remainder \(remainder)", bits.joined()))
            num /= 2
        }
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
            steps.append(("\(num) ÷ 16 = \(num/16) remainder \(remainder) (\(hexChar))", digits.joined()))
            num /= 16
        }
        return steps
    }

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
        var mask: UInt32 = cidr == 0 ? 0 : (~UInt32(0)) << (32 - cidr)
        let octets = (0..<4).map { i -> String in
            let octet = (mask >> (24 - i * 8)) & 0xFF
            return "\(octet)"
        }
        return octets.joined(separator: ".")
    }
}
