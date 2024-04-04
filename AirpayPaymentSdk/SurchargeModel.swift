//
//  SurchargeModel.swift
//  AirpayPaymentSdk
//
//  Created by Tonny Franzis on 05/02/24.
//

import Foundation

struct SurchargeModel: Codable {
    let data: SurchargeData
}

struct SurchargeData: Codable {
    let surchargeAmount: String?
    let bankStatus: String?

    enum CodingKeys: String, CodingKey {
        case surchargeAmount = "surcharge_amount"
        case bankStatus = "bank_status"
    }
}
