import SwiftUI

struct ProtocolVisualizerView: View {
    @State private var selectedProtocol: NetProtocol = .arp
    @State private var isAnimating = false
    @State private var animationStep = 0
    @State private var packetProgress: CGFloat = 0

    enum NetProtocol: String, CaseIterable {
        case arp = "ARP"
        case icmp = "ICMP (Ping)"
        case dns = "DNS"

        var description: String {
            switch self {
            case .arp: return "Address Resolution Protocol maps IP addresses to MAC addresses"
            case .icmp: return "Internet Control Message Protocol is used for ping and error reporting"
            case .dns: return "Domain Name System translates domain names to IP addresses"
            }
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                Text("Protocol Visualizer")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                // Protocol picker
                HStack(spacing: 8) {
                    ForEach(NetProtocol.allCases, id: \.self) { proto in
                        Button(action: {
                            withAnimation { selectedProtocol = proto }
                            resetAnimation()
                        }) {
                            Text(proto.rawValue)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(selectedProtocol == proto ? .white : .white.opacity(0.6))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(selectedProtocol == proto ? Theme.electricBlue : .white.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }

                Text(selectedProtocol.description)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)

                // Animation area
                protocolAnimation

                // Steps
                protocolSteps

                BouncyButton(isAnimating ? "Reset" : "Simulate",
                             icon: isAnimating ? "arrow.counterclockwise" : "play.fill") {
                    if isAnimating {
                        resetAnimation()
                    } else {
                        startAnimation()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(Theme.backgroundGradient.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    private var protocolAnimation: some View {
        GlassCard {
            ZStack {
                // Devices
                HStack {
                    deviceView(name: "Device A", ip: "192.168.1.10", icon: "desktopcomputer")
                    Spacer()
                    if selectedProtocol == .dns {
                        deviceView(name: "DNS Server", ip: "8.8.8.8", icon: "server.rack")
                    } else {
                        deviceView(name: "Device B", ip: "192.168.1.20", icon: "desktopcomputer")
                    }
                }

                // Packet animation
                if isAnimating {
                    packetView
                        .offset(x: packetOffset)
                        .transition(.scale)
                }
            }
            .frame(height: 120)
        }
    }

    private var packetView: some View {
        VStack(spacing: 2) {
            Image(systemName: "envelope.fill")
                .font(.system(size: 20))
                .foregroundColor(packetColor)
            Text(packetLabel)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(packetColor)
        }
        .padding(6)
        .background(packetColor.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var packetColor: Color {
        switch animationStep {
        case 0, 1: return Theme.electricBlue
        case 2, 3: return Theme.mintGreen
        default: return Theme.softYellow
        }
    }

    private var packetLabel: String {
        switch selectedProtocol {
        case .arp: return animationStep <= 1 ? "ARP Request" : "ARP Reply"
        case .icmp: return animationStep <= 1 ? "Echo Request" : "Echo Reply"
        case .dns: return animationStep <= 1 ? "DNS Query" : "DNS Response"
        }
    }

    private var packetOffset: CGFloat {
        let maxOffset: CGFloat = 80
        if animationStep <= 1 {
            return -maxOffset + packetProgress * maxOffset * 2
        } else {
            return maxOffset - packetProgress * maxOffset * 2
        }
    }

    private func deviceView(name: String, ip: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(.white)
            Text(name)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(ip)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.6))
        }
    }

    private var protocolSteps: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(stepsForProtocol.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    Circle()
                        .fill(index <= animationStep && isAnimating ? Theme.mintGreen : .white.opacity(0.2))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Text("\(index + 1)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        )
                    Text(step)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(index <= animationStep && isAnimating ? .white : .white.opacity(0.5))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.smallRadius))
    }

    private var stepsForProtocol: [String] {
        switch selectedProtocol {
        case .arp:
            return [
                "Device A broadcasts: \"Who has 192.168.1.20?\"",
                "All devices on network receive the ARP request",
                "Device B replies: \"192.168.1.20 is at AA:BB:CC:DD:EE:FF\"",
                "Device A updates its ARP table with the mapping"
            ]
        case .icmp:
            return [
                "Device A sends ICMP Echo Request to 192.168.1.20",
                "Packet travels through the network to Device B",
                "Device B sends ICMP Echo Reply back",
                "Device A receives reply — ping successful!"
            ]
        case .dns:
            return [
                "Device A asks DNS: \"What is the IP for example.com?\"",
                "DNS server looks up the domain in its records",
                "DNS replies: \"example.com is at 93.184.216.34\"",
                "Device A can now connect to the website"
            ]
        }
    }

    private func startAnimation() {
        isAnimating = true
        animationStep = 0
        animateStep()
    }

    private func animateStep() {
        packetProgress = 0
        withAnimation(.easeInOut(duration: 1.2)) {
            packetProgress = 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if animationStep < stepsForProtocol.count - 1 {
                animationStep += 1
                animateStep()
            }
        }
    }

    private func resetAnimation() {
        isAnimating = false
        animationStep = 0
        packetProgress = 0
    }
}
