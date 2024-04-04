//
//  ConfirmPayementView.swift
//  TimerWithLoader
//
//  Created by Tonny Franzis on 10/01/24.
//

import Foundation
import SwiftUI
import Combine
struct ConfirmPayementView: View {
    let bundleIdentifier = "com.airpay.AirpayPaymentSdk"
    @StateObject var viewModel = proceedViewModel()
    @State private var mobileNumber: String = ""
    @State private var isValidNumber: Bool = true
    @StateObject private var toastManager = ToastManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var navigationCallback: ((TransactionStatusModel) -> Void)?
    @State private var showAlert = false
    let amount: String
    let order_id: String
    let merchant_id: String
    let first_name: String
    let last_name: String
    let srNo: String
    let mobile : String
    let environment : String
    let isSwahili : Bool
    let channel_partner:String
    // Updated init method to include navigationCallback and responseCallback
    init(order_id: String, merchant_id: String, first_name: String, last_name: String, amount: String, srNo: String,mobile:String,environment:String,isSwahili:Bool,channel_partner:String, navigationCallback: ((TransactionStatusModel) -> Void)?) {
        self.order_id = order_id
        self.merchant_id = merchant_id
        self.first_name = first_name
        self.last_name = last_name
        self.amount = amount
        self.srNo = srNo
        self.mobile = mobile
        self.environment = environment
        self.isSwahili = isSwahili
        self.channel_partner = channel_partner
        self._navigationCallback = State(initialValue: navigationCallback) // Bind to @State
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(named: "back", bundleIdentifier: bundleIdentifier)
                                .resizable()
                                .frame(width: 15,height: 15)
                        }
                    }
                    Spacer()
                    Image(named: "logo-airpay", bundleIdentifier: bundleIdentifier)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 20)
                        .padding(.leading,-15)
                    Spacer()
                }.padding()
                    .background(
                        Color(red: 0.0/255, green: 97.0/255, blue: 168.0/255)
                    ).frame(height: 60)
                VStack{
                    HStack{
                        Spacer().frame(width: 20)
                        VStack(alignment: .leading,spacing: 15){
                            Text(LocalizationManager.localizedString("Merchant Name", isSwahili: isSwahili)).foregroundColor(.black).font(.system(size: 15, weight: .regular))
                            Text(LocalizationManager.localizedString("Order Id", isSwahili: isSwahili)).foregroundColor(.black).font(.system(size: 15, weight: .regular))
                        }
                        Spacer().frame(width: 20)
                        VStack(spacing: 15){
                            Text(":")
                            Text(":")
                        }
                        Spacer().frame(width: 20)
                        
                        VStack(alignment: .leading,spacing: 15){
                            Text(first_name + " " + last_name).foregroundColor(.black).font(.system(size: 17, weight: .bold))
                            
                            Text(order_id).foregroundColor(.black).font(.system(size: 17, weight: .bold))
                            
                        }
                        Spacer()
                    }
                }.frame(height: 80)
                    .padding(.top,5)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                    )
                    .padding(.bottom,15)
                VStack{
                    VStack{
                        HStack{
                            Text(LocalizationManager.localizedString("Total Amount", isSwahili: isSwahili)).foregroundColor(.white)
                            Spacer()
                            HStack{
                                Text(LocalizationManager.localizedString("Tsh", isSwahili: isSwahili)).foregroundColor(.white).font(.system(size: 17, weight: .bold))
                                Text(viewModel.totalAmount).foregroundColor(.white).font(.system(size: 22, weight: .heavy))
                                
                            }
                        }
                        Spacer()
                        HStack{
                            Spacer()
                            Text(LocalizationManager.localizedString("Details", isSwahili: isSwahili)).foregroundColor(.white).font(.system(size: 17, weight: .bold))
                        }.padding(.top,20)
                    }.padding(.horizontal,20).padding(.top,20)
                    DottedLine().padding(.horizontal,20).frame(height: 1)
                    VStack(spacing: 10){
                        HStack{
                            Text(LocalizationManager.localizedString("Transfer Amount", isSwahili: isSwahili)).foregroundColor(.white)
                            Spacer()
                            Text("Tsh \(String(format: "%.2f", (Double(amount) ?? 0.0)))").foregroundColor(.white)
                        }
                        HStack{
                            Text(LocalizationManager.localizedString("Platform Fee", isSwahili: isSwahili)).foregroundColor(.white)
                            Spacer()
                            Text("Tsh \(viewModel.surchargeAmount)").foregroundColor(.white)
                        }
                    }.padding(.horizontal,20)
                        .padding(.bottom,20)
                }.background(
                    Color(red: 0.0/255, green: 97.0/255, blue: 168.0/255)
                        .cornerRadius(10)
                )
                .frame(height: 200)
                .padding(.horizontal,20)
                VStack(alignment: .leading,spacing: 20) {
                    Text(LocalizationManager.localizedString("Payment Method", isSwahili: isSwahili)).font(.system(size: 15, weight: .regular)).padding(.top,10)
                    VStack(alignment: .trailing, spacing: 0) {
                        // Use the custom initializer with bundleIdentifier
                        Image(named: "tick", bundleIdentifier: bundleIdentifier)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15, height: 15)
                        
                        Image(named: "airtel_logo", bundleIdentifier: bundleIdentifier)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 20)
                    }
                    .frame(width: 100, height: 35)
                    
                    
                    Text(LocalizationManager.localizedString("Airtel Mobile Number", isSwahili: isSwahili)).font(.system(size: 15, weight: .regular))
                    ZStack(alignment: .topLeading){
                        HStack(spacing: 0){
                            
                            Text("+255")
                                .font(.system(size: 16, weight: .regular))
                                .padding(.leading,10)
                            VStack{
                                Color("#C1D3DB")
                            }.frame(width: 1,height: 29)
                                .padding(.leading,10)
                            Rectangle()
                                .fill(Color.black) // Set your desired color here
                                .frame(width: 1)
                                .padding(5)
                            TextField(LocalizationManager.localizedString("Enter Mobile Number", isSwahili: isSwahili), text: $mobileNumber)
                                .keyboardType(.phonePad)
                                .onReceive(Just(mobileNumber)) { newMobileNumber in
                                    if newMobileNumber.count > 9 {
                                        mobileNumber = String(newMobileNumber.prefix(9))
                                    }
                                }
                                .keyboardType(.decimalPad)
                            
                                .disableAutocorrection(true)
                        }
                        
                        .frame(height: 45)
                        .background(
                            RoundedRectangle(cornerRadius: 10.0)
                                .stroke(.black, lineWidth: 1.0))
                    }
                    //                    TextField("Enter Mobile Number", text: $mobileNumber)
                    //                        .keyboardType(.phonePad)
                    //                        .onReceive(Just(mobileNumber)) { newMobileNumber in
                    //                            if newMobileNumber.count > 9 {
                    //                                mobileNumber = String(newMobileNumber.prefix(9))
                    //                            }
                    //                        }
                    CustomButtonWithLoader(buttonText: "\(LocalizationManager.localizedString("Proceed to Confirm", isSwahili: isSwahili))", action: {
                        validateMobileNumber(mobileNumber: mobileNumber)
                    }, buttonColor: Color("lightPrimary"), shouldDisable: false, showIndicator: $viewModel.isLoading)
                    
                    toastManager.showToastView()
                }.padding(.horizontal,20)
                Spacer()
            }
            .background(NavigationLink(
                destination: TimerView(navigationCallback: $navigationCallback,isSwahili: isSwahili)
                    .navigationBarHidden(true), // Replace "ConfirmationView()" with your actual confirmation view
                isActive: $viewModel.isTimerViewActive,
                label: {
                    EmptyView() // EmptyView is used to create a link without any visible UI
                })
            )
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(LocalizationManager.localizedString("Alert", isSwahili: isSwahili)),
                    message: Text("\(LocalizationManager.localizedString("Please enter an amount between", isSwahili: isSwahili)) \(viewModel.minAmount) TSH -  \(viewModel.maxAmount) TSH"),
                    dismissButton: .default(
                        Text(LocalizationManager.localizedString("Dismiss", isSwahili: isSwahili)),
                        action: {
                            // Handle the dismiss button action
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                )
            }
        }.onAppear{
            viewModel.merchantId = merchant_id
            viewModel.channel_partner = channel_partner
            viewModel.srNo = srNo
            self.mobileNumber = mobile
            viewModel.amount = amount
            DispatchQueue.main.async {
                viewModel.fetchBootConfig()
            }
        }
        .navigationBarHidden(true)
    }
    // Function to validate mobile number
    func validateMobileNumber(mobileNumber: String) {
        // Use Regex to check for valid mobile number format
        let regex = "^[0-9]{9}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        isValidNumber = predicate.evaluate(with: mobileNumber)
        
        if isValidNumber {
            // If the mobile number is valid, activate the navigation to the confirmation view
            
            if Double(amount) ?? 0.0 >= Double(viewModel.minAmount) ?? 0.0 && Double(amount) ?? 0.0 <= Double(viewModel.maxAmount) ?? 0.0 {
                // Amount is within the range
                print("Amount is within the range")
                viewModel.generatePayIndexEnc(strAmount: amount, firstName: first_name, lastName: last_name, merchantID: viewModel.merchantId, mobile: mobileNumber, strOrderId: order_id, mer_dom: viewModel.baseURL, user_name: viewModel.userName,password: viewModel.password)
            } else {
                // Amount is not within the range
                showAlert = true
            }
            
        } else {
            ToastManager.shared.show(message: (LocalizationManager.localizedString("Please enter a valid mobile number", isSwahili: isSwahili)), duration: 2.0)
        }
    }
}
struct DottedLine: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                // Create a path for a horizontal dotted line
                path.move(to: CGPoint(x: 0, y: height / 2))
                path.addLine(to: CGPoint(x: width, y: height / 2))
            }
            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
            .foregroundColor(Color.white)
        }
    }
}
struct CustomButton: View {
    var title: LocalizedStringKey
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            
                Text(title)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(Color(red: 0.0/255, green: 97.0/255, blue: 168.0/255))
               // .background(Color("lightPrimary"))
                .cornerRadius(10)
            
        }
    }
}
struct CustomButtonPlainBlue: View {
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
          
