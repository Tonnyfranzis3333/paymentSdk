//
//  LocalizationManager.swift
//  AirpayPaymentSdk
//
//  Created by Tonny Franzis on 21/03/24.
//

import Foundation

struct LocalizationManager {
    static func localizedString(_ key: String, isSwahili: Bool) -> String {
        if isSwahili {
            return swahiliStrings[key] ?? ""
        } else {
            return englishStrings[key] ?? ""
        }
    }
    
    static let englishStrings: [String: String] = [
        "Merchant Name": "Merchant Name",
        "Order Id" : "Order Id",
        "Total Amount" : "Total Amount",
        "Tsh" : "Tsh",
        "Details" : "Details",
        "Transfer Amount" : "Transfer Amount",
        "Platform Fee" : "Platform Fee",
        "Payment Method" : "Payment Method",
        "Airtel Mobile Number" : "Airtel Mobile Number",
        "Enter Mobile Number" : "Enter Mobile Number",
        "Proceed to Confirm" : "Proceed to Confirm",
        "Please enter a valid mobile number" : "Please enter a valid mobile number",
        "Order ID" : "Order ID",
        "Open your Airtel Money wallet to approve the payment request before the timer runs out" : "Open your Airtel Money wallet to approve the payment request before the timer runs out",
        "Note : Do not hit back button or close this screen until the transaction is complete" : "Note : Do not hit back button or close this screen until the transaction is complete",
        "Cancel Payment" : "Cancel Payment",
        "Transaction Successfull" : "Transaction Successfull",
        "Are you sure you want to cancel the payment?" : "Are you sure you want to cancel the payment?",
        "This payment request will get cancelled only if you have not completed the payment on Airtel Money wallet app" : "This payment request will get cancelled only if you have not completed the payment on Airtel Money wallet app",
        "Yes, Cancel" : "Yes, Cancel",
        "No" : "No",
        "Thank you" : "Thank you",
        "Sorry" : "Sorry",
        "Your Payment of TSh" : "Your Payment of TSh",
        "was Successful" : "was Successful",
        "has Failed" : "has Failed",
        "Failed Reason: External Transactions Already Exist" : "Failed Reason: External Transactions Already Exist",
        "Please enter an amount between" : "Please enter an amount between",
        "Dismiss" : "Dismiss",
        "Alert":"Alert"
    ]
    
    static let swahiliStrings: [String: String] = [
        "Merchant Name": "Jina la mfanyabiashara",
        "Order Id": "Kitambulisho cha agizo",
        "Total Amount" : "Jumla",
        "Tsh" : "Tsh",
        "Details" : "Maelezo",
        "Transfer Amount" : "Kiasi cha Uhamisho",
        "Platform Fee" : "Ada ya Jukwaa",
        "Payment Method" : "Njia ya malipo",
        "Airtel Mobile Number" : "Nambari ya simu ya Airtel",
        "Enter Mobile Number" : "Weka Nambari ya Simu",
        "Proceed to Confirm" : "Endelea Kuthibitisha",
        "Please enter a valid mobile number" : "Tafadhali weka nambari halali ya simu",
        "Order ID" : "Kitambulisho cha agizo",
        "Open your Airtel Money wallet to approve the payment request before the timer runs out" : "Fungua pochi yako ya Airtel Money ili kuidhinisha ombi la malipo kabla ya kipima muda kuisha",
        "Note : Do not hit back button or close this screen until the transaction is complete" : "Kumbuka : Usibonyeze kitufe cha nyuma au ufunge skrini hii hadi muamala ukamilike",
        "Cancel Payment" : "Ghairi Malipo",
        "Transaction Successfull" : "Muamala Umefaulu",
        "Are you sure you want to cancel the payment?" : "Je, una uhakika unataka kughairi malipo?",
        "This payment request will get cancelled only if you have not completed the payment on Airtel Money wallet app" : "Ombi hili la malipo litaghairiwa ikiwa tu hujakamilisha malipo kwenye programu ya Airtel Money wallet",
        "Yes, Cancel" : "Ndiyo, Ghairi",
        "No" : "Hapana",
        "Thank you" : "Asante",
        "Sorry" : "Pole",
        "Your Payment of TSh" : "Malipo yako ya TSh",
        "was Successful" : "Ilifanikiwa",
        "has Failed" : "Imeshindwa",
        "Failed Reason: External Transactions Already Exist" : "Sababu Iliyoshindikana: Miamala ya Nje Tayari Ipo",
        "Please enter an amount between" : "Tafadhali weka kiasi kati ya",
        "Dismiss" : "Ondoa",
        "Alert":"Tahadhari"
    ]
}
