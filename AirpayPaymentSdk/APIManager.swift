//
//  APIManager.swift
//  TimerWithLoader
//
//  Created by Tonny Franzis on 02/01/24.
//

import Alamofire
import SwiftUI
class APIManager {
    static let shared = APIManager()
    let baseurl = "https://tz-payments.airpay.ninja"
    //    "STAGING_URL", "\"https://tz-payments.airpay.ninja\\"")
    ///"BASE_URL", "\"https://payments.airpay.tz\\"")
    
    class func getSurcharge(merchant_id:String,checksum:String,privatekey:String,amount:String,key: String,success: @escaping (_ res:SurchargeModel) -> Void,
                        failure: @escaping (_ error: Error) -> Void) {
        let parameters = [
            "amount": amount,
            "bank_code": "",
            "card_bin": "",
            "chmod": "mmoney"
        ]
        
        print(parameters,"$$$$")
        
        let jsonStr = try? parameters.toJson()
        guard let jsonStr else {return}
        print(jsonStr)
        
        print(key)
        print(key.count)
        let iv = randomString(length: 16)
        let aes256 = AES(key: key, iv: iv)
        let encryptedReqBody = aes256?.encrypt(string: jsonStr)
        
        guard let encbase64 =  encryptedReqBody?.base64EncodedString() else { return  }
        let encdata = iv + encbase64
        
        print(encdata)
        
        var queryParameter = [String: Any]()
        queryParameter["merchant_id"] = merchant_id
        queryParameter["checksum"] = checksum
        queryParameter["privatekey"] = privatekey
        queryParameter["encdata"] = encdata
        
        
        print(queryParameter)
        print(iv,"initial vector")
        let url = "\(shared.baseurl)/sdk/surcharge.php"
        print(url)
        AF.request(url, method: .post, parameters: queryParameter)
            .validate()
            .responseJSON { result in
                if let jsonData = result.data {
                    do {
                        if let jsonResponse = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                            var valueToUse: String?
                            
                            print(jsonResponse)
                            // Check if the response contains 'query' or 'response'
                            if let query = jsonResponse["query"] as? String {
                                valueToUse = query
                            } else if let response = jsonResponse["response"] as? String {
                                valueToUse = response
                            }
                            print(valueToUse ?? "")
                            // Process the obtained value (query or response)
                            if let value = valueToUse {
                                let filterQuoteencValDataStr = value.replacingOccurrences(of: "\"", with: "")
                                print(filterQuoteencValDataStr,"the filtered string")
                                guard let filteredData = filterQuoteencValDataStr.data(using: .utf8)else{return}
                                let encValueWithoutFirst16 = filteredData.dropFirst(16)
                                
                                let ivFromResponse = filteredData.prefix(16)
                                print(ivFromResponse)
                                //                            let DecryKey = "wawrewruthaglswuflgipififldrazlv"
                                //   print(encValueWithoutFirst16,"encValueWithoutFirst16")
                                //  print(ivFromResponse)
                                guard let ivStr = String(data: ivFromResponse, encoding: .utf8) else{return}
                                print(ivStr)
                                if let newdata = Data(base64Encoded: encValueWithoutFirst16) {
                                    let aes256DEcry = AES(key: key, iv: ivStr ?? "")
                                    
                                    if  let decryptedData =  aes256DEcry?.decrypt(data: newdata){
                                        let trimmedDecryptedData = decryptedData.trimmingCharacters(in: .whitespacesAndNewlines)
                                        guard let updatedData = trimmedDecryptedData.data(using: .utf8) else{return}
                                        
                                        
                                        guard let upStr = String(data: updatedData, encoding: .utf8) else{return}
                                        print(upStr,"upStr")
                                        let upstrReplaced =  upStr.replacingOccurrences(of: "source", with: "sourceKey")
                                        print(upstrReplaced,"upstrReplaced")
                                        print(decryptedData,"the decrypted data<=============================")
                                        if let jsonData = upStr.data(using: .utf8) {
                                            do {
                                                let accessTokenResponse = try JSONDecoder().decode(SurchargeModel.self, from: jsonData)
                                                // Access your AccessTokenResponse model here
                                                success(accessTokenResponse)
                                            } catch {
                                                print("JSON decoding failed: \(error.localizedDescription)")
                                                failure(error)
                                            }
                                        } else {
                                            print("Invalid JSON data.")
                                        }
                                        
                                    }else{
                                        print("decryption  failed")
                                    }
                                } else {
                                    
                                    print("Decoding failed.")
                                }
                                
                            } else {
                                print("Neither 'query' nor 'response' found in the JSON.")
                                // Handle the case where neither 'query' nor 'response' is available
                            }
                        } else {
                            print("Failed to parse JSON.")
                        }
                    } catch {
                        print("Error: \(error.localizedDescription)")
                    }
                } else {
                    print("No data found in the response.")
                }
            }
    }
    
    class func tokenAPI(merchant_id:String,checksum:String,privatekey:String,strClientId: String,strClientSecret: String, key: String,success: @escaping (_ res:AccessTokenResponse) -> Void,
                        failure: @escaping (_ error: Error) -> Void) {
        let parameters = [
            "merchant_id": merchant_id,
            "client_id": strClientId,
            "client_secret": strClientSecret,
            "grant_type": "client_credentials"
        ] as [String : Any]
        print(parameters,"$$$$")
        
        let jsonStr = try? parameters.toJson()
        guard let jsonStr else {return}
        print(jsonStr)
        
        print(key)
        print(key.count)
        let iv = randomString(length: 16)
        let aes256 = AES(key: key, iv: iv)
        let encryptedReqBody = aes256?.encrypt(string: jsonStr)
        
        guard let encbase64 =  encryptedReqBody?.base64EncodedString() else { return  }
        let encdata = iv + encbase64
        
        print(encdata)
        
        var queryParameter = [String: Any]()
        queryParameter["merchant_id"] = merchant_id
        queryParameter["checksum"] = checksum
        queryParameter["privatekey"] = privatekey
        queryParameter["encdata"] = encdata
        
        
        print(queryParameter)
        print(iv,"initial vector")
        let url = "\(shared.baseurl)/pay/v1/api/oauth2/index.php"
        AF.request(url, method: .post, parameters: queryParameter)
            .validate()
            .responseJSON { result in
                if let jsonData = result.data {
                    do {
                        if let jsonResponse = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                            var valueToUse: String?
                            
                            print(jsonResponse)
                            // Check if the response contains 'query' or 'response'
                            if let query = jsonResponse["query"] as? String {
                                valueToUse = query
                            } else if let response = jsonResponse["response"] as? String {
                                valueToUse = response
                            }
                            print(valueToUse ?? "")
                            // Process the obtained value (query or response)
                            if let value = valueToUse {
                                let filterQuoteencValDataStr = value.replacingOccurrences(of: "\"", with: "")
                                print(filterQuoteencValDataStr,"the filtered string")
                                guard let filteredData = filterQuoteencValDataStr.data(using: .utf8)else{return}
                                let encValueWithoutFirst16 = filteredData.dropFirst(16)
                                
                                let ivFromResponse = filteredData.prefix(16)
                                print(ivFromResponse)
                                //                            let DecryKey = "wawrewruthaglswuflgipififldrazlv"
                                //   print(encValueWithoutFirst16,"encValueWithoutFirst16")
                                //  print(ivFromResponse)
                                guard let ivStr = String(data: ivFromResponse, encoding: .utf8) else{return}
                                print(ivStr)
                                if let newdata = Data(base64Encoded: encValueWithoutFirst16) {
                                    let aes256DEcry = AES(key: key, iv: ivStr ?? "")
                                    
                                    if  let decryptedData =  aes256DEcry?.decrypt(data: newdata){
                                        let trimmedDecryptedData = decryptedData.trimmingCharacters(in: .whitespacesAndNewlines)
                                        guard let updatedData = trimmedDecryptedData.data(using: .utf8) else{return}
                                        
                                        
                                        guard let upStr = String(data: updatedData, encoding: .utf8) else{return}
                                        print(upStr,"upStr")
                                        let upstrReplaced =  upStr.replacingOccurrences(of: "source", with: "sourceKey")
                                        print(upstrReplaced,"upstrReplaced")
                                        print(decryptedData,"the decrypted data<=============================")
                                        if let jsonData = upStr.data(using: .utf8) {
                                            do {
                                                let accessTokenResponse = try JSONDecoder().decode(AccessTokenResponse.self, from: jsonData)
                                                // Access your AccessTokenResponse model here
                                                success(accessTokenResponse)
                                            } catch {
                                                print("JSON decoding failed: \(error.localizedDescription)")
                                                failure(error)
                                            }
                                        } else {
                                            print("Invalid JSON data.")
                                        }
                                        
                                    }else{
                                        print("decryption  failed")
                                    }
                                } else {
                                    
                                    print("Decoding failed.")
                                }
                                
                            } else {
                                print("Neither 'query' nor 'response' found in the JSON.")
                                // Handle the case where neither 'query' nor 'response' is available
                            }
                        } else {
                            print("Failed to parse JSON.")
                        }
                    } catch {
                        print("Error: \(error.localizedDescription)")
                    }
                } else {
                    print("No data found in the response.")
                }
            }
    }
    
    class func payIndex(merchant_id:String,checksum:String,privatekey:String,buyer_firstname:String,buyer_lastname:String,buyer_phone:String,key: String,mer_dom64:String,orderid:String,tokenValue:String,amount:String,success: @escaping (_ res:payIndexModel) -> Void,
                        failure: @escaping (_ error: Error) -> Void) {
        let parameters = [
            "amount": amount,
            "arpyVer": "4",
            "bankcode": "AIRTEL",
            "buyer_address": "",
            "buyer_city": "",
            "buyer_country": "",
            "buyer_email": "",
            "buyer_firstname": buyer_firstname,
            "buyer_lastname": buyer_lastname,
            "buyer_phone": buyer_phone,
            "buyer_pincode": "",
            "buyer_state": "",
            "channel": "mmoney",
            "chmod": "",
            "currency_code": "834",
            "iso_currency": "TZS",
            "merchant_id": merchant_id,
            "mer_dom": mer_dom64,
            "orderid": orderid
        ] as [String : Any]
        
        print(parameters,"$$$$")
        
        let jsonStr = try? parameters.toJson()
        guard let jsonStr else {return}
        print(jsonStr)
        
        print(key)
        print(key.count)
        let iv = randomString(length: 16)
        let aes256 = AES(key: key, iv: iv)
        let encryptedReqBody = aes256?.encrypt(string: jsonStr)
        
        guard let encbase64 =  encryptedReqBody?.base64EncodedString() else { return  }
        let encdata = iv + encbase64
        
        print(encdata)
        
        var queryParameter = [String: Any]()
        queryParameter["merchant_id"] = merchant_id
        queryParameter["checksum"] = checksum
        queryParameter["privatekey"] = privatekey
        queryParameter["encdata"] = encdata
        
        
        print(queryParameter)
        print(iv,"initial vector")
        let url = "\(shared.baseurl)/pay/v1/api/seamless/index.php?token=\(tokenValue)"
        print(url)
        AF.request(url, method: .post, parameters: queryParameter)
            .validate()
            .responseJSON { result in
                if let jsonData = result.data {
                    do {
                        if let jsonResponse = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                            var valueToUse: String?
                            
                            print(jsonResponse)
                            // Check if the response contains 'query' or 'response'
                            if let query = jsonResponse["query"] as? String {
                                valueToUse = query
                            } else if let response = jsonResponse["response"] as? String {
                                valueToUse = response
                            }
                            print(valueToUse ?? "")
                            // Process the obtained value (query or response)
                            if let value = valueToUse {
                                let filterQuoteencValDataStr = value.replacingOccurrences(of: "\"", with: "")
                                print(filterQuoteencValDataStr,"the filtered string")
                                guard let filteredData = filterQuoteencValDataStr.data(using: .utf8)else{return}
                                let encValueWithoutFirst16 = filteredData.dropFirst(16)
                                
                                let ivFromResponse = filteredData.prefix(16)
                                print(ivFromResponse)
                                //                            let DecryKey = "wawrewruthaglswuflgipififldrazlv"
                                //   print(encValueWithoutFirst16,"encValueWithoutFirst16")
                                //  print(ivFromResponse)
                                guard let ivStr = String(data: ivFromResponse, encoding: .utf8) else{return}
                                print(ivStr)
                                if let newdata = Data(base64Encoded: encValueWithoutFirst16) {
                                    let aes256DEcry = AES(key: key, iv: ivStr ?? "")
                                    
                                    if  let decryptedData =  aes256DEcry?.decrypt(data: newdata){
                                        let trimmedDecryptedData = decryptedData.trimmingCharacters(in: .whitespacesAndNewlines)
                                        guard let updatedData = trimmedDecryptedData.data(using: .utf8) else{return}
                                        
                                        
                                        guard let upStr = String(data: updatedData, encoding: .utf8) else{return}
                                        print(upStr,"upStr")
                                        let upstrReplaced =  upStr.replacingOccurrences(of: "source", with: "sourceKey")
                                        print(upstrReplaced,"upstrReplaced")
                                        print(decryptedData,"the decrypted data<=============================")
                                        if let jsonData = upStr.data(using: .utf8) {
                                            do {
                                                let accessTokenResponse = try JSONDecoder().decode(payIndexModel.self, from: jsonData)
                                                // Access your AccessTokenResponse model here
                                                success(accessTokenResponse)
                                            } catch {
                                                print("JSON decoding failed: \(error.localizedDescription)")
                                                failure(error)
                                            }
                                        } else {
                                            print("Invalid JSON data.")
                                        }
                                        
                                    }else{
                                        print("decryption  failed")
                                    }
                                } else {
                                    
                                    print("Decoding failed.")
                                }
                                
                            } else {
                                print("Neither 'query' nor 'response' found in the JSON.")
                                // Handle the case where neither 'query' nor 'response' is available
                            }
                        } else {
                            print("Failed to parse JSON.")
                        }
                    } catch {
                        print("Error: \(error.localizedDescription)")
                    }
                } else {
                    print("No data found in the response.")
                }
            }
    }
    
    class func paymentResponse(
        merchantID: String,
        checksum: String,
        privateKey: String,
        key: String,
        orderID: String,
        timeValue: String,
        success: @escaping (_ res: TransactionStatusModel) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        // Create parameters dictionary
        let parameters = [
            "datetime": timeValue,
            "orderid": orderID,
            "response_type": "JSON"
        ]

        // Convert parameters to JSON string
        guard let jsonStr = try? parameters.toJson() else {
            print("Failed to convert parameters to JSON.")
            return
        }

        // Encrypt the JSON string
        guard let (iv, encdata) = encryptData(jsonStr, key: key) else {
            print("Encryption failed.")
            return
        }

        // Prepare request parameters
        var queryParameter = [
            "merchant_id": merchantID,
            "checksum": checksum,
            "privatekey": privateKey,
            "encdata": encdata
        ]

        // Make the network request
        let url = "\(shared.baseurl)/sdk/a.php"
        AF.request(url, method: .post, parameters: queryParameter)
            .validate()
            .responseJSON { response in
                handleNetworkResponse(response, key: key, success: success, failure: failure)
            }
    }

    private class func encryptData(_ data: String, key: String) -> (String, String)? {
        let iv = randomString(length: 16)
        guard let aes256 = AES(key: key, iv: iv),
              let encryptedReqBody = aes256.encrypt(string: data),
              let encbase64 = encryptedReqBody.base64EncodedString() as? String else {
            print("Encryption failed.")
            return nil
        }

        let encdata = iv + encbase64
        return (iv, encdata)
    }

    private class func handleNetworkResponse(
        _ response: AFDataResponse<Any>,
        key: String,
        success: @escaping (_ res: TransactionStatusModel) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        switch response.result {
        case .success(let value):
            guard let jsonResponse = value as? [String: Any],
                  let encryptedValue = jsonResponse["response"] as? String else {
                print("Invalid response format.")
                return
            }

            if let decryptedData = decryptEncryptedValue(encryptedValue, key: key) {
                handleDecryptedData(decryptedData, success: success, failure: failure)
            } else {
                print("Decryption failed.")
                failure(NSError(domain: "", code: 0, userInfo: nil))
            }

        case .failure(let error):
            print("Request failed with error: \(error.localizedDescription)")
            failure(error)
        }
    }

    private class func decryptEncryptedValue(_ encryptedValue: String, key: String) -> Data? {
        let ivFromResponse = String(encryptedValue.prefix(16))
        let encValueWithoutFirst16 = encryptedValue.dropFirst(16)

        guard let ivStr = ivFromResponse.data(using: .utf8),
              let newdata = Data(base64Encoded: String(encValueWithoutFirst16)),
              let aes256DEcry = AES(key: key, iv: String(data: ivStr, encoding: .utf8) ?? ""),
              let decryptedString = aes256DEcry.decrypt(data: newdata),
              let decryptedData = decryptedString.data(using: .utf8) else {
            // Handle the case where any of the optionals is nil
            print("Decryption failed or optional values are nil.")
            return nil
        }

        return decryptedData
    }




    private class func handleDecryptedData(
        _ decryptedData: Data,
        success: @escaping (_ res: TransactionStatusModel) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        let trimmedDecryptedData: String

        if let decryptedString = String(data: decryptedData, encoding: .utf8) {
            trimmedDecryptedData = decryptedString.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            print("Failed to convert decrypted data to string.")
            failure(NSError(domain: "", code: 0, userInfo: nil))
            return
        }

        guard let updatedData = trimmedDecryptedData.data(using: .utf8),
              let upStr = String(data: updatedData, encoding: .utf8) else {
            print("Invalid decrypted data format.")
            failure(NSError(domain: "", code: 0, userInfo: nil))
            return
        }
        
        let upStrReplaced = upStr.replacingOccurrences(of: "source", with: "sourceKey")
print(upStrReplaced)
        guard let jsonData = upStrReplaced.data(using: .utf8) else {
            print("Invalid JSON data.")
            failure(NSError(domain: "", code: 0, userInfo: nil))
            return
        }

        do {
            let transactionStatusModel = try JSONDecoder().decode(TransactionStatusModel.self, from: jsonData)
            success(transactionStatusModel)
        } catch {
            print("JSON decoding failed: \(error.localizedDescription)")
            failure(error)
        }
    }

    
