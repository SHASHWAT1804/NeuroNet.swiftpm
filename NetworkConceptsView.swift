import SwiftUI

struct NetworkConceptsView: View {
    @State private var selectedConcept: NetworkConcept?

    enum NetworkConcept: String, CaseIterable, Identifiable {
        case ip = "IP Address"
        case mac = "MAC Address"
        case subnet = "Subnet Mask"
        case cidr = "CIDR Notation"
        case router = "Router"
        case switchDevice = "Switch"
        case firewall = "Firewall"
        case vlan = "VLAN"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .ip: return "number.circle"
            case .mac: return "barcode"
            case .subnet: return "square.grid.3x3"
            case .cidr: return "slash.circle"
            case .router: return "wifi.router.fill"
            case .switchDevice: return "arrow.triangle.branch"
            case .firewall: return "flame.fill"
            case .vlan: return "rectangle.split.3x1"
            }
        }

        var color: Color {
            switch self {
            case .ip: return Theme.electricBlue
            case .mac: return Theme.neonPurple
            case .subnet: return Theme.mintGreen
            case .cidr: return Theme.softYellow
            case .router: return Theme.coral
            case .switchDevice: return .cyan
            case .firewall: return .orange
            case .vlan: return .pink
            }
        }

        var explanation: String {
            switch self {
            case .ip: return "An IP address is like a home address for your device on a network. It has 4 numbers (0-255) separated by dots.\n\nExample: 192.168.1.100\n\nThere are two types:\n• Private IPs: Used inside your home network\n• Public IPs: Used on the internet\n\nIPv4 uses 32 bits (4 bytes), giving about 4.3 billion unique addresses."
            case .mac: return "A MAC address is a unique hardware identifier burned into every network device. It's like a serial number.\n\nFormat: AA:BB:CC:DD:EE:FF\n\nIt has 6 pairs of hexadecimal digits (48 bits total).\n\nThe first 3 pairs identify the manufacturer, the last 3 are unique to the device."
            case .subnet: return "A subnet mask determines which part of an IP address is the network portion and which is the host portion.\n\nCommon masks:\n• 255.255.255.0 (/24) — 254 hosts\n• 255.255.0.0 (/16) — 65,534 hosts\n• 255.0.0.0 (/8) — 16 million hosts\n\nThe 1-bits mark the network, 0-bits mark the host."
            case .cidr: return "CIDR (Classless Inter-Domain Routing) is a compact way to write subnet masks.\n\nThe number after / tells how many bits are for the network.\n\n/24 = 255.255.255.0 (24 ones)\n/16 = 255.255.0.0 (16 ones)\n/8 = 255.0.0.0 (8 ones)\n\nSmaller CIDR = more hosts, larger CIDR = fewer hosts."
            case .router: return "A router connects different networks together and forwards data packets between them.\n\nIt works at Layer 3 (Network Layer) of the OSI model.\n\nKey functions:\n• Routes packets using IP addresses\n• Connects your home to the internet\n• Assigns IP addresses via DHCP\n• Provides NAT (Network Address Translation)"
            case .switchDevice: return "A switch connects devices within the same network and forwards data using MAC addresses.\n\nIt works at Layer 2 (Data Link Layer).\n\nKey features:\n• Learns MAC addresses automatically\n• Forwards frames only to the correct port\n• Much faster than a hub\n• Creates separate collision domains"
            case .firewall: return "A firewall monitors and controls network traffic based on security rules.\n\nIt acts as a barrier between trusted and untrusted networks.\n\nTypes:\n• Packet filtering: Checks headers\n• Stateful: Tracks connections\n• Application: Inspects content\n\nRules define what traffic is allowed or blocked."
            case .vlan: return "A VLAN (Virtual LAN) divides one physical switch into multiple logical networks.\n\nBenefits:\n• Separates traffic (e.g., students vs teachers)\n• Improves security\n• Reduces broadcast traffic\n• No extra hardware needed\n\nDevices in different VLANs need a router to communicate."
            }
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                Text("Network Concepts")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 10)

                ForEach(NetworkConcept.allCases) { concept in
                    Button(action: {
                        withAnimation(.spring()) {
                            selectedConcept = selectedConcept == concept ? nil : concept
                        }
                    }) {
                        VStack(spacing: 0) {
                            HStack(spacing: 14) {
                                Image(systemName: concept.icon)
                                    .font(.system(size: 22))
                                    .foregroundColor(concept.color)
                                    .frame(width: 44, height: 44)
                                    .background(concept.color.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                Text(concept.rawValue)
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: selectedConcept == concept ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.white.opacity(0.5))
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .padding(16)

                            if selectedConcept == concept {
                                Text(concept.explanation)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.85))
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.cardRadius)
                                .stroke(selectedConcept == concept ? concept.color.opacity(0.5) : .white.opacity(0.1), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(Theme.backgroundGradient.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}