                Text(title)
                    .foregroundColor(Color(red: 0.0/255, green: 97.0/255, blue: 168.0/255))
                    .padding(.horizontal,20)
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
            
        }
    }
}

struct CustomButtonWhite: View {
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
//                .font(.custom(FontsManager.OpenSans.Bold, fixedSize: 18))
                .foregroundColor(Color(red: 0.0/255, green: 97.0/255, blue: 168.0/255))
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 45)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke((Color(red: 0.0/255, green: 97.0/255, blue: 168.0/255)), lineWidth: 1) // Set the blue stroke color and width
                )
        }
    }
}


class ToastManager: ObservableObject {
    static let shared = ToastManager()

    @Published private var toastQueue: [Toast] = []

    func show(message: String, duration: TimeInterval = 2.0) {
        let toast = Toast(message: message, duration: duration)
        toastQueue.append(toast)
        
        // Remove the toast after the specified duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.removeToast(toast)
        }
    }

    private func removeToast(_ toast: Toast) {
        if let index = toastQueue.firstIndex(of: toast) {
            toastQueue.remove(at: index)
        }
    }
    
    func showToastView() -> some View {
        ForEach(toastQueue, id: \.self) { toast in
            ToastView(message: toast.message, duration: toast.duration)
        }
    }
}

struct ToastView: View {
    let message: String
    let duration: TimeInterval

    var body: some View {
        HStack(alignment: .center){
            Text(message)
                .padding()
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(10)
                .animation(.easeInOut(duration: duration), value: message)
        }
    }
}
struct Toast: Identifiable, Hashable {
    let id = UUID()
    let message: String
    let duration: TimeInterval
}
extension Image {
    init(named imageName: String, bundleIdentifier: String) {
        if let bundle = Bundle(identifier: bundleIdentifier) {
            if let uiImage = UIImage(named: imageName, in: bundle, compatibleWith: nil) {
                self.init(uiImage: uiImage)
            } else {
                // Fallback if the image is not found
                self.init(systemName: "questionmark")
            }
        } else {
            // Fallback if the bundle is not found
            self.init(systemName: "questionmark")
        }
    }
}