//    func parseAccessTokenData(from decryptedData: String) -> AccessTokenResponse? {
//        guard let data = decryptedData.data(using: .utf8) else {
//            print("Failed to convert decryptedData to Data")
//            return nil
//        }
//        
//        do {
//            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
//            
//            let accessTokenResponse = try decoder.decode(AccessTokenResponse.self, from: data)
//            return accessTokenResponse
//        } catch {
//            print("Error parsing AccessTokenResponse: \(error.localizedDescription)")
//            print("Decrypted data: \(decryptedData)")
//            return nil
//        }
//    }
    
    
    
    
    
    class func bootConfigAPI(merchantID:String,srno:String,channel_partner:String,success: @escaping (_ res:BootConfigResponse) -> Void,
                             failure: @escaping (_ error: Error) -> Void) {
        let url =  "/pos/index-api.php"
        let parameters = [
            "merid": merchantID,
            "reqtype": "bootconfig",
            "srno": srno,
            "channel_partner" : channel_partner
        ] as [String : Any]
        print(parameters,"$$$$")
        
        let jsonStr = try? parameters.toJson()
        guard let jsonStr else {return}
        print(jsonStr)
        let Enckey256   = "wawrewruthaglswuflgipififldrazlv"
        let iv = randomString(length: 16)
        let aes256 = AES(key: Enckey256, iv: iv)
        let encryptedReqBody = aes256?.encrypt(string: jsonStr)
        
        guard let encbase64 =  encryptedReqBody?.base64EncodedString() else { return  }
        let encrpRequest = iv + encbase64
        let queryParameter = [
            "query":"\(encrpRequest)"
        ]
        
        print(iv,"initial vector")
        APIClientSdk.request(.post, url: url, passedKey: "", params: queryParameter, success: { response, headers in
            print(response, "response <++++++++++")
            
            if let bootConfigResponse = APIManager.saveConficData(fromResponse: response) {
                // Pass the profileModel to the success closure
                success(bootConfigResponse)
            }
            
        }, failure: { error in
            failure(error)
            print("Failed login API call")
        })
        
        
    }
    
    class func saveConficData(fromResponse response: [String: Any]) -> BootConfigResponse? {
        
        if let data = response["DATA"] as? [String: Any],
           let allowPayMode = data["ALLOWPAYMODE"] as? [String: Any],
           let mmoney = allowPayMode["mmoney"] as? [String: Any],
           let bankArray = mmoney["BANK"] as? [[String: Any]] {
            for bank in bankArray {
                if let dispnm = bank["DISPNM"] as? String, dispnm == "Airtel",
                   let maxamt = bank["MAXAMT"] as? String {
                    print("Maximum amount for Airtel bank under mmoney: \(maxamt)")
                }
            }
        }
        guard let jsonData = response["DATA"] as? [String: Any] else {
            print("Failed to access 'data' key in the response.")
            return nil
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonData, options: [])
            let decoder = JSONDecoder()
            let bootConfigData = try decoder.decode(BootConfigData.self, from: jsonData)
            let bootConfigResponse = BootConfigResponse(data: bootConfigData)
            return bootConfigResponse
        } catch {
            print("Failed to decode JSON into ProfileModel: \(error)")
            return nil
        }
    }
    
//    class func saveConficData(fromResponse response: [String: Any]) -> BootConfigResponse? {
//        var bootConfigResponse = BootConfigResponse(statusMsg: response["STATUSMSG"] as? String, status: response["STATUS"] as? Int, data: nil)
//        guard let jsonData = response["DATA"] as? [String: Any] else {
//            return bootConfigResponse
//        }
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: jsonData, options: [])
//            let decoder = JSONDecoder()
//            var bootConfigData = try decoder.decode(BootConfigData.self, from: jsonData)
//            bootConfigResponse = BootConfigResponse(statusMsg: bootConfigResponse.statusMsg, status: bootConfigResponse.status, data: bootConfigResponse.data)
//            return bootConfigResponse
//        } catch {
//            print("Failed to decode JSON into bootConfigResponse: \(error)")
//            return nil
//        }
//    }
}

