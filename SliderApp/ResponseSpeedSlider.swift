import SwiftUI
import AVFoundation

struct ResponseSpeedSlider: View {
    // MARK: - Properties
    @Binding var responseSpeed: Double
    @State private var isDragging = false
    @State private var lastTickValue: Double = 0
    @State private var particles: [Particle] = []
    @State private var particleTimer: Timer?
    @State private var particlesFadingOut = false
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "232525"))
                    .frame(height: 120)
                
                VStack(alignment: .leading, spacing: 4) {
                    // Title inside container
                    HStack {
                        Text("Response Speed")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "FCFCF9"))
                    }
                    .padding(.horizontal, 20)
                    
                    
                    // Slider section
                    GeometryReader { geometry in
                        SliderView(
                            geometry: geometry,
                            responseSpeed: $responseSpeed,
                            isDragging: $isDragging,
                            lastTickValue: $lastTickValue,
                            particles: $particles,
                            particleTimer: $particleTimer,
                            particlesFadingOut: $particlesFadingOut
                        )
                    }
                    .frame(height: 60)
                }
              
            }
        }
    }
}

// MARK: - Color Extensions
extension Color {
    static func interpolate(from: Color, to: Color, factor: Double) -> Color {
        let clampedFactor = max(0, min(1, factor))
        
        // Get RGB components from UIColor
        let fromUIColor = UIColor(from)
        let toUIColor = UIColor(to)
        
        var fromRed: CGFloat = 0, fromGreen: CGFloat = 0, fromBlue: CGFloat = 0, fromAlpha: CGFloat = 0
        var toRed: CGFloat = 0, toGreen: CGFloat = 0, toBlue: CGFloat = 0, toAlpha: CGFloat = 0
        
        fromUIColor.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
        toUIColor.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)
        
        // Interpolate each component
        let red = fromRed + (toRed - fromRed) * clampedFactor
        let green = fromGreen + (toGreen - fromGreen) * clampedFactor
        let blue = fromBlue + (toBlue - fromBlue) * clampedFactor
        let alpha = fromAlpha + (toAlpha - fromAlpha) * clampedFactor
        
        return Color(red: red, green: green, blue: blue, opacity: alpha)
    }
}

// MARK: - Particle System
private struct Particle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var opacity: Double
    var scale: CGFloat
    var velocityX: CGFloat
    var velocityY: CGFloat
    var life: Double = 1.0
    var fadeRate: Double = 0.015 // Individual fade rate
    
    mutating func update(fadingOut: Bool = false) {
        x += velocityX
        y += velocityY
        
        if fadingOut {
            life -= fadeRate // Use individual fade rate
        } else {
            life -= 0.01 // Slower fade during dragging for longer trails
        }
        
        opacity = life
        scale = life * 0.8
        velocityY -= 0.06 // Medium gravity effect
    }
    
    mutating func setFadeOutRate() {
        // Set dispersed fade-out rates for staggered effect (slower)
        fadeRate = Double.random(in: 0.01...0.04)
    }
    
    var isAlive: Bool {
        life > 0
    }
}

// MARK: - Slider View
private struct SliderView: View {
    let geometry: GeometryProxy
    @Binding var responseSpeed: Double
    @Binding var isDragging: Bool
    @Binding var lastTickValue: Double
    @Binding var particles: [Particle]
    @Binding var particleTimer: Timer?
    @Binding var particlesFadingOut: Bool
    
    var body: some View {
        let thumbSize: CGFloat = 40
        let trackHeight: CGFloat = 32
        let horizontalPadding: CGFloat = 20
        let draggableWidth = geometry.size.width - (2 * horizontalPadding) - thumbSize
        let percentage = (responseSpeed - 0.5) / 1.0
        let thumbX = (draggableWidth > 0) ? (CGFloat(percentage) * draggableWidth) : 0
        let thumbCenterX = thumbX + thumbSize / 2
        // Calculate intensity based on speed (0.5x to 1.5x range)
        let intensityFactor = (responseSpeed - 0.5) / 1.0 // 0.0 to 1.0
        
        // Dynamic slider colors based on response speed
        let sliderColors = getSliderColors(for: responseSpeed)
        let gradientColors = [sliderColors.darker, sliderColors.brighter]
        
        // Calculate glow intensity based on speed
        let glowIntensity = intensityFactor
        let glowRadius = 8 + (glowIntensity * 12) // 8 to 20 radius
        let glowOpacity = 0.3 + (glowIntensity * 0.4) // 0.3 to 0.7 opacity
        
        ZStack {
            // Particle Trail System with custom colors
            ForEach(particles) { particle in
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                sliderColors.brighter.opacity(particle.opacity),
                                sliderColors.darker.opacity(particle.opacity * 0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 6, height: 6)
                    .scaleEffect(particle.scale)
                    .position(x: particle.x, y: particle.y)
                    .allowsHitTesting(false)
            }
            
            ZStack(alignment: .leading) {
                // Background Track
                Capsule()
                    .fill(Color(hex: "2D2F2F"))
                    .frame(height: trackHeight)

                // Micro-ticks (skip leftmost tick to avoid overflow)
                ForEach(1...10, id: \.self) { idx in
                    Rectangle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 0.5, height: trackHeight / 2)
                        .offset(x: CGFloat(idx) / 10 * draggableWidth)
                }

                // Foreground Track
                Capsule()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: gradientColors),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: thumbCenterX, height: trackHeight)
                    .shadow(color: Color.white.opacity(0.25), radius: 1, x: 0, y: -1)
                
