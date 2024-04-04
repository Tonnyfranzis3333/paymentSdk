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
    @Binding var navigationCallback: ((TransactionStatusModel) -> Void)?
    @State private var counter = 0
    let actionTimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

    @State private var isTimerRunning = false

    @State private var isBottomSheetExpanded = false
    
    @StateObject var viewModel = proceedViewModel()
    var isSwahili = Bool()
    var body: some View {
        VStack {
            HStack {
                Text("\(LocalizationManager.localizedString("Order ID", isSwahili: isSwahili)) - \(viewModel.orderID)").font(.system(size: 18, weight: .bold)).foregroundColor(.black)
            }.padding()
                .foregroundColor(.white)
            Divider()
            Spacer()
            if timeRemaining > 0 , !viewModel.apiResponseSuccess{
                // Loader
                ZStack {
                    Text(timeString(time: timeRemaining))
                        .font(.title3)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(timeRemaining) / CGFloat(totalTime))
                        .stroke(Color(red: 0.0/255, green: 97.0/255, blue: 168.0/255), lineWidth: 10)
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(timeRemaining) / CGFloat(totalTime))
                        .stroke(Color.white, lineWidth: 10)
                        .frame(width: 130, height: 130)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear)
                    
                    ForEach(0..<60) { index in
                        Capsule()
                            .frame(width: 2, height: 15)
                            .foregroundColor(capsuleColor(for: Double(timeRemaining), index: Double(index)))
                            .offset(y: 70)
                            .rotationEffect(.degrees(-180 + Double(index) * (360.0 / 60)))
                    }
                }

                Spacer()
                Text((LocalizationManager.localizedString("Open your Airtel Money wallet to approve the payment request before the timer runs out", isSwahili: isSwahili))).font(.system(size: 21, weight: .bold)).padding(.bottom,20).padding(.horizontal,20)
                Text((LocalizationManager.localizedString("Note : Do not hit back button or close this screen until the transaction is complete", isSwahili: isSwahili))).font(.system(size: 17, weight: .regular)).padding(.horizontal,20)
                Spacer()
                Button(action: {
                    isBottomSheetExpanded.toggle()
                }) {
                    Text((LocalizationManager.localizedString("Cancel Payment", isSwahili: isSwahili))).foregroundColor(Color(red: 0.0/255, green: 97.0/255, blue: 168.0/255)).font(.system(size: 21, weight: .bold))
                }
                Spacer()
            } else {
                if viewModel.apiResponseSuccess{
                    Spacer()
                    Text((LocalizationManager.localizedString("Transaction Successfull", isSwahili: isSwahili))).font(.system(size: 20, weight: .bold)).padding(.horizontal,20)
                    Spacer()
                }
                SuccessOrFailurePopup(isSuccess: $viewModel.apiResponseSuccess,amount: $viewModel.amount,isSwahili : isSwahili){
                    
                    let transactionStatusModel = TransactionStatusModel(cancelStatus: false, data: viewModel.transactionStatusModel?.data)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        navigationCallback?(transactionStatusModel)
                    }
                }
                .presentationDetents([.height(300)])
                
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
            if let retrievedOrderID = UserDefaults.standard.string(forKey: "OrderID") {
                viewModel.orderID = retrievedOrderID
            }
            performAction()
        }
        .sheet(isPresented: $isBottomSheetExpanded) {
            CancelPopup(isBottomSheetExpanded: $isBottomSheetExpanded,isSwahili:isSwahili){
                performAction()
                let transactionStatusModel = TransactionStatusModel(cancelStatus: false, data: viewModel.transactionStatusModel?.data)
                    navigationCallback?(transactionStatusModel)
            }
            .presentationDetents([.height(300)])
        }
        .sheet(isPresented: $viewModel.showPopup) {
            SuccessOrFailurePopup(isSuccess: $viewModel.apiResponseSuccess,amount: $viewModel.amount){
                let transactionStatusModel = TransactionStatusModel(cancelStatus: false, data: viewModel.transactionStatusModel?.data)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    navigationCallback?(transactionStatusModel)
                }
                
            }
            .presentationDetents([.height(300)])
        }
        
    }

    func capsuleColor(for timeRemaining: Double, index: Double) -> Color {
        let percentage = CGFloat(timeRemaining) / CGFloat(totalTime)
        
        if index / 60.0 < percentage {
            return Color(red: 0.0/255, green: 97.0/255, blue: 168.0/255) // Use the original color otherwise
        } else {
            return Color.gray // Use gray color for capsules representing passed time
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


struct CancelPopup: View {
    @Binding var isBottomSheetExpanded: Bool
    @StateObject var viewModel = proceedViewModel()
    var isSwahili = Bool()
    var onCancel: () -> Void
    var body: some View {
        VStack(alignment: .leading){
            Text((LocalizationManager.localizedString("Are you sure you want to cancel the payment?", isSwahili: isSwahili))).font(.system(size: 21, weight: .bold)).padding(.bottom,20).padding(.horizontal,20)
            
            Text((LocalizationManager.localizedString("This payment request will get cancelled only if you have not completed the payment on Airtel Money wallet app", isSwahili: isSwahili))).font(.system(size: 17, weight: .regular)).padding(.bottom,20).padding(.horizontal,20)
                
            CustomButton(title: "\(LocalizationManager.localizedString("Yes, Cancel", isSwahili: isSwahili))") {
                print("Button tapped!")
                isBottomSheetExpanded.toggle()
                onCancel()
            }.padding(.horizontal,20)
            CustomButtonWhite(title: (LocalizationManager.localizedString("No", isSwahili: isSwahili))) {
                print("Button tapped!")
                isBottomSheetExpanded.toggle()
            }.padding(.horizontal,20)
            }
            
        }
    }


struct SuccessOrFailurePopup: View {
    @Binding var isSuccess: Bool
    @Binding var amount: String
    var isSwahili = Bool()
    var onCancel: () -> Void
    var body: some View {
        VStack(alignment: .leading) {
            if isSuccess {
                Text((LocalizationManager.localizedString("Thank you", isSwahili: isSwahili))).font(.system(size: 25, weight: .bold)).padding(.bottom,20).padding(.horizontal,20).foregroundColor(.white).padding(.top,20)
            }else{
                Text("Sorry").font(.system(size: 25, weight: .bold)).padding(.bottom,20).padding(.horizontal,20).foregroundColor(.white).padding(.top,20)
            }
            if isSuccess {
                Text("Your Payment of TSh \(amount) was Successful").font(.system(size: 17, weight: .regular)).padding(.bottom,20).padding(.horizontal,20).foregroundColor(.white)
            } else {
                Text("\(LocalizationManager.localizedString("Your Payment of TSh", isSwahili: isSwahili)) \(amount) \(LocalizationManager.localizedString("has Failed", isSwahili: isSwahili))").font(.system(size: 17, weight: .regular)).padding(.bottom,20).padding(.horizontal,20).foregroundColor(.white)
            }
            if isSuccess {
//                Text("Payment Successful Message").font(.system(size: 17, weight: .regular)).padding(.bottom,20).padding(.horizontal,20).foregroundColor(.white)
            } else {
                Text((LocalizationManager.localizedString("Failed Reason: External Transactions Already Exist", isSwahili: isSwahili))).font(.system(size: 17, weight: .regular)).padding(.bottom,20).padding(.horizontal,20).foregroundColor(.white)
            }
            
        }
        .background(
            Color(red: 0.0/255, green: 97.0/255, blue: 168.0/255)
                .cornerRadius(10)
        )
        .frame(height: 230)
        .padding(.horizontal, 20)
        .onAppear(){
            onCancel()
        }
    }
}


