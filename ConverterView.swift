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

    private var exampleHint: (input: String, output: String) {
        NumberConverter.exampleHint(for: selectedMode.rawValue)
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
                                Haptics.selection()
                                withAnimation { selectedMode = mode }
                                inputText = ""
                                result = ""
                                steps = []
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

                // Example hint
                Button(action: {
                    Haptics.light()
                    inputText = exampleHint.input
                    convert()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(Theme.softYellow)
                            .font(.system(size: 14))
                        Text("Try it:  \(exampleHint.input) → \(exampleHint.output)")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(Theme.mintGreen)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Theme.softYellow.opacity(0.1))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Theme.softYellow.opacity(0.2), lineWidth: 1))
                }

                // Input
                GlassCard {
                    VStack(spacing: 12) {
                        HStack {
                            Text("Enter Value")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                            Spacer()
                            if !inputText.isEmpty {
                                Button(action: {
                                    Haptics.light()
                                    inputText = ""
                                    result = ""
                                    steps = []
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white.opacity(0.4))
                                        .font(.system(size: 16))
                                }
                            }
                        }

                        TextField(placeholderText, text: $inputText)
                            .font(.system(size: 22, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .textFieldStyle(.plain)
                            .autocapitalization(.allCharacters)
                            .disableAutocorrection(true)
                            .onChange(of: inputText) { _ in convert() }
                    }
                }

                // Result
                if !result.isEmpty {
                    resultCard
                }

                // Steps
                if !steps.isEmpty {
                    stepsSection
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(Theme.backgroundGradient.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    private var resultCard: some View {
        let isError = result == "Invalid input"
        let grad = isError
            ? LinearGradient(colors: [Theme.coral, Theme.coral.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
            : Theme.successGradient
        return GradientCard(gradient: grad) {
            VStack(spacing: 8) {
                Text("Result")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                Text(result)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .textSelection(.enabled)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .transition(.scale.combined(with: .opacity))
    }

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Step by Step")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Text("\(steps.count) steps")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))
            }

            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(spacing: 12) {
                    Text("\(index + 1)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(index == steps.count - 1 ? Theme.mintGreen : Theme.neonPurple)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text(step.step)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                        Text("→ \(step.result)")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(index == steps.count - 1 ? Theme.softYellow : Theme.mintGreen)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(index == steps.count - 1 ? Theme.mintGreen.opacity(0.1) : Color.clear)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: Theme.smallRadius))
                .opacity(animateSteps ? 1 : 0)
                .offset(x: animateSteps ? 0 : -20)
                .animation(.spring().delay(Double(index) * 0.08), value: animateSteps)
            }
        }
    }

    private var placeholderText: String {
        "e.g. \(exampleHint.input)"
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
            if let dec = Int(input), dec >= 0 {
                result = NumberConverter.decimalToBinary(dec)
                steps = NumberConverter.stepsDecimalToBinary(dec)
                Haptics.light()
            } else { result = "Invalid input"; steps = []; Haptics.error() }

        case .binToDec:
            let valid = input.allSatisfy { $0 == "0" || $0 == "1" }
            if valid, let dec = NumberConverter.binaryToDecimal(input) {
                result = "\(dec)"
                steps = NumberConverter.stepsBinaryToDecimal(input)
                Haptics.light()
            } else { result = "Invalid input"; steps = []; Haptics.error() }

        case .decToHex:
            if let dec = Int(input), dec >= 0 {
                result = NumberConverter.decimalToHex(dec)
                steps = NumberConverter.stepsDecimalToHex(dec)
                Haptics.light()
            } else { result = "Invalid input"; steps = []; Haptics.error() }

        case .hexToDec:
            if let dec = NumberConverter.hexToDecimal(input) {
                result = "\(dec)"
                steps = NumberConverter.stepsHexToDecimal(input)
                Haptics.light()
            } else { result = "Invalid input"; steps = []; Haptics.error() }

        case .decToOct:
            if let dec = Int(input), dec >= 0 {
                result = NumberConverter.decimalToOctal(dec)
                steps = NumberConverter.stepsDecimalToOctal(dec)
                Haptics.light()
            } else { result = "Invalid input"; steps = []; Haptics.error() }

        case .octToDec:
            let valid = input.allSatisfy { $0 >= "0" && $0 <= "7" }
            if valid, let dec = NumberConverter.octalToDecimal(input) {
                result = "\(dec)"
                steps = NumberConverter.stepsOctalToDecimal(input)
                Haptics.light()
            } else { result = "Invalid input"; steps = []; Haptics.error() }

        case .hexToBin:
            if let _ = Int(input, radix: 16) {
                result = NumberConverter.hexToBinary(input) ?? ""
                steps = NumberConverter.stepsHexToBinary(input)
                Haptics.light()
            } else { result = "Invalid input"; steps = []; Haptics.error() }

        case .binToHex:
            let valid = input.allSatisfy { $0 == "0" || $0 == "1" }
            if valid, let hex = NumberConverter.binaryToHex(input) {
                result = hex
                steps = NumberConverter.stepsBinaryToHex(input)
                Haptics.light()
            } else { result = "Invalid input"; steps = []; Haptics.error() }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation { animateSteps = true }
        }
    }
}
