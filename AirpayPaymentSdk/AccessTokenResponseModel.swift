//
//  AccessTokenResponseModel.swift
//  TimerWithLoader
//
//  Created by Tonny Franzis on 09/01/24.
//

import Foundation

struct AccessTokenResponse: Codable {
    let data: AccessTokenData
}

struct AccessTokenData: Codable {
    let accessToken: String
    let expiresIn: Int
    let tokenType: String
    let scope: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
        case scope
    }
}
