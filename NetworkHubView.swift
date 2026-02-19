import SwiftUI

struct NetworkHubView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                Text("Network Playground")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)

                Text("Explore how networks work through visual simulations")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .leading)

                NavigationLink(destination: NetworkConceptsView()) {
                    ModuleCardContent(title: "Network Concepts",
                                      subtitle: "IP, MAC, Subnets, CIDR explained visually",
                                      icon: "book.fill",
                                      gradient: Theme.primaryGradient)
                }
                .buttonStyle(.plain)

                NavigationLink(destination: ProtocolVisualizerView()) {
                    ModuleCardContent(title: "Protocol Visualizer",
                                      subtitle: "Watch ARP, ICMP, and DNS in action",
                                      icon: "arrow.triangle.branch",
                                      gradient: Theme.successGradient)
                }
                .buttonStyle(.plain)

                NavigationLink(destination: NetworkSandboxView()) {
                    ModuleCardContent(title: "Network Sandbox",
                                      subtitle: "Build your own network and send packets",
                                      icon: "square.grid.3x3.topleft.filled",
                                      gradient: Theme.warmGradient)
                }
                .buttonStyle(.plain)

                NavigationLink(destination: SubnetCalculatorView()) {
                    ModuleCardContent(title: "Subnet Calculator",
                                      subtitle: "Visualize subnet masks and CIDR notation",
                                      icon: "divide.circle.fill",
                                      gradient: LinearGradient(colors: [Theme.neonPurple, Theme.coral],
                                                               startPoint: .leading, endPoint: .trailing))
                }
                .buttonStyle(.plain)

                // Network quizzes
                Text("Network Quizzes")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach([QuizCategory.ipAddressing, .subnetting, .protocols], id: \.self) { cat in
                        NavigationLink(destination: QuizSetupView(category: cat)) {
                            QuizCategoryCard(category: cat)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(Theme.backgroundGradient.ignoresSafeArea())
    }
}
