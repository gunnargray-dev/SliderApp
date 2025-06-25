# SliderApp

A SwiftUI demo app featuring a custom response speed slider with advanced visual effects, particle systems, and haptic feedback.

## Features

### 🎨 Advanced Visual Effects
- **Dynamic Gradient Colors**: Beautiful teal-to-cyan gradient that adapts to slider value
- **Particle Trail System**: Physics-based particle effects that follow the slider thumb
- **Dynamic Glow Effects**: Intensity-based glow that changes with response speed
- **Smooth Animations**: Spring-based animations with proper easing

### 🎯 Interactive Experience  
- **Haptic Feedback**: Light, medium, and selection feedback for different interactions
- **Audio Feedback**: System sound integration for enhanced user experience
- **Real-time Value Display**: Live updating speed multiplier (0.5x - 1.5x range)
- **Micro-tick Marks**: Visual guides on the slider track

### 🛠️ Technical Implementation
- **SwiftUI Architecture**: Modern declarative UI framework
- **Custom Particle System**: Timer-based physics simulation with gravity and velocity
- **Gesture Handling**: Advanced drag gesture recognition with coordinate spaces
- **State Management**: Proper `@Binding` and `@State` usage for reactive UI

## Components

### `ResponseSpeedSlider`
The main custom slider component featuring:
- Particle trail generation during interaction
- Dynamic visual feedback based on speed value
- Audio and haptic feedback integration
- Smooth thumb animations with scale effects

### `Color+Extensions`
Utility extension for hex color support throughout the app.

## Requirements

- iOS 14.0+
- Xcode 12.0+
- Swift 5.3+

## Installation

1. Clone the repository
2. Open `SliderApp.xcodeproj` in Xcode
3. Build and run on simulator or device

## Demo

The app demonstrates a response speed control interface that could be used for:
- Accessibility settings
- Animation speed preferences  
- User interface responsiveness controls
- Gaming input sensitivity

## Architecture

Built using SwiftUI with MVVM patterns:
- Clean separation of concerns
- Reusable custom components
- Proper state binding between views
- Modern iOS development practices

---

*Created as a demonstration of advanced SwiftUI techniques including custom gestures, particle systems, and rich user feedback.* 