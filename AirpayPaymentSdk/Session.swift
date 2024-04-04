//
//  Session.swift
//  swift-ui-base
//
//  Created by Germán Stábile on 4/1/20.
//  Copyright © 2020 Rootstrap. All rights reserved.
//

import Foundation

struct Session: Codable {
  

 
  var accessToken: String?
   
 // var expiry: Date?
  
  private enum CodingKeys: String, CodingKey {
    
    case accessToken = "access_token"
     
 //   case expiry
  }
  

  
  init?(headers: [String: Any]) {
    //  print(headers)
//    var loweredHeaders = headers
//    loweredHeaders.lowercaseKeys()
//    guard let stringHeaders = loweredHeaders as? [String: String] else {
//      return nil
//    }
//    if let expiryString = stringHeaders[HTTPHeader.expiry.rawValue],
//      let expiryNumber = Double(expiryString) {
//      expiry = Date(timeIntervalSince1970: expiryNumber)
//    }
   
    accessToken = headers["token"]! as? String
      
   
  }
}
