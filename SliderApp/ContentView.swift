import SwiftUI

struct ContentView: View {
    @State private var responseSpeed: Double = 1.0
    
    // Dynamic gradient colors based on response speed
    private var dynamicGradientColors: [Color] {
        // Map response speed (0.5 to 1.5) to color spectrum
        let normalizedSpeed = (responseSpeed - 0.5) / 1.0 // 0.0 to 1.0
        
        // Define color spectrum points
        let colorStops: [(Double, [Color])] = [
            (0.0, [Color(hex: "1a0845"), Color(hex: "2d1b69"), Color(hex: "0f2357"), Color(hex: "1a0845")]), // Deep purple/blue
            (0.2, [Color(hex: "2d1b69"), Color(hex: "4c1d95"), Color(hex: "1e40af"), Color(hex: "2563eb")]), // Purple to blue
            (0.4, [Color(hex: "059669"), Color(hex: "0d9488"), Color(hex: "0891b2"), Color(hex: "0284c7")]), // Teal/cyan
            (0.6, [Color(hex: "f59e0b"), Color(hex: "d97706"), Color(hex: "ea580c"), Color(hex: "dc2626")]), // Orange to red
            (0.8, [Color(hex: "dc2626"), Color(hex: "b91c1c"), Color(hex: "991b1b"), Color(hex: "7f1d1d")]), // Red spectrum
            (1.0, [Color(hex: "be123c"), Color(hex: "9f1239"), Color(hex: "881337"), Color(hex: "4c0519")]), // Deep red/maroon
        ]
        
        // Find the two closest color stops and interpolate
        var lowerStop = colorStops[0]
        var upperStop = colorStops[0]
        
        for i in 0..<colorStops.count - 1 {
            if normalizedSpeed >= colorStops[i].0 && normalizedSpeed <= colorStops[i + 1].0 {
                lowerStop = colorStops[i]
                upperStop = colorStops[i + 1]
                break
            }
        }
        
        // Calculate interpolation factor
        let range = upperStop.0 - lowerStop.0
        let factor = range > 0 ? (normalizedSpeed - lowerStop.0) / range : 0
        
        // Interpolate between the color arrays
        var interpolatedColors: [Color] = []
        for i in 0..<4 {
            let interpolated = Color.interpolate(
                from: lowerStop.1[i], 
                to: upperStop.1[i], 
                factor: factor
            )
            interpolatedColors.append(interpolated)
        }
        
        return interpolatedColors
    }
    
    var body: some View {
        ZStack {
            // Dynamic mesh gradient background
            MeshGradientBackground(colors: dynamicGradientColors)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.8), value: responseSpeed)
            
            VStack {
                // Title at top
                Text("Response Speed Demo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                    .padding(.top, 60)
                
                Spacer()
                
                // Data visualization in center
                DataVisualizationView(responseSpeed: responseSpeed)
                
                Spacer()
                
                // Slider at bottom
                ResponseSpeedSlider(responseSpeed: $responseSpeed)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Data Visualization Component
struct DataVisualizationView: View {
    let responseSpeed: Double
    @State private var animatedValue: Double = 0
    @State private var sampleData: [Double] = []
    @State private var timer: Timer?
    
    private var responseTime: Double {
        // Convert response speed to milliseconds (inverse relationship)
        return 200 / responseSpeed // Base 200ms, divided by speed multiplier
    }
    
    private var throughput: Double {
        // Calculate throughput based on response speed
        return responseSpeed * 50 // Base 50 operations/sec, multiplied by speed
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // Main data display
            VStack(spacing: 20) {
                // Response Time Card
                DataCard(
                    title: "Response Time",
                    value: String(format: "%.0fms", responseTime),
                    subtitle: "Average latency",
                    color: getDataColor()
                )
                
                // Throughput Card  
                DataCard(
                    title: "Throughput",
                    value: String(format: "%.0f ops/sec", throughput),
                    subtitle: "Operations per second",
                    color: getDataColor()
                )
                
                // Speed Multiplier Card
                DataCard(
                    title: "Speed Multiplier",
                    value: String(format: "%.1fx", responseSpeed),
                    subtitle: "Current setting",
                    color: getDataColor(),
                    isHighlighted: true
                )
            }
            
            // Live data visualization
            LiveDataChart(responseSpeed: responseSpeed, color: getDataColor())
        }
        .onAppear {
            animatedValue = responseSpeed
            startDataSimulation()
        }
        .onDisappear {
            stopDataSimulation()
        }
        .onChange(of: responseSpeed) { _, newValue in
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedValue = newValue
            }
        }
    }
    
    private func getDataColor() -> Color {
        let normalizedSpeed = (responseSpeed - 0.5) / 1.0
        
        let colorStops: [(Double, Color)] = [
            (0.0, Color(hex: "7c3aed")), // Purple
            (0.2, Color(hex: "3b82f6")), // Blue
            (0.4, Color(hex: "10b981")), // Emerald
            (0.6, Color(hex: "f59e0b")), // Amber
            (0.8, Color(hex: "ef4444")), // Red
            (1.0, Color(hex: "f43f5e")), // Rose
        ]
        
        for i in 0..<colorStops.count - 1 {
            let current = colorStops[i]
            let next = colorStops[i + 1]
            
            if normalizedSpeed >= current.0 && normalizedSpeed <= next.0 {
                let range = next.0 - current.0
                let factor = range > 0 ? (normalizedSpeed - current.0) / range : 0
                return Color.interpolate(from: current.1, to: next.1, factor: factor)
            }
        }
        
        return colorStops.last?.1 ?? Color.blue
    }
    
    private func startDataSimulation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            let newValue = responseSpeed + Double.random(in: -0.1...0.1)
            sampleData.append(newValue)
            if sampleData.count > 50 {
                sampleData.removeFirst()
            }
        }
    }
    
    private func stopDataSimulation() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Data Card Component
