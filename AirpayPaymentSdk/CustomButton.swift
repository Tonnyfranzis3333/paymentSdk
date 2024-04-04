//
//  CustomButton.swift
//  Yako
//
//  Created by Vysag K on 24/11/23.
//

import Foundation
import SwiftUI

struct CustomButtonWithLoader: View {
    var buttonText: LocalizedStringKey
    var action: () -> Void
    var buttonColor: Color
    var shouldDisable:Bool
    @Binding var showIndicator:Bool
    @State var isloading:Bool = true
    var body: some View {
        Button(action: {
            
          
            action()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .foregroundColor(buttonColor)
                    .frame(height: 45)
                    .frame(maxWidth: .infinity)
                   // .padding(.horizontal,20)
                   
                if showIndicator {
                  
                    ProgressView()
                        .progressViewStyle(CustomDotProgressViewStyle())
                        .foregroundColor(.white)
                } else {
                    Text(buttonText)
                        .font(.custom("OpenSans-Regular", size: 16))
                        .foregroundColor(.white)
                        
                }
                
            }
            
        }
       // .disabled(showIndicator )
        
    }

}
struct CustomDotProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
       ThreeDotLoadingView()
    }
}

struct ThreeDotLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 8) {
            DotView()
                .offset(y: isAnimating ? 0 : -8)
                .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.3))
                
            
            DotView()
                .offset(y: isAnimating ? 0 : -8)
                .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.5))
            
            DotView()
                .offset(y: isAnimating ? 0 : -8)
                .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.7))
            DotView()
                .offset(y: isAnimating ? 0 : -8)
                .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.9))
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct DotView: View {
    var body: some View {
        Circle()
            .frame(width: 10, height: 10)
            .foregroundColor(Color.white)
    }
}


struct SequentialLoadingView: View {
    @Binding  var isAnimating:Bool
    @Binding var showindicator:Bool
    let animationDuration: Double = 0.8 // Adjust the duration of each dot's animation
    
    var body: some View {
        HStack(spacing: 8) {
            DotView2(isAnimating: $isAnimating, delay: 0)
            DotView2(isAnimating: $isAnimating, delay: animationDuration * 0.25)
            DotView2(isAnimating: $isAnimating, delay: animationDuration * 0.5)
            DotView2(isAnimating: $isAnimating, delay: animationDuration * 0.75)
        }
        .onAppear {
            startAnimation()
            
        }
        
       
    }
    
    func startAnimation() {
        withAnimation(Animation.easeInOut(duration:animationDuration).repeatForever(autoreverses: false)) {
            self.isAnimating.toggle()
        }
    }
}

struct DotView2: View {
    @Binding var isAnimating: Bool
    let delay: Double
    
    var body: some View {
        Circle()
            .frame(width: 12, height: 12)
            .foregroundColor(Color.white)
            .opacity(isAnimating ? 1 : 0.3)
            .animation(Animation.easeInOut(duration: 0.5).delay(delay))
    }
}
