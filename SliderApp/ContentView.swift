import SwiftUI

struct ContentView: View {
    @State private var responseSpeed: Double = 1.0
    
    var body: some View {
        ZStack {
            Color(hex: "191a1a").ignoresSafeArea()
            
            VStack {
                Text("Response Speed Demo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
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

#Preview {
    ContentView()
} 
