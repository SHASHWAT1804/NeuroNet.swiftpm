import SwiftUI

struct SubnetCalculatorView: View {
    @State private var cidr: Double = 24
    @State private var ipAddress = "192.168.1.0"

    private var cidrInt: Int { Int(cidr) }
    private var subnetMask: String { NumberConverter.cidrToSubnetMask(cidrInt) ?? "N/A" }
    private var totalHosts: Int {
        cidrInt >= 31 ? (cidrInt == 32 ? 1 : 2) : Int(pow(2.0, Double(32 - cidrInt))) - 2
    }
    private var totalAddresses: Int { Int(pow(2.0, Double(32 - cidrInt))) }
    private var networkBits: Int { cidrInt }
    private var hostBits: Int { 32 - cidrInt }

    private var binaryMask: String {
        String(repeating: "1", count: cidrInt) + String(repeating: "0", count: 32 - cidrInt)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                Text("Subnet Calculator")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                // CIDR Slider
                GlassCard {
                    VStack(spacing: 12) {
                        HStack {
                            Text("CIDR Notation")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                            Spacer()
                            Text("/\(cidrInt)")
                                .font(.system(size: 22, weight: .bold, design: .monospaced))
                                .foregroundColor(Theme.electricBlue)
                        }
                        Slider(value: $cidr, in: 0...32, step: 1)
                            .tint(Theme.electricBlue)
                    }
                }

                // Results
                GradientCard(gradient: Theme.primaryGradient) {
                    VStack(spacing: 14) {
                        resultRow("Subnet Mask", subnetMask)
                        Divider().background(.white.opacity(0.3))
                        resultRow("Usable Hosts", "\(totalHosts)")
                        Divider().background(.white.opacity(0.3))
                        resultRow("Total Addresses", "\(totalAddresses)")
                        Divider().background(.white.opacity(0.3))
                        resultRow("Network Bits", "\(networkBits)")
                        Divider().background(.white.opacity(0.3))
                        resultRow("Host Bits", "\(hostBits)")
                    }
                }

                // Binary visualization
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Binary Subnet Mask")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        binaryVisualization
                    }
                }

                // IP binary
                if let ipBinary = NumberConverter.ipToBinary(ipAddress) {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("IP in Binary")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text(ipBinary)
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(Theme.mintGreen)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(Theme.backgroundGradient.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    private func resultRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
    }

    private var binaryVisualization: some View {
        VStack(spacing: 6) {
            // Show 4 octets
            ForEach(0..<4, id: \.self) { octet in
                HStack(spacing: 2) {
                    ForEach(0..<8, id: \.self) { bit in
                        let bitIndex = octet * 8 + bit
                        let isNetwork = bitIndex < cidrInt
                        Text(isNetwork ? "1" : "0")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(isNetwork ? Theme.electricBlue : Theme.coral.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    Text("= \(octetValue(octet))")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: 50, alignment: .leading)
                }
            }

            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Theme.electricBlue)
                        .frame(width: 12, height: 12)
                    Text("Network")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Theme.coral.opacity(0.5))
                        .frame(width: 12, height: 12)
                    Text("Host")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.top, 4)
        }
    }

    private func octetValue(_ octet: Int) -> Int {
        let start = octet * 8
        var value = 0
        for bit in 0..<8 {
            if start + bit < cidrInt {
                value += 1 << (7 - bit)
            }
        }
        return value
    }
}
