//
//  PaymentResponseModel.swift
//  AirpayPaymentSdk
//
//  Created by Tonny Franzis on 16/01/24.
//

import Foundation
import Foundation

public struct TransactionStatusModel: Codable {
    public let cancelStatus : Bool?
    public let data: TransactionData?
}

public struct TransactionData: Codable {
    public let transactionPaymentStatus: String?
    public let merchantID: String?
    public let orderID: String?
    public let apTransactionID: String?
    public let transactionMode: String?
    public let chmod: String?
    public let amount: String?
    public let currencyCode: String?
    public let transactionStatus: Int?
    public let transactionMessage: String?
    public let bankResponseMessage: String?
    public let customerName: String?
    public let customerPhone: String?
    public let customerEmail: String?
    public let transactionType: Int?
    public let risk: String?
    public let customVar: String?
    public let token: String?
    public let uid: String?
    public let transactionTime: String?
    public let surchargeAmount: String?
    public let cardType: String?
    public let apSecureHash: String?

    enum CodingKeys: String, CodingKey {
        case transactionPaymentStatus = "transaction_payment_status"
        case merchantID = "merchant_id"
        case orderID = "orderid"
        case apTransactionID = "ap_transactionid"
        case transactionMode = "txn_mode"
        case chmod
        case amount
        case currencyCode = "currency_code"
        case transactionStatus = "transaction_status"
        case transactionMessage = "message"
        case bankResponseMessage = "bank_response_msg"
        case customerName = "customer_name"
        case customerPhone = "customer_phone"
        case customerEmail = "customer_email"
        case transactionType = "transaction_type"
        case risk
        case customVar
        case token
        case uid
        case transactionTime = "transaction_time"
        case surchargeAmount = "surcharge_amount"
        case cardType
        case apSecureHash = "ap_securehash"
    }
}
