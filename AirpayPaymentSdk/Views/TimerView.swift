//
//  TimerView.swift
//  TimerWithLoader
//
//  Created by Tonny Franzis on 11/01/24.
//

import Foundation
import SwiftUI
struct TimerView: View {
    @State private var timeRemaining = 300
    let totalTime = 300
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @State private var counter = 0
    let actionTimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

    @State private var isTimerRunning = false

    @State private var isBottomSheetExpanded = false
    
    
    @State private var isSuccessOrFailure = false
        
    
    
    @StateObject var viewModel = proceedViewModel()
    var body: some View {
        VStack {
            HStack {
                Text("Order ID - 12121213").font(.system(size: 21, weight: .bold)).foregroundColor(.black)
            }.padding()
                .foregroundColor(.white)
            Divider()
            Spacer()
            if timeRemaining > 0 {
                // Loader
                ZStack {
                    Circle()
                        .stroke(Color(red: 0.0/255, green: 97.0/255, blue: 168.0/255), lineWidth: 10)
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear)
                    
                    Text(timeString(time: timeRemaining)).font(.title3)
                        .font(.title)
                        .fontWeight(.bold)
                    Circle()
                        .trim(from: 0, to: CGFloat(timeRemaining) / CGFloat(totalTime))
                        .stroke(Color.white, lineWidth: 10)
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear)
                    Circle()
                        .trim(from: 0, to: CGFloat(timeRemaining) / CGFloat(totalTime))
                        .stroke(Color(red: 0.0/255, green: 97.0/255, blue: 168.0/255), lineWidth: 10)
                        .frame(width: 130, height: 130)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear)
                }
                Spacer()
                Text("Open your Airtel Money wallet to approve the payment request before the timer runs out").font(.system(size: 21, weight: .bold)).padding(.bottom,20).padding(.horizontal,20)
                Text("Note : Do not hit back button or close this screen until the transaction is complete").font(.system(size: 17, weight: .regular)).padding(.horizontal,20)
                Spacer()
                Button(action: {
                    isBottomSheetExpanded.toggle()
                }) {
                    Text("Cancel Payment").foregroundColor(Color(red: 0.0/255, green: 97.0/255, blue: 168.0/255)).font(.system(size: 21, weight: .bold))
                }
                Spacer()
            } else {
                
            }
        }
        .onReceive(timer) { _ in
            guard isTimerRunning else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.upstream.connect().cancel()
            }
        }
        .onReceive(actionTimer) { _ in
            guard isTimerRunning else { return }
            // This closure will be called every 10 seconds
            counter += 1
            performAction() // Call your action here
        }
        .onAppear {
            isTimerRunning = true
        }
        .sheet(isPresented: $isBottomSheetExpanded) {
            DownloadPopup(isBottomSheetExpanded: $isBottomSheetExpanded)
                            .presentationDetents([.height(300)])
        }
        .sheet(isPresented: $viewModel.showPopup) {
            SuccessOrFailurePopup(isSuccessOrFailure: $isSuccessOrFailure,isSuccess: $viewModel.apiResponseSuccess)
                            .presentationDetents([.height(300)])
        }
    }

    func performAction() {
        // Implement the action you want to perform here
        print("Action performed every 10 seconds")
        // For example, you might make an API call, update UI, etc.
        viewModel.every5SecCall()
    }

    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}


struct DownloadPopup: View {
    @Binding var isBottomSheetExpanded: Bool
    var body: some View {
        VStack(alignment: .leading){
            Text("Are you sure you want to cancel the payment?").font(.system(size: 21, weight: .bold)).padding(.bottom,20).padding(.horizontal,20)
            
            Text("This payment request will get cancelled only if you have not completed the payment on Airtel Money wallet app").font(.system(size: 17, weight: .regular)).padding(.bottom,20).padding(.horizontal,20)
                
            CustomButton(title: "Yes, Cancel") {
                print("Button tapped!")
                isBottomSheetExpanded.toggle()
            }.padding(.horizontal,20)
            CustomButtonWhite(title: "No") {
                print("Button tapped!")
            }.padding(.horizontal,20)
            }
            
        }
    }

struct SuccessOrFailurePopup: View {
    @Binding var isSuccessOrFailure: Bool
    @Binding var isSuccess: Bool
    var body: some View {
        VStack(alignment: .leading){
            Text("Sorry").font(.system(size: 25, weight: .bold)).padding(.bottom,20).padding(.horizontal,20).foregroundColor(.white).padding(.top,20)
            
            Text("Your Payment of TSh 800.00 has Failed").font(.system(size: 17, weight: .regular)).padding(.bottom,20).padding(.horizontal,20).foregroundColor(.white)
            Text("Failed Reason: External Transactions Already Exist").font(.system(size: 17, weight: .regular)).padding(.bottom,20).padding(.horizontal,20).foregroundColor(.white)
        }.background(
            Color(red: 0.0/255, green: 97.0/255, blue: 168.0/255)
                .cornerRadius(10)
        )
        .frame(height: 230)
        .padding(.horizontal,20)

    }
}



