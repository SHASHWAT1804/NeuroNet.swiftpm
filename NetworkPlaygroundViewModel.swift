import SwiftUI
import Combine

@MainActor
final class NetworkPlaygroundViewModel: ObservableObject {
    @Published var devices: [NetworkDevice] = []
    @Published var connections: [NetworkConnection] = []
    @Published var packets: [Packet] = []
    @Published var isSimulating = false
    @Published var simulationLog: [String] = []

    private var timer: AnyCancellable?

    func addDevice(_ type: NetworkDevice.DeviceType, at position: CGPoint) {
        let count = devices.filter { $0.type == type }.count
        let device = NetworkDevice(type: type, position: position,
                                   label: "\(type.rawValue) \(count + 1)")
        devices.append(device)
        simulationLog.append("Added \(device.label)")
    }

    func connectDevices(from: UUID, to: UUID) {
        guard from != to,
              !connections.contains(where: {
                  ($0.fromDeviceId == from && $0.toDeviceId == to) ||
                  ($0.fromDeviceId == to && $0.toDeviceId == from)
              }) else { return }
        let conn = NetworkConnection(fromDeviceId: from, toDeviceId: to)
        connections.append(conn)
        simulationLog.append("Connected devices")
    }

    func sendPacket(from sourceId: UUID, to destId: UUID) {
        guard let conn = connections.first(where: {
            ($0.fromDeviceId == sourceId && $0.toDeviceId == destId) ||
            ($0.fromDeviceId == destId && $0.toDeviceId == sourceId)
        }) else {
            simulationLog.append("⚠️ No connection between devices")
            return
        }

        let packet = Packet(
            sourceIP: "192.168.1.\(Int.random(in: 2...254))",
            destIP: "192.168.1.\(Int.random(in: 2...254))",
            sourceMAC: randomMAC(), destMAC: randomMAC(),
            protocol_: ["TCP", "UDP", "ICMP", "ARP"].randomElement()!,
            connectionId: conn.id
        )
        packets.append(packet)
        simulationLog.append("📦 Packet sent: \(packet.protocol_) \(packet.sourceIP) → \(packet.destIP)")
        animatePacket(packet.id)
    }

    private func animatePacket(_ packetId: UUID) {
        isSimulating = true
        timer?.cancel()
        var progress: CGFloat = 0
        timer = Timer.publish(every: 0.03, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                progress += 0.02
                if let idx = self.packets.firstIndex(where: { $0.id == packetId }) {
                    self.packets[idx].progress = progress
                }
                if progress >= 1.0 {
                    self.timer?.cancel()
                    self.isSimulating = false
                    self.simulationLog.append("✅ Packet delivered")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.packets.removeAll { $0.id == packetId }
                    }
                }
            }
    }

    func clearAll() {
        devices.removeAll()
        connections.removeAll()
        packets.removeAll()
        simulationLog.removeAll()
    }

    private func randomMAC() -> String {
        (0..<6).map { _ in String(format: "%02X", Int.random(in: 0...255)) }.joined(separator: ":")
    }
}