                // Thumb with Glow Effect
                ZStack {
                    // Glow Layer 1 - Outer glow with custom colors
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    sliderColors.darker.opacity(glowOpacity * 0.6),
                                    sliderColors.brighter.opacity(glowOpacity * 0.4),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: thumbSize / 2,
                                endRadius: glowRadius
                            )
                        )
                        .frame(width: glowRadius * 2, height: glowRadius * 2)
                        .animation(.easeInOut(duration: 0.3), value: glowIntensity)
                    
                    // Glow Layer 2 - Inner glow with custom colors
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    sliderColors.brighter.opacity(glowOpacity * 0.8),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: thumbSize / 4,
                                endRadius: thumbSize / 2 + 4
                            )
                        )
                        .frame(width: thumbSize + 8, height: thumbSize + 8)
                        .animation(.easeInOut(duration: 0.3), value: glowIntensity)
                    
                    // Main Thumb
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .background(.ultraThinMaterial, in: Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 1))
                        .overlay(
                            Text(String(format: "%.1fx", responseSpeed))
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .opacity(isDragging ? 0 : 1)
                                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isDragging)
                        )
                        .frame(width: thumbSize, height: thumbSize)
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "1B474D"), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(isDragging ? 0.25 : 0.15), radius: isDragging ? 6 : 4, x: 0, y: isDragging ? 3 : 2)
                }
                .scaleEffect(isDragging ? 1.15 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isDragging)
                .offset(x: thumbX)
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .named("slider"))
                            .onChanged { value in
                                updateSpeed(for: value.location, in: geometry.size)
                                if !isDragging {
                                    playAudioFeedback(.dragStart)
                                    startParticleSystem()
                                    particlesFadingOut = false
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        isDragging = true
                                    }
                                }
                                // Generate particles during drag (only if not fading out)
                                if !particlesFadingOut {
                                    generateParticles(at: CGPoint(
                                        x: horizontalPadding + thumbX + thumbSize / 2,
                                        y: thumbSize / 2
                                    ))
                                }
                            }
                            .onEnded { _ in
                                playAudioFeedback(.dragEnd)
                                particlesFadingOut = true
                                disperseParticleLifetimes()
                                fadeOutParticles()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    isDragging = false
                                    responseSpeed = round(responseSpeed * 10) / 10
                                }
                            }
                    )
            }
            .coordinateSpace(name: "slider")
            .frame(height: thumbSize)
            .padding(.horizontal, horizontalPadding)
            
            // Pop-up value bubble - centered over thumb
            Text(String(format: "%.1fx", responseSpeed))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "FCFCF9"))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(sliderColors.darker)
                .cornerRadius(12)
                .opacity(isDragging ? 1 : 0)
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isDragging)
                .position(
                    x: horizontalPadding + thumbX + thumbSize / 2,
                    y: -8
                )
        }
        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        .onDisappear {
            stopParticleSystem()
        }
    }
    
    // MARK: - Audio Feedback
    private enum AudioFeedbackType {
        case dragStart, dragEnd, boundary, tick
    }
    
    private func playAudioFeedback(_ type: AudioFeedbackType) {
        playHapticFeedback(type)
        
        switch type {
        case .dragStart:
            AudioServicesPlaySystemSound(1103)
        case .dragEnd:
            AudioServicesPlaySystemSound(1104)
        case .boundary:
            AudioServicesPlaySystemSound(1105)
        case .tick:
            AudioServicesPlaySystemSound(1123)
        }
    }
    
    private func playHapticFeedback(_ type: AudioFeedbackType) {
        switch type {
        case .dragStart, .dragEnd:
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.prepare()
            impact.impactOccurred()
        case .boundary:
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.prepare()
            impact.impactOccurred()
        case .tick:
            let selection = UISelectionFeedbackGenerator()
            selection.prepare()
            selection.selectionChanged()
        }
    }
    
    private func updateSpeed(for location: CGPoint, in size: CGSize) {
        let thumbSize: CGFloat = 40
        let horizontalPadding: CGFloat = 20
        let trackWidth = size.width - (2 * horizontalPadding)
        let draggableWidth = trackWidth - thumbSize
        let dragOnTrackX = location.x - horizontalPadding
        let thumbOriginX = dragOnTrackX - (thumbSize / 2)
        let clampedThumbX = max(0, min(thumbOriginX, draggableWidth))
        
        if draggableWidth > 0 {
            let percentage = clampedThumbX / draggableWidth
            let newSpeed = 0.5 + (Double(percentage) * 1.0)
            
            // Boundary feedback
            if (newSpeed == 0.5 && responseSpeed > 0.5) || (newSpeed == 1.5 && responseSpeed < 1.5) {
                playAudioFeedback(.boundary)
            }
            
            // Tick feedback
            let currentTick = round(newSpeed * 10) / 10
            if isDragging && currentTick != lastTickValue {
                playAudioFeedback(.tick)
                lastTickValue = currentTick
            }
            
            responseSpeed = newSpeed
        }
    }
    
    // MARK: - Particle System Functions
    private func startParticleSystem() {
        particleTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updateParticles()
        }
    }
    
    private func stopParticleSystem() {
        particleTimer?.invalidate()
        particleTimer = nil
    }
    
    private func generateParticles(at position: CGPoint) {
        let particleCount = 8 // Increased to 8 particles per frame for richer effect
        for _ in 0..<particleCount {
            let particle = Particle(
                x: position.x + CGFloat.random(in: -15...15), // Much wider horizontal dispersion
                y: position.y + CGFloat.random(in: -12...12), // Much wider vertical spread
                opacity: Double.random(in: 0.5...0.9), // Lower minimum for more variety
                scale: CGFloat.random(in: 0.4...1.3), // Even wider scale range
                velocityX: CGFloat.random(in: -0.25...0.25), // Slower horizontal movement
                velocityY: CGFloat.random(in: -0.15...0.15)  // Slower vertical movement
            )
            particles.append(particle)
        }
    }
    
    private func updateParticles() {
        particles = particles.compactMap { particle in
            var updatedParticle = particle
            updatedParticle.update(fadingOut: particlesFadingOut)
            return updatedParticle.isAlive ? updatedParticle : nil
        }
        
        // Stop timer when all particles are gone and we're fading out
        if particlesFadingOut && particles.isEmpty {
            stopParticleSystem()
        }
    }
    
    private func fadeOutParticles() {
        // Continue running timer to fade out existing particles
        // but don't generate new ones
        if particleTimer == nil {
            startParticleSystem()
        }
    }
    
    private func disperseParticleLifetimes() {
        // Give each existing particle a randomized fade-out rate
        // and add some variation to their current life values
        for i in particles.indices {
            particles[i].setFadeOutRate()
            // Add some randomness to current life for more natural dispersion
                         particles[i].life *= Double.random(in: 0.7...1.0)
         }
     }
     
     // MARK: - Dynamic Color System
     private func getSliderColors(for speed: Double) -> (darker: Color, brighter: Color) {
         let normalizedSpeed = (speed - 0.5) / 1.0 // 0.0 to 1.0
         
         // Define color pairs for different speed ranges
         let colorPairs: [(Double, (Color, Color))] = [
             (0.0, (Color(hex: "4c1d95"), Color(hex: "7c3aed"))), // Purple
             (0.2, (Color(hex: "1e40af"), Color(hex: "3b82f6"))), // Blue
             (0.4, (Color(hex: "059669"), Color(hex: "10b981"))), // Emerald
             (0.6, (Color(hex: "d97706"), Color(hex: "f59e0b"))), // Amber
             (0.8, (Color(hex: "dc2626"), Color(hex: "ef4444"))), // Red
             (1.0, (Color(hex: "be123c"), Color(hex: "f43f5e"))), // Rose
         ]
         
         // Find the two closest color pairs and interpolate
         var lowerPair = colorPairs[0]
         var upperPair = colorPairs[0]
         
         for i in 0..<colorPairs.count - 1 {
             if normalizedSpeed >= colorPairs[i].0 && normalizedSpeed <= colorPairs[i + 1].0 {
                 lowerPair = colorPairs[i]
                 upperPair = colorPairs[i + 1]
                 break
             }
         }
         
         // Calculate interpolation factor
         let range = upperPair.0 - lowerPair.0
         let factor = range > 0 ? (normalizedSpeed - lowerPair.0) / range : 0
         
         // Interpolate colors
         let darkerColor = Color.interpolate(
             from: lowerPair.1.0,
             to: upperPair.1.0,
             factor: factor
         )
         
         let brighterColor = Color.interpolate(
             from: lowerPair.1.1,
             to: upperPair.1.1,
             factor: factor
         )
         
         return (darker: darkerColor, brighter: brighterColor)
     }
 }

// MARK: - Preview
struct ResponseSpeedSlider_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var speed = 1.0
        var body: some View {
            ResponseSpeedSlider(responseSpeed: $speed)
                .padding()
                .background(Color(hex: "191a1a"))
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
} 
