import SwiftUI

struct NetworkSandboxView: View {
    @EnvironmentObject var networkVM: NetworkPlaygroundViewModel
    @State private var selectedDeviceType: NetworkDevice.DeviceType = .computer
    @State private var selectedSourceId: UUID?
    @State private var selectedDestId: UUID?
    @State private var connectMode = false
    @State private var showLog = false

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            toolbarView

            // Canvas
            ZStack {
                // Background grid
                GridBackground()

                // Connections
                ForEach(networkVM.connections) { conn in
                    if let from = networkVM.devices.first(where: { $0.id == conn.fromDeviceId }),
                       let to = networkVM.devices.first(where: { $0.id == conn.toDeviceId }) {
                        ConnectionLine(from: from.position, to: to.position)

                        // Packet on connection
                        ForEach(networkVM.packets.filter { $0.connectionId == conn.id }) { packet in
                            PacketDot(from: from.position, to: to.position, progress: packet.progress)
                        }
                    }
                }

                // Devices
                ForEach(networkVM.devices) { device in
                    DeviceNode(device: device,
                               isSelected: device.id == selectedSourceId || device.id == selectedDestId,
                               isSource: device.id == selectedSourceId)
                    .position(device.position)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if let idx = networkVM.devices.firstIndex(where: { $0.id == device.id }) {
                                    networkVM.devices[idx].position = value.location
                                }
                            }
                    )
                    .onTapGesture {
                        handleDeviceTap(device)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.darkNavy)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 12)
            .onTapGesture { location in
                if !connectMode && networkVM.devices.count < 10 {
                    networkVM.addDevice(selectedDeviceType, at: location)
                }
            }

            // Log
            if showLog {
                logView
            }
        }
        .background(Theme.backgroundGradient.ignoresSafeArea())
        .navigationTitle("Network Sandbox")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var toolbarView: some View {
        VStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(NetworkDevice.DeviceType.allCases, id: \.self) { type in
                        Button(action: {
                            selectedDeviceType = type
                            connectMode = false
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: type.icon)
                                    .font(.system(size: 16))
                                Text(type.rawValue)
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .foregroundColor(selectedDeviceType == type && !connectMode ? .white : .white.opacity(0.6))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedDeviceType == type && !connectMode ? Theme.electricBlue : .white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }

                    Divider().frame(height: 30).background(.white.opacity(0.3))

                    Button(action: { connectMode.toggle(); selectedSourceId = nil; selectedDestId = nil }) {
                        VStack(spacing: 4) {
                            Image(systemName: "link")
                                .font(.system(size: 16))
                            Text("Connect")
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundColor(connectMode ? .white : .white.opacity(0.6))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(connectMode ? Theme.mintGreen : .white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    Button(action: { showLog.toggle() }) {
                        Image(systemName: "text.alignleft")
                            .foregroundColor(.white.opacity(0.6))
                            .padding(10)
                            .background(.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    Button(action: { networkVM.clearAll() }) {
                        Image(systemName: "trash")
                            .foregroundColor(Theme.coral)
                            .padding(10)
                            .background(Theme.coral.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal, 12)
            }

            if connectMode {
                Text("Tap two devices to connect them")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.mintGreen)
            } else {
                Text("Tap canvas to add \(selectedDeviceType.rawValue)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(.vertical, 8)
    }

    private var logView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Network Log")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(Array(networkVM.simulationLog.enumerated()), id: \.offset) { _, log in
                        Text(log)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
        .padding(12)
        .frame(height: 120)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }

    private func handleDeviceTap(_ device: NetworkDevice) {
        if connectMode {
            if selectedSourceId == nil {
                selectedSourceId = device.id
            } else if selectedSourceId != device.id {
                selectedDestId = device.id
                networkVM.connectDevices(from: selectedSourceId!, to: device.id)
                // Also send a packet
                networkVM.sendPacket(from: selectedSourceId!, to: device.id)
                selectedSourceId = nil
                selectedDestId = nil
            }
        }
    }
}

// MARK: - Supporting Views

struct GridBackground: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 30
            for x in stride(from: 0, through: size.width, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(.white.opacity(0.05)), lineWidth: 1)
            }
            for y in stride(from: 0, through: size.height, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(.white.opacity(0.05)), lineWidth: 1)
            }
        }
    }
}

struct DeviceNode: View {
    let device: NetworkDevice
    let isSelected: Bool
    let isSource: Bool

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: device.type.icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(isSelected ? Theme.mintGreen : Theme.electricBlue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Theme.mintGreen : .clear, lineWidth: 2)
                )
                .shadow(color: (isSelected ? Theme.mintGreen : Theme.electricBlue).opacity(0.5), radius: 8)
            Text(device.label)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

struct ConnectionLine: View {
    let from: CGPoint
    let to: CGPoint

    var body: some View {
        Path { path in
            path.move(to: from)
            path.addLine(to: to)
        }
        .stroke(Theme.electricBlue.opacity(0.4), style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
    }
}

struct PacketDot: View {
    let from: CGPoint
    let to: CGPoint
    let progress: CGFloat

    var body: some View {
        Circle()
            .fill(Theme.softYellow)
            .frame(width: 10, height: 10)
            .shadow(color: Theme.softYellow, radius: 6)
            .position(
                x: from.x + (to.x - from.x) * progress,
                y: from.y + (to.y - from.y) * progress
            )
    }
}
