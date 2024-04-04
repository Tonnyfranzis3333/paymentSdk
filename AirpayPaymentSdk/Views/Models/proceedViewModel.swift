//
//  proceedViewModel.swift
//  TimerWithLoader
//
//  Created by Tonny Franzis on 02/01/24.
//

import Foundation
import CryptoKit
import CommonCrypto
class proceedViewModel: ObservableObject {
    @Published var bootConfigResponse: BootConfigResponse?
    @Published var accessTokenResponse: AccessTokenResponse?
    @Published var payIndexModel: payIndexModel?
    @Published var tokenResponse: Data?
    @Published var isLoading = false
    @Published var errored = false
    var isTimerViewActive = false
    var showPopup = false
    var apiResponseSuccess = false
    
    var error: String = ""
    var merchanId = "247034"
    
    var baseURL = String()
    
    var firstName = String()
    var lastName = String()
    var merDom64 = String()
    var mobile = String()
    var orderID = String()
    
    var tokenValue = String()
    var amount = String()
    
    var strClientId = String()
    var strClientSecret = String()
    var secretKey = String()
    var userName = String()
    var password = String()
    
    
    let userDefaultsUserName = "userName"
    let userDefaultsToken = "token"
    let userDefaultsfirstName = "firstName"
    let userDefaultslastName = "lastName"
    let userDefaultsMobile = "Mobile"
    let userDefaultsOrderID = "OrderID"
    
    let userDefaultsPassword = "password"
    
    func fetchBootConfig() {
        APIManager.bootConfigAPI(merchantID:merchanId,success : { res in
            self.isLoading = false
            let receiver = BootConfigResponse(data: res.data)
            self.bootConfigResponse = receiver
            self.generateTokenEnc(strClientId: self.bootConfigResponse?.data.clientID ?? "", strClientSecret: self.bootConfigResponse?.data.clientSecret ?? "", secretKey: self.bootConfigResponse?.data.secretKey ?? "", merchantID: self.merchanId)
            self.apiResponseSuccess = Bool.random()
            self.baseURL = self.bootConfigResponse?.data.baseURL ?? ""
            
            UserDefaults.standard.set(self.bootConfigResponse?.data.username ?? "", forKey: self.userDefaultsUserName)
            UserDefaults.standard.set(self.bootConfigResponse?.data.password ?? "", forKey: self.userDefaultsPassword)
            
            
                    // Show the popup based on the API response
            self.showPopup.toggle()
           print("fetchBootConfig api call success")
            
        },
            failure: { [weak self] error in
                        self?.isLoading = false
                        self?.errored = true
                        self?.error = error.localizedDescription
            print("failed login attempt<========")
            })
    }
    func generateTokenEnc(strClientId:String,strClientSecret:String,secretKey:String,merchantID:String) {
        self.strClientId = strClientId
        self.strClientSecret = strClientSecret
        self.secretKey = secretKey
        
        
        if let retrievedUserName = UserDefaults.standard.string(forKey: userDefaultsUserName) {
            self.userName = retrievedUserName
                        }
        if let retrievedPassword = UserDefaults.standard.string(forKey: userDefaultsPassword) {
            self.password = retrievedPassword
                        }

        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDate = dateFormatter.string(from: Date())
        
        let allData = strClientId + strClientSecret + "client_credentials" + merchantID + currentDate
        
        // Calculate SHA256 hash for checksum
        print(allData)
        let checksum = sha256(data: allData.data(using: .utf8)!)
        print(checksum)
        // Create strSecretKey and strprivatekey using SHA256 hashing
        
        
//        let strSecretKey = sha256(data: "\(secretKey)".data(using: .utf8)!)
        
        let sTemp = "\(secretKey)@\(self.userName):|:\(self.password)"
        print(sTemp)
        let strprivatekey = sha256(data: sTemp.data(using: .utf8)!)
        print(strprivatekey)
        // Prepare data for AES encrypti
        let key = md5(string: "\(self.userName)~:~\(self.password)")
        self.fetchToken(checksum:checksum,strprivatekey:strprivatekey,key: key)
    }
    func fetchToken(checksum:String,strprivatekey:String,key: String) {
        
        APIManager.tokenAPI(merchant_id: merchanId, checksum: checksum, privatekey: strprivatekey,strClientId: strClientId,strClientSecret: strClientSecret, key: key,success : { res in
            self.isLoading = false
           print("tokenAPI call success")
            let tokenData = AccessTokenResponse(data: res.data)
            self.accessTokenResponse = tokenData
            self.tokenValue = tokenData.data.accessToken
            UserDefaults.standard.set(tokenData.data.accessToken, forKey: self.userDefaultsToken)
        },
            failure: { [weak self] error in
                        self?.isLoading = false
                        self?.errored = true
                        self?.error = error.localizedDescription
            print("failed login attempt<========")
            })
    }
    
