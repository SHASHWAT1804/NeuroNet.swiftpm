import SwiftUI

// MARK: - Gradient Card
struct GradientCard<Content: View>: View {
    let gradient: LinearGradient
    let content: () -> Content

    init(gradient: LinearGradient = Theme.primaryGradient,
         @ViewBuilder content: @escaping () -> Content) {
        self.gradient = gradient
        self.content = content
    }

    var body: some View {
        content()
            .padding(20)
            .background(gradient)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
    }
}

// MARK: - Glass Card
struct GlassCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(20)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardRadius)
                    .stroke(.white.opacity(0.15), lineWidth: 1)
            )
    }
}

// MARK: - Bouncy Button
struct BouncyButton: View {
    let title: String
    let icon: String?
    let gradient: LinearGradient
    let action: () -> Void

    @State private var isPressed = false

    init(_ title: String, icon: String? = nil,
         gradient: LinearGradient = Theme.primaryGradient,
         action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.gradient = gradient
        self.action = action
    }

    var body: some View {
        Button(action: {
            Haptics.medium()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPressed = false
                action()
            }
        }) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(gradient)
            .clipShape(RoundedRectangle(cornerRadius: Theme.buttonRadius))
            .shadow(color: Theme.electricBlue.opacity(0.3), radius: 8, y: 4)
        }
        .scaleEffect(isPressed ? 0.92 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isPressed)
    }
}

// MARK: - XP Badge
struct XPBadge: View {
    let xp: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .foregroundColor(Theme.softYellow)
                .font(.system(size: 12))
            Text("\(xp) XP")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(Theme.softYellow)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Theme.softYellow.opacity(0.15))
        .clipShape(Capsule())
    }
}

// MARK: - Progress Ring
struct ProgressRing: View {
    let progress: Double
    let size: CGFloat
    let lineWidth: CGFloat
    let gradient: LinearGradient

    init(progress: Double, size: CGFloat = 60,
         lineWidth: CGFloat = 6,
         gradient: LinearGradient = Theme.primaryGradient) {
        self.progress = progress
        self.size = size
        self.lineWidth = lineWidth
        self.gradient = gradient
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.1), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(gradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.8), value: progress)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.smallRadius))
    }
}

// MARK: - Confetti View
struct ConfettiView: View {
    @State private var particles: [(id: Int, x: CGFloat, y: CGFloat, color: Color, rotation: Double)] = []
    @State private var animate = false

    let colors: [Color] = [Theme.electricBlue, Theme.neonPurple, Theme.mintGreen,
                            Theme.softYellow, Theme.coral, .pink, .orange]

    var body: some View {
        ZStack {
            ForEach(particles, id: \.id) { p in
                RoundedRectangle(cornerRadius: 2)
                    .fill(p.color)
                    .frame(width: 8, height: 8)
                    .rotationEffect(.degrees(animate ? p.rotation + 360 : p.rotation))
                    .offset(x: animate ? p.x : 0, y: animate ? p.y : -20)
                    .opacity(animate ? 0 : 1)
            }
        }
        .onAppear {
            particles = (0..<50).map { i in
                (id: i,
                 x: CGFloat.random(in: -180...180),
                 y: CGFloat.random(in: 200...600),
                 color: colors.randomElement()!,
                 rotation: Double.random(in: 0...360))
            }
            withAnimation(.easeOut(duration: 2.0)) { animate = true }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Animated Counter
struct AnimatedCounter: View {
    let value: Int
    @State private var displayValue: Int = 0

    var body: some View {
        Text("\(displayValue)")
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .onChange(of: value) { newVal in
                withAnimation(.easeInOut(duration: 0.5)) {
                    displayValue = newVal
                }
            }
            .onAppear { displayValue = value }
    }
}

// MARK: - Module Card
struct ModuleCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: LinearGradient
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(.white.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(20)
            .background(gradient)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
            .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
        }
        .buttonStyle(.plain)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: isHovered)
    }
}