struct DataCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    var isHighlighted: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .textCase(.uppercase)
                .tracking(1)
            
            Text(value)
                .font(.system(size: isHighlighted ? 32 : 28, weight: .bold, design: .rounded))
                .foregroundColor(color)
                .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(isHighlighted ? 0.4 : 0.2), lineWidth: 1)
        )
        .scaleEffect(isHighlighted ? 1.05 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isHighlighted)
    }
}

// MARK: - Live Data Chart Component
struct LiveDataChart: View {
    let responseSpeed: Double
    let color: Color
    @State private var chartData: [CGFloat] = Array(repeating: 0.5, count: 30)
    @State private var animationTimer: Timer?
    
    var body: some View {
        VStack(spacing: 12) {
            Text("LIVE DATA")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
                .tracking(1.5)
            
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(Array(chartData.enumerated()), id: \.offset) { index, value in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(color.opacity(0.8))
                        .frame(width: 4, height: max(4, value * 40))
                        .animation(.easeInOut(duration: 0.3), value: value)
                }
            }
            .frame(height: 50)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
        .onChange(of: responseSpeed) { _, _ in
            updateChartData()
        }
    }
    
    private func startAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { _ in
            updateChartData()
        }
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func updateChartData() {
        let newValue = CGFloat(responseSpeed * 0.4 + Double.random(in: -0.2...0.2))
        chartData.removeFirst()
        chartData.append(max(0.1, min(1.0, newValue)))
    }
}

// MARK: - Mesh Gradient Background Component
struct MeshGradientBackground: View {
    let colors: [Color]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base gradient
                RadialGradient(
                    gradient: Gradient(colors: [colors[0], colors[1]]),
                    center: UnitPoint(x: 0.2, y: 0.2),
                    startRadius: 0,
                    endRadius: geometry.size.width * 0.8
                )
                
                // Overlay gradient 1
                RadialGradient(
                    gradient: Gradient(colors: [colors[2].opacity(0.7), Color.clear]),
                    center: UnitPoint(x: 0.8, y: 0.3),
                    startRadius: 0,
                    endRadius: geometry.size.width * 0.6
                )
                .blendMode(.overlay)
                
                // Overlay gradient 2
                RadialGradient(
                    gradient: Gradient(colors: [colors[3].opacity(0.5), Color.clear]),
                    center: UnitPoint(x: 0.3, y: 0.8),
                    startRadius: 0,
                    endRadius: geometry.size.width * 0.7
                )
                .blendMode(.multiply)
                
                // Linear gradient overlay
                LinearGradient(
                    gradient: Gradient(colors: [
                        colors[0].opacity(0.3),
                        Color.clear,
                        colors[1].opacity(0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .blendMode(.overlay)
                
                // Noise texture overlay
                Rectangle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.02),
                                Color.clear,
                                Color.black.opacity(0.05)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: geometry.size.width * 0.5
                        )
                    )
                    .blendMode(.overlay)
            }
        }
    }
}

#Preview {
    ContentView()
} 