    func generatePayIndexEnc(strAmount:String,firstName:String,lastName:String,merchantID:String,mobile:String,strOrderId:String,mer_dom:String,user_name:String,password:String) {
        
        
        self.amount = strAmount
        
        UserDefaults.standard.set(firstName, forKey: self.userDefaultsfirstName)
        UserDefaults.standard.set(lastName, forKey: self.userDefaultslastName)
        UserDefaults.standard.set(mobile, forKey: self.userDefaultsMobile)
        UserDefaults.standard.set(strOrderId, forKey: self.userDefaultsOrderID)
        
        if let retrievedfirstName = UserDefaults.standard.string(forKey: userDefaultsfirstName) {
            self.firstName = retrievedfirstName
                        }
        if let retrievedlastName = UserDefaults.standard.string(forKey: userDefaultslastName) {
            self.lastName = retrievedlastName
                        }
        if let retrievedMobile = UserDefaults.standard.string(forKey: userDefaultsMobile) {
            self.mobile = retrievedMobile
                        }
        if let retrievedOrderID = UserDefaults.standard.string(forKey: userDefaultsOrderID) {
            self.orderID = retrievedOrderID
                        }
        if let retrievedUserName = UserDefaults.standard.string(forKey: userDefaultsUserName) {
            self.userName = retrievedUserName
                        }
        if let retrievedPassword = UserDefaults.standard.string(forKey: userDefaultsPassword) {
            self.password = retrievedPassword
                        }
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDate = dateFormatter.string(from: Date())
                if let dataToEncode = mer_dom.data(using: .utf8) {
            merDom64 = dataToEncode.base64EncodedString()
                        }
        
        
        let allData = strAmount + "4" + "AIRTEL" + "" + "" + "" + "" + self.firstName + self.lastName + self.mobile + "" + "" + "mmoney" + "" + "834" + "TZS" + merDom64.replacingOccurrences(of: "\\n", with: "") + merchantID + self.orderID + currentDate
        
        // Calculate SHA256 hash for checksum
        let checksum = SHA256.hash(data: Data(allData.utf8)).compactMap { String(format: "%02x", $0) }.joined()
        
        print(allData)
        
      
        
        let sTemp = "\(secretKey)@\(self.userName):|:\(self.password)"
        print(sTemp)
        let strprivatekey = sha256(data: sTemp.data(using: .utf8)!)
        
        
        // Prepare data for AES encryption
        
        let key = md5(string: "\(self.userName)~:~\(self.password)")
        
        
        print(checksum)
        print(strprivatekey)
        print(key)
        // Perform AES encryption
//        let encryptData = performAESEncryption(data: jsonQuery, key: key)
        
        self.payIndex(checksum:checksum,strprivatekey:strprivatekey,key: key)
    }
    func payIndex(checksum:String,strprivatekey:String,key: String) {
        APIManager.payIndex(merchant_id: merchanId, checksum: checksum, privatekey: strprivatekey, buyer_firstname: firstName, buyer_lastname: lastName, buyer_phone: mobile, key: key, mer_dom64: merDom64, orderid: orderID, tokenValue: tokenValue, amount: amount,success : { res in
            self.isLoading = false
           print("payIndex call success")
            if res.status == "success"{
                print("payIndex success")
                self.isTimerViewActive = true
            }
        },
            failure: { [weak self] error in
                        self?.isLoading = false
                        self?.errored = true
                        self?.error = error.localizedDescription
            print("failed login attempt<========")
            })
    }
    func every5SecCall() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDate = dateFormatter.string(from: Date())
              
        
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        let dateTime = dateTimeFormatter.string(from: Date())
        if let retrievedOrderID = UserDefaults.standard.string(forKey: userDefaultsOrderID) {
            self.orderID = retrievedOrderID
                        }
        let allData = dateTime + self.orderID + "JSON" + currentDate
        
       
        // Calculate SHA256 hash for checksum
        let checksum = SHA256.hash(data: Data(allData.utf8)).compactMap { String(format: "%02x", $0) }.joined()
        
        print(allData)
        
        if let retrievedUserName = UserDefaults.standard.string(forKey: userDefaultsUserName) {
            self.userName = retrievedUserName
                        }
        if let retrievedPassword = UserDefaults.standard.string(forKey: userDefaultsPassword) {
            self.password = retrievedPassword
                        }
        
        let sTemp = "\(secretKey)@\(self.userName):|:\(self.password)"
        print(sTemp)
        let strprivatekey = sha256(data: sTemp.data(using: .utf8)!)
        
        
        // Prepare data for AES encryption
        let key = md5(string: "\(self.userName)~:~\(self.password)")
        
        
        print(checksum)
        print(strprivatekey)
        print(key)
        // Perform AES encryption
//        let encryptData = performAESEncryption(data: jsonQuery, key: key)
        
        self.paymentResponse(checksum:checksum,strprivatekey:strprivatekey,key: key,timeValue:dateTime)
    }
    func paymentResponse(checksum:String,strprivatekey:String,key: String,timeValue:String) {
        APIManager.paymentResponse(merchant_id: merchanId, checksum: checksum, privatekey: strprivatekey, key: key, orderid: orderID, timeValue: timeValue,success : { res in
            self.isLoading = false
           print("every5SecCall call success")
//            let tokenData = AccessTokenResponse(data: res.data)
//            self.accessTokenResponse = tokenData
        },
            failure: { [weak self] error in
                        self?.isLoading = false
                        self?.errored = true
                        self?.error = error.localizedDescription
            print("failed login attempt<========")
            })
    }
    
    
    

    

    
    func sha256(data: Data) -> String {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash).map { String(format: "%02x", $0) }.joined()
    }
    
    func md5(string: String) -> String {
        let data = Data(string.utf8)
        let hash = Insecure.MD5.hash(data: data)
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
    
    
}

