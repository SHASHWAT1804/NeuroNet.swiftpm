import SwiftUI

struct ConverterView: View {
    @State private var inputText = ""
    @State private var selectedMode: ConversionMode = .decToBin
    @State private var steps: [(step: String, result: String)] = []
    @State private var result = ""
    @State private var animateSteps = false

    enum ConversionMode: String, CaseIterable {
        case decToBin = "Dec → Bin"
        case binToDec = "Bin → Dec"
        case decToHex = "Dec → Hex"
        case hexToDec = "Hex → Dec"
        case decToOct = "Dec → Oct"
        case octToDec = "Oct → Dec"
        case hexToBin = "Hex → Bin"
        case binToHex = "Bin → Hex"
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                Text("Number Converter")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                // Mode picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ConversionMode.allCases, id: \.self) { mode in
                            Button(action: {
                                withAnimation { selectedMode = mode }
                                convert()
                            }) {
                                Text(mode.rawValue)
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(selectedMode == mode ? .white : .white.opacity(0.6))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(selectedMode == mode ? Theme.electricBlue : .white.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }

                // Input
                GlassCard {
                    VStack(spacing: 12) {
                        Text("Enter Value")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        TextField("Type here...", text: $inputText)
                            .font(.system(size: 22, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .textFieldStyle(.plain)
                            .autocapitalization(.allCharacters)
                            .disableAutocorrection(true)
                            .onChange(of: inputText) { _ in
                                convert()
                            }
                    }
                }

                // Result
                if !result.isEmpty {
                    GradientCard(gradient: Theme.successGradient) {
                        VStack(spacing: 8) {
                            Text("Result")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                            Text(result)
                                .font(.system(size: 32, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .textSelection(.enabled)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                // Steps
                if !steps.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Step by Step")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                            HStack(spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(width: 28, height: 28)
                                    .background(Theme.neonPurple)
                                    .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(step.step)
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.white.opacity(0.9))
                                    Text("→ \(step.result)")
                                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                                        .foregroundColor(Theme.mintGreen)
                                }
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.smallRadius))
                            .opacity(animateSteps ? 1 : 0)
                            .offset(x: animateSteps ? 0 : -20)
                            .animation(.spring().delay(Double(index) * 0.1), value: animateSteps)
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

    private func convert() {
        animateSteps = false
        let input = inputText.trimmingCharacters(in: .whitespaces)
        guard !input.isEmpty else {
            result = ""
            steps = []
            return
        }

        switch selectedMode {
        case .decToBin:
            if let dec = Int(input) {
                result = NumberConverter.decimalToBinary(dec)
                steps = NumberConverter.stepsDecimalToBinary(dec)
            } else { result = "Invalid"; steps = [] }
        case .binToDec:
            if let dec = NumberConverter.binaryToDecimal(input) {
                result = "\(dec)"; steps = []
            } else { result = "Invalid"; steps = [] }
        case .decToHex:
            if let dec = Int(input) {
                result = NumberConverter.decimalToHex(dec)
                steps = NumberConverter.stepsDecimalToHex(dec)
            } else { result = "Invalid"; steps = [] }
        case .hexToDec:
            if let dec = NumberConverter.hexToDecimal(input) {
                result = "\(dec)"; steps = []
            } else { result = "Invalid"; steps = [] }
        case .decToOct:
            if let dec = Int(input) {
                result = NumberConverter.decimalToOctal(dec)
                steps = []
            } else { result = "Invalid"; steps = [] }
        case .octToDec:
            if let dec = NumberConverter.octalToDecimal(input) {
                result = "\(dec)"; steps = []
            } else { result = "Invalid"; steps = [] }
        case .hexToBin:
            if let bin = NumberConverter.hexToBinary(input) {
                result = bin; steps = []
            } else { result = "Invalid"; steps = [] }
        case .binToHex:
            if let hex = NumberConverter.binaryToHex(input) {
                result = hex; steps = []
            } else { result = "Invalid"; steps = [] }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation { animateSteps = true }
        }
    }
}
