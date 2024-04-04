//
//  payIndexModel.swift
//  TimerWithLoader
//
//  Created by Tonny Franzis on 10/01/24.
//

import Foundation
struct payIndexModel: Codable {
    let status: String
    let message: String
    let data: payIndexData
}

struct payIndexData: Codable {
    let transactionPaymentStatus: String?
    let merchantId: String?
    let orderId: String?
    let apTransactionId: String?
    let transactionMode: String?
    let chmod: String?
    let amount: String?
    let currencyCode: String?
    let transactionStatus: Int?
    let bankResponseMsg: String?
    let customerName: String?
    let customerPhone: String?
    let customerEmail: String?
    let transactionType: Int?
    let risk: String?
    let customVar: String?
    let token: String?
    let uid: String?
    let transactionTime: String?
    let surchargeAmount: String?
    let cardType: String?
    let apSecurehash: String?

    enum CodingKeys: String, CodingKey {
        case transactionPaymentStatus = "transaction_payment_status"
        case merchantId = "merchant_id"
        case orderId = "orderid"
        case apTransactionId = "ap_transactionid"
        case transactionMode = "txn_mode"
        case chmod
        case amount
        case currencyCode = "currency_code"
        case transactionStatus = "transaction_status"
        case bankResponseMsg = "bank_response_msg"
        case customerName = "customer_name"
        case customerPhone = "customer_phone"
        case customerEmail = "customer_email"
        case transactionType = "transaction_type"
        case risk
        case customVar = "custom_var"
        case token
        case uid
        case transactionTime = "transaction_time"
        case surchargeAmount = "surcharge_amount"
        case cardType = "card_type"
        case apSecurehash = "ap_securehash"
    }
}
