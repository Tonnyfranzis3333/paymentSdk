//
//  BootConfigModel.swift
//  
//
//  Created by Tonny Franzis on 12/01/24.
//

import Foundation
struct BootConfigResponse: Codable {
    let data: BootConfigData

    enum CodingKeys: String, CodingKey {
        case data = "DATA"
    }
}

struct BootConfigData: Codable {
    let banks: String
    let baseURL: String
    let clientID, clientSecret, mername, password: String
    let requestType, secretKey, surchargeFlag, username: String

    enum CodingKeys: String, CodingKey {
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
