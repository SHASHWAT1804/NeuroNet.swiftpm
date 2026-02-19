import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userVM: UserProfileViewModel
    @EnvironmentObject var appState: AppState
    @State private var isEditingName = false
    @State private var nameInput = ""
    @State private var showResetAlert = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Avatar & Name
                avatarSection

                // Stats
                statsSection

                // Badges
                badgesSection

                // Performance
                performanceSection

                // Settings
                settingsSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(Theme.backgroundGradient.ignoresSafeArea())
        .alert("Reset Progress", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                userVM.resetProgress()
                appState.hasCompletedOnboarding = false
            }
        } message: {
            Text("This will erase all your progress, XP, badges, and quiz history. This cannot be undone.")
        }
    }

    private var avatarSection: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Theme.primaryGradient)
                    .frame(width: 100, height: 100)
                    .shadow(color: Theme.electricBlue.opacity(0.4), radius: 15)
                Text(UserProfile.avatars[userVM.profile.avatarIndex])
                    .font(.system(size: 50))
            }

            // Avatar picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(0..<UserProfile.avatars.count, id: \.self) { index in
                        Button(action: {
                            withAnimation { userVM.profile.avatarIndex = index }
                            userVM.save()
                        }) {
                            Text(UserProfile.avatars[index])
                                .font(.system(size: 28))
                                .frame(width: 44, height: 44)
                                .background(index == userVM.profile.avatarIndex ?
                                            Theme.electricBlue.opacity(0.3) : .white.opacity(0.1))
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(index == userVM.profile.avatarIndex ?
                                                    Theme.electricBlue : .clear, lineWidth: 2)
                                )
                        }
                    }
                }
            }

            // Name
            if isEditingName {
                HStack {
                    TextField("Your name", text: $nameInput)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .textFieldStyle(.plain)
                        .multilineTextAlignment(.center)
                        .padding(10)
                        .background(.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    Button(action: {
                        if !nameInput.isEmpty {
                            userVM.profile.name = nameInput
                            userVM.save()
                        }
                        isEditingName = false
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Theme.mintGreen)
                    }
                }
            } else {
                Button(action: {
                    nameInput = userVM.profile.name
                    isEditingName = true
                }) {
                    HStack(spacing: 6) {
                        Text(userVM.profile.name)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }

            // Level badge
            HStack(spacing: 8) {
                XPBadge(xp: userVM.profile.xp)
                Text("Level \(userVM.profile.level)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.electricBlue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Theme.electricBlue.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
        .padding(.top, 10)
    }

    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(title: "Quizzes", value: "\(userVM.totalQuizzesTaken)",
                     icon: "checkmark.circle.fill", color: Theme.electricBlue)
            StatCard(title: "Accuracy", value: "\(Int(userVM.totalAccuracy * 100))%",
                     icon: "target", color: Theme.mintGreen)
            StatCard(title: "Streak", value: "\(userVM.profile.streak)",
                     icon: "flame.fill", color: Theme.coral)
        }
    }

    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Badges")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            let allBadges = BadgeDefinitions.all
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()),
                                GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(allBadges, id: \.id) { achievement in
                    let isUnlocked = userVM.profile.badges.contains { $0.id == achievement.id }
                    VStack(spacing: 6) {
                        Image(systemName: achievement.icon)
                            .font(.system(size: 24))
                            .foregroundColor(isUnlocked ? Theme.softYellow : .white.opacity(0.2))
                            .frame(width: 48, height: 48)
                            .background(isUnlocked ? Theme.softYellow.opacity(0.15) : .white.opacity(0.05))
                            .clipShape(Circle())
                        Text(achievement.title)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(isUnlocked ? .white : .white.opacity(0.3))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                }
            }
        }
    }

    private var performanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance by Category")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            ForEach(QuizCategory.allCases, id: \.self) { cat in
                let accuracy = userVM.accuracyFor(category: cat)
                let count = userVM.quizResults.filter { $0.category == cat }.count
                if count > 0 {
                    HStack(spacing: 12) {
                        Image(systemName: cat.icon)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Theme.electricBlue.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(cat.rawValue)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(.white.opacity(0.1))
                                        .frame(height: 6)
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(accuracy >= 0.7 ? Theme.mintGreen : Theme.coral)
                                        .frame(width: geo.size.width * accuracy, height: 6)
                                }
                            }
                            .frame(height: 6)
                        }

                        Text("\(Int(accuracy * 100))%")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 40, alignment: .trailing)
                    }
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.smallRadius))
                }
            }
        }
    }

    private var settingsSection: some View {
        VStack(spacing: 12) {
            Text("Settings")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Dark mode toggle
            GlassCard {
                Toggle(isOn: $appState.isDarkMode) {
                    HStack(spacing: 10) {
                        Image(systemName: appState.isDarkMode ? "moon.fill" : "sun.max.fill")
                            .foregroundColor(Theme.softYellow)
                        Text("Dark Mode")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .tint(Theme.electricBlue)
            }

            // Reset
            Button(action: { showResetAlert = true }) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Reset All Progress")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                }
                .foregroundColor(Theme.coral)
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Theme.coral.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: Theme.buttonRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.buttonRadius)
                        .stroke(Theme.coral.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
}
