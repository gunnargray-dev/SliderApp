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
                Text("Response Speed Demo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                    .padding(.bottom, 40)
                
                ResponseSpeedSlider(responseSpeed: $responseSpeed)
                    .padding(.horizontal, 20)
                
                Spacer()
            }
            .padding(.top, 60)
        }
        .preferredColorScheme(.dark)
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
