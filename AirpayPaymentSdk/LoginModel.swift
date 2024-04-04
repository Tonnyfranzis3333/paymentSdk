//
//  LoginModel.swift
//  TimerWithLoader
//
//  Created by Tonny Franzis on 03/01/24.
//

import Foundation
//struct BootConfigResponse: Codable {    
//    let data: BootConfigData
//
//    enum CodingKeys: String, CodingKey {
//        case data = "DATA"
//    }
//}
//
//struct BootConfigData: Codable {
//    let banks: String
//    let baseURL: String
//    let clientID, clientSecret, mername, password: String
//    let requestType, secretKey, surchargeFlag, username: String
//
//    enum CodingKeys: String, CodingKey {
//        case banks = "BANKS"
//        case baseURL = "BASEURL"
//        case clientID = "CLIENT_ID"
//        case clientSecret = "CLIENT_SECRET"
//        case mername = "MERNAME"
//        case password = "PASSWORD"
//        case requestType = "REQUEST_TYPE"
//        case secretKey = "SECRETKEY"
//        case surchargeFlag = "SURCHARGE_FLAG"
//        case username = "USERNAME"
//    }
//}
//
//struct AllowPayMode: Codable {
//    let mmoney: String?
//
//    enum CodingKeys: String, CodingKey {
//        case mmoney = "mmoney"
//    }
//}

struct BootConfigResponse: Codable {
    let data: BootConfigData?

    enum CodingKeys: String, CodingKey {
        case data = "DATA"
    }
}

struct BootConfigData: Codable {
    let allowPayMode: AllowPayMode?
    let banks: String?
    let baseURL: String?
    let clientID: String?
    let clientSecret: String?
    let mername: String?
    let password: String?
    let requestType: String?
    let secretKey: String?
    let surchargeFlag: String?
    let username: String?

    enum CodingKeys: String, CodingKey {
        case allowPayMode = "ALLOWPAYMODE"
        case banks = "BANKS"
        case baseURL = "BASEURL"
        case clientID = "CLIENT_ID"
        case clientSecret = "CLIENT_SECRET"
        case mername = "MERNAME"
        case password = "PASSWORD"
        case requestType = "REQUEST_TYPE"
        case secretKey = "SECRETKEY"
        case surchargeFlag = "SURCHARGE_FLAG"
        case username = "USERNAME"
    }
}

struct AllowPayMode: Codable {
    let mmoney: MMoney?

    enum CodingKeys: String, CodingKey {
        case mmoney = "mmoney"
    }
}
struct MMoney: Codable {
    let bank: [Bank]?

    struct Bank: Codable {
        let dispnm: String?
        let maxamt: String?
        let minamt: String?

        enum CodingKeys: String, CodingKey {
            case dispnm = "DISPNM"
            case maxamt = "MAXAMT"
            case minamt = "MINAMT"
        }
    }

    enum CodingKeys: String, CodingKey {
        case bank = "BANK"
    }
}
// Your JSON parsing code remains the same

