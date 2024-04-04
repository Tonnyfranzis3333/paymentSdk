

import Foundation
import Alamofire
import SwiftUI

public enum SwiftBaseErrorCode: Int {
  case inputStreamReadFailed           = -6000
  case outputStreamWriteFailed         = -6001
  case contentTypeValidationFailed     = -6002
  case statusCodeValidationFailed      = -6003
  case dataSerializationFailed         = -6004
  case stringSerializationFailed       = -6005
  case jsonSerializationFailed         = -6006
  case propertyListSerializationFailed = -6007
}

class BaseURLConvertible: URLConvertible {
  
  let path: String
  let baseUrl: String
  
  init(path: String, baseUrl: String = APIClientSdk.getBaseUrl()) {
    self.path = path
    self.baseUrl = baseUrl
  }
  
  func asURL() throws -> URL {
    //  print(baseUrl,"baseurl",path,"path<++++++++++++++++++++++++")
    return URL(string: "\(baseUrl)\(path)")!
  }
}

class BaseURLRequestConvertible: URLRequestConvertible {
  let url: URLConvertible
  let method: HTTPMethod
  let headers: HTTPHeaders
  let params: [String: Any]?
  let encoding: ParameterEncoding?
  
  func asURLRequest() throws -> URLRequest {
    let request = try URLRequest(url: url,
                                 method: method,
                                 headers: headers)
     
    if let params = params, let encoding = encoding {
      return try encoding.encode(request, with: params)
    }
    
    return request
  }
  
  init(path: String,
       baseUrl: String = APIClientSdk.getBaseUrl(),
       method: HTTPMethod,
       encoding: ParameterEncoding? = nil,
       params: [String: Any]? = nil,
       headers: [String: String] = [:]) {
    url = BaseURLConvertible(path: path, baseUrl: baseUrl)
      print(url)
    self.method = method
    self.headers = HTTPHeaders(headers)
    self.params = params
    self.encoding = encoding
  }
}

public typealias SuccessCallback = (
  _ responseObject: [String: Any],
  _ responseHeaders: [AnyHashable: Any]
  ) -> Void
public typealias SuccessCallback2 = (
    _ responseObject: [String: Any]
) -> Void
public typealias FailureCallback = (_ error: Error) -> Void

class APIClientSdk {
    
    enum HTTPHeader: String {
        
        case token = "Authorization" // access tokemn
        case loginStatus = "x-login-status" // bool(string)
        case type = "x-app-type"   // user
        case id = "x-affiliate-id" // 6
        case lang = "x-language"  // en or sw
        case contenttype = "Content-Type"   //text/plain
        //case contentlength
       
       
        
    }
    
    private static let emptyDataStatusCodes: Set<Int> = [204, 205]
    
    //Mandatory headers for Rails 5 API
    static let baseHeaders: [String: String] = [
        
        HTTPHeader.contenttype.rawValue: "text/plain",
        HTTPHeader.id.rawValue:"6",
        HTTPHeader.type.rawValue:"user",
        HTTPHeader.loginStatus.rawValue:"false",
        HTTPHeader.lang.rawValue:"en",
       
        
    ]
    
    fileprivate class func getHeaders() -> [String: String] {
        if SessionManager.currentSession?.accessToken == ""{
            return baseHeaders
        }else{
           if let session = SessionManager.currentSession {
                let dict2 = [
                    
                    HTTPHeader.token.rawValue: session.accessToken ?? ""
                ]
                let concatenatedDictionary = baseHeaders.merging(dict2) { (_, new) in new }
                return concatenatedDictionary
                
            }
            return baseHeaders
        }
    }
    
    
    fileprivate class func getBaseUrl() -> String {
        return "https://tz-payments.airpay.ninja"
    }
    
    //Recursively build multipart params to send along with media in upload requests.
    //If params includes the desired root key, call this method with an empty String for rootKey param.
    class func multipartFormData(
        _ multipartForm: MultipartFormData,
        params: Any, rootKey: String
    ) {
        switch params.self {
        case let array as [Any]:
            for val in array {
                let forwardRootKey = rootKey.isEmpty ? "array[]" : rootKey + "[]"
                multipartFormData(multipartForm, params: val, rootKey: forwardRootKey)
            }
        case let dict as [String: Any]:
            for (k, v) in dict {
                let forwardRootKey = rootKey.isEmpty ? k : rootKey + "[\(k)]"
                multipartFormData(multipartForm, params: v, rootKey: forwardRootKey)
            }
        default:
            if let uploadData = "\(params)".data(
                using: String.Encoding.utf8, allowLossyConversion: false
            ) {
                let forwardRootKey = rootKey.isEmpty ?
                "\(type(of: params))".lowercased() : rootKey
                multipartForm.append(uploadData, withName: forwardRootKey)
            }
        }
    }
    //Multipart-form base request. Used to upload media along with desired params.
    //Note: Multipart request does not support Content-Type = application/json.
    //If your API requires this header do not use this method or change backend to skip this validation.
    class func PostImage( url: String,image: UIImage,fileName:String,
                          withName:String,
                          success: @escaping SuccessCallback,
                          failure: @escaping FailureCallback) {
        let token = SessionManager.currentSession?.accessToken
        let headers:HTTPHeaders = [.authorization(bearerToken: token ?? ""),
                                   .contentType("multipart/form-data")]
        let  Url =  getBaseUrl() + url
        
         AF.upload(
             multipartFormData: { multipartFormData in
                 multipartFormData.append(image.jpegData(compressionQuality: 0)!, withName: withName , fileName: fileName, mimeType: "image/jpeg")
         },
          to: Url, method: .post , headers: headers)
         .responseJSON(completionHandler: { result in
             validateResult(result: result, success: success, failure: failure)
         })

 }
    class func multipartRequest(_ method: HTTPMethod = .post,
                                url: String,
                                headers: [String: String] = APIClientSdk.getHeaders(),
                                params: [String: Any]?,
                                paramsRootKey: String,
                                media: [MultipartMedia],
                                success: @escaping SuccessCallback,
                                failure: @escaping FailureCallback) {
        let requestConvertible = BaseURLRequestConvertible(
            path: url,
            method: method,
            headers: headers
        )
        AF.upload(
            multipartFormData: { (multipartForm) -> Void in
                if let parameters = params {
                    multipartFormData(multipartForm, params: parameters, rootKey: paramsRootKey)
                }
                for elem in media {
                    elem.embed(inForm: multipartForm)
                }
            },
            with: requestConvertible)
        .responseJSON(completionHandler: { result in
            validateResult(result: result, success: success, failure: failure)
        })
    }
    
    class func defaultEncoding(forMethod method: HTTPMethod) -> ParameterEncoding {
        switch method {
        case .post, .put, .patch:
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }
    class func plainRequest(_ method: HTTPMethod,
                       url: URL,
                       token: String?,
                       params: [String: Any]? = nil,
                       headersExtra: [String: String] = [:],
                       paramsEncoding: ParameterEncoding? = nil,
                       success: @escaping SuccessCallback,
                       failure: @escaping FailureCallback) {
        if((token) != nil){
            var headers:HTTPHeaders = [.authorization(bearerToken: token ?? "")]
            if((headersExtra) != nil){
                for (key, value) in headersExtra {
                    headers.add(name:key, value:value)
                }
            }
            AF.request( url, method:.get,encoding: URLEncoding.default, headers: headers)
                .validate()
                .responseJSON(
                completionHandler: { result in
                    validateResult(result: result, success: success, failure: failure)
                })
        }else{
            AF.request( url, method:.get,encoding: URLEncoding.default)
                .validate()
                .responseJSON(
                completionHandler: { result in
                    validateResult(result: result, success: success, failure: failure)
                })
        }
    }
    
    class func plainRequest2(_ method: HTTPMethod,
                    url: URL,
                    token: String?,
                    params: [String: Any]? ,
                    headersExtra: [String: String] = [:],
                    paramsEncoding: ParameterEncoding? = nil,
                    success: @escaping SuccessCallback,
                    failure: @escaping FailureCallback) {
        var headers:HTTPHeaders = [:]
        if((token) != nil){
            headers = [.authorization(bearerToken: token ?? "")]
        }
        if((headersExtra) != nil){
            for (key, value) in headersExtra {
                headers.add(name:key, value:value)
            }
        }
        AF.request(url, method:method,parameters: params,encoding:JSONEncoding.prettyPrinted, headers: headers)
            .validate()
            .responseJSON(
            completionHandler: { result in
                validateResult(result: result, success: success, failure: failure)
            })

    }
    
    class func plainRequest3(_ method: HTTPMethod,
                    url: URL,
                    token: String?,
                    params: [String]? ,
                    headersExtra: [String: String] = [:],
                    paramsEncoding: ParameterEncoding? = nil,
                    success: @escaping SuccessCallback,
                    failure: @escaping FailureCallback) {
        var headers:HTTPHeaders = [:]
        if((token) != nil){
            headers = [.authorization(bearerToken: token ?? "")]
        }
        if((headersExtra) != nil){
            for (key, value) in headersExtra {
                headers.add(name:key, value:value)
            }
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")

        let values = params

        request.httpBody = try! JSONSerialization.data(withJSONObject: values)

        AF.request(request)
        .validate()
        .responseJSON(
        completionHandler: { result in
        
            validateResult(result: result, success: success, failure: failure)
        })
                    
//        AF.request(url, method:method,parameters: params,encoding:JSONEncoding.prettyPrinted, headers: headers)
//            .validate()
//            .responseJSON(
//            completionHandler: { result in
//                validateResult(result: result, success: success, failure: failure)
//            })

    }
    
    
//    class func request(_ method: HTTPMethod,
//                       url: String,
//                       params: [String: Any]? = nil,
//                       paramsEncoding: ParameterEncoding? = nil,
//                       success: @escaping SuccessCallback,
//                       failure: @escaping FailureCallback) {
//        let encoding = paramsEncoding ?? defaultEncoding(forMethod: method)
//        let headers = APIClient.getHeaders()
//        let requestConvertible = BaseURLRequestConvertible(
//            path: url,
//            method: method,
//            encoding: encoding,
//            params: params,
//            headers: headers
//        )
//        let request = AF.request(requestConvertible)
//        request
//            .validate()
//            .validate(contentType: ["application/json"])
//            .responseJSON(
//            completionHandler: { result in
//                print(result,"the result<==========")
//                validateResult(result: result, success: success, failure: failure)
//            })
//    }
    
    class func request<Parameters: Encodable>(
        
        _ method: HTTPMethod,
        url: String,
        passedKey:String,
        params: Parameters? = nil,
        paramsEncoding: ParameterEncoding? = nil,
        success: @escaping SuccessCallback,
        failure: @escaping FailureCallback
    ) {
        print(method)
        print(params)
        let encoding = paramsEncoding ?? defaultEncoding(forMethod: method)
//        let headers = APIClient.getHeaders()
        var DecryKey = "wawrewruthaglswuflgipififldrazlv"
//        print(headers,"header inside request fn")
        if passedKey != ""{
            DecryKey = passedKey
        } else {
            print("Private Key not found or not a String value")
        }
        print("DecryKey:\(DecryKey)")
        let requestConvertible = BaseURLRequestConvertible(
            path: url,
            method: method,
            encoding: encoding,
            params: params as? [String : Any]
//            headers: headers
        )

        let request = AF.request(requestConvertible)
        let loginapiurl = getBaseUrl() + url
                print(loginapiurl,"====== apiurl")
        request
            .validate()
  
        
        
        
        // Inside your responseJSON completion handler
        .responseJSON(completionHandler: { result in
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
                                print(DecryKey)
                                let aes256DEcry = AES(key: DecryKey, iv: ivStr ?? "")
                                
                                if  let decryptedData =  aes256DEcry?.decrypt(data: newdata){
                                    let trimmedDecryptedData = decryptedData.trimmingCharacters(in: .whitespacesAndNewlines)
                                    guard let updatedData = trimmedDecryptedData.data(using: .utf8) else{return}
                                    
                                    
                                    guard let upStr = String(data: updatedData, encoding: .utf8) else{return}
                                    print(upStr,"upStr")
                                    let upstrReplaced =  upStr.replacingOccurrences(of: "source", with: "sourceKey")
                                    print(upstrReplaced,"upstrReplaced")
                                    print(decryptedData,"the decrypted data<=============================")
                                    let newUpdata = upstrReplaced.data(using: .utf8)
                                    NewValidateResult(originalResult: result, decryptresult: newUpdata, resultRes: result.response, success: success, failure: failure)
                                    
                                    
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
        })
    }
    
    
    class func auth(_ method: HTTPMethod,
                    url: String,
                    params: [String: Any]? ,
                    paramsEncoding: ParameterEncoding? = nil,
                    success: @escaping SuccessCallback,
                    failure: @escaping FailureCallback) {
        let encoding = paramsEncoding ?? defaultEncoding(forMethod: method)
        let usrnm = params?["email"]
        let usrPwd = params?["password"]
        let credentialData = "\(usrnm!):\(usrPwd!)".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
     
        let base64Credentials = credentialData.base64EncodedString()
        let headers:HTTPHeaders = ["Authorization": "Basic \(base64Credentials)"]
        var  authUrl =  getBaseUrl()+url
        AF.request(authUrl, method:.post,encoding: URLEncoding.default, headers: headers).responseJSON(
            completionHandler: { result in
                validateResult(result: result, success: success, failure: failure)
            })
        
    }
    class func authProfile(_ method: HTTPMethod,
                    url: String,
                    params: [String: Any]? ,
                    paramsEncoding: ParameterEncoding? = nil,
                    success: @escaping SuccessCallback,
                    failure: @escaping FailureCallback) {
        let encoding = paramsEncoding ?? defaultEncoding(forMethod: method)
        let usrnm = params?["email"]
        let usrPwd = params?["pwd"]
        let credentialData = "\(usrnm!):\(usrPwd!)".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
     
        let base64Credentials = credentialData.base64EncodedString()
        let headers:HTTPHeaders = ["Authorization": "Basic \(base64Credentials)"]
        var  authUrl =  getBaseUrl()+url
        AF.request(authUrl, method:method,parameters: params,encoding:JSONEncoding.prettyPrinted, headers: headers).responseJSON(
            completionHandler: { result in
                validateResult(result: result, success: success, failure: failure)
            })
        
    }
    
    class func Get(_ method: HTTPMethod,
                    url: String,
                    params: [String: Any]? ,
                    paramsEncoding: ParameterEncoding? = nil,
                    success: @escaping SuccessCallback,
                    failure: @escaping FailureCallback) {
        let encoding = paramsEncoding ?? defaultEncoding(forMethod: method)
        let token = SessionManager.currentSession?.accessToken
        let headers:HTTPHeaders = [.authorization(bearerToken: token as? String ?? "")]
        var Url =  getBaseUrl()+url
        AF.request(Url, method:.get,encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseJSON(
            completionHandler: { result in
                validateResult(result: result, success: success, failure: failure)
             
            })
        
    }
    class func Post(_ method: HTTPMethod,
                    url: String,
                    params: [String: Any]? ,
                    paramsEncoding: ParameterEncoding? = nil,
                    success: @escaping SuccessCallback,
                    failure: @escaping FailureCallback) {
        let encoding = paramsEncoding ?? defaultEncoding(forMethod: method)
        let token = SessionManager.currentSession?.accessToken
        let headers:HTTPHeaders = [.authorization(bearerToken: token as? String ?? "")]
        let  Url =  getBaseUrl()+url
        AF.request(Url, method:.post,parameters: params,encoding:JSONEncoding.prettyPrinted, headers: headers)
            .validate()
            .responseJSON(
            completionHandler: { result in
               
                validateResult(result: result, success: success, failure: failure)
                
            })

    }
    class func PostExternal(_ method: HTTPMethod,
                    url: String,
                    params: [String: Any]? ,
                    paramsEncoding: ParameterEncoding? = nil,
                    success: @escaping SuccessCallback,
                    failure: @escaping FailureCallback) {
        let encoding = paramsEncoding ?? defaultEncoding(forMethod: method)
        let token = SessionManager.currentSession?.accessToken
        let headers:HTTPHeaders = [.authorization(bearerToken: token as? String ?? "")]
        let  Url = url
        AF.request(Url, method:.post,parameters: params,encoding:JSONEncoding.prettyPrinted, headers: headers)
            .validate()
            .responseJSON(
            completionHandler: { result in
                validateResult(result: result, success: success, failure: failure)
            })

    }
    
    class func Put(_ method: HTTPMethod,
                    url: String,
                    params: [String: Any]? ,
                    paramsEncoding: ParameterEncoding? = nil,
                    success: @escaping SuccessCallback,
                    failure: @escaping FailureCallback) {
        let encoding = paramsEncoding ?? defaultEncoding(forMethod: method)
        let token = SessionManager.currentSession?.accessToken
        let headers:HTTPHeaders = [.authorization(bearerToken: token as? String ?? "")]
        
        let  Url =  getBaseUrl()+url
        AF.request(Url, method:.put,parameters: params,encoding:JSONEncoding.prettyPrinted, headers: headers)
            .validate()
            .responseJSON(
            completionHandler: { result in
                
                validateResult(result: result, success: success, failure: failure)
               
            })

    }
    class func Delete(_ method: HTTPMethod,
                    url: String,
                   
                    paramsEncoding: ParameterEncoding? = nil,
                    success: @escaping SuccessCallback,
                    failure: @escaping FailureCallback) {
        let encoding = paramsEncoding ?? defaultEncoding(forMethod: method)
        let token = SessionManager.currentSession?.accessToken
        let headers:HTTPHeaders = [.authorization(bearerToken: token as? String ?? "")]
        
        let  Url =  getBaseUrl()+url
        print("Delete Url",Url)
        AF.request(Url, method:.delete,encoding:JSONEncoding.prettyPrinted, headers: headers)
            .validate()
            .responseJSON(
            completionHandler: { result in
                validateResult(result: result, success: success, failure: failure)
            })

    }
    
    //Handle rails-API-base errors if any
    class func handleCustomError(_ code: Int?, dictionary: [String: Any]) -> NSError? {
        var acceptableStatusCodes: Range<Int> { 200..<300 }
        if acceptableStatusCodes.contains(code ?? 500) {
            return nil
        }
        if let messageDict = dictionary["message"] as? [String: [String]] {
            let errorsList = messageDict[messageDict.keys.first!]!
            return NSError(
                domain: "\(messageDict.keys.first!) \(errorsList.first!)",
                code: code ?? 500, userInfo: nil
            )
        } else if let error = dictionary["message"] as? String {
            return NSError(domain: error, code: code ?? 500, userInfo: nil)
        } else if let errors = dictionary["message"] as? [String: Any] {
            let errorDesc = errors[errors.keys.first!]!
            return NSError(
                domain: "\(errors.keys.first!) " + "\(errorDesc)",
                code: code ?? 500, userInfo: nil
            )
        } else if dictionary["message"] != nil || dictionary["message"] != nil {
            return NSError(
                domain: "Something went wrong. Try again later.",
                code: code ?? 500, userInfo: nil
            )
        }
        return nil
    }
    
    fileprivate class func validateResult(result: AFDataResponse<Any>,
                                         
                                          success: @escaping SuccessCallback,
                                          failure: @escaping FailureCallback) {
        
        let defaultError = AppEr.error(
            domain: .generic,
            localizedDescription: "Error parsing response".localized
        )
        guard let response = result.response else {
            failure(defaultError)
            return
        }
        
        guard
            let data = result.data,
            !data.isEmpty
        else {
            let emptyResponseAllowed = emptyDataStatusCodes.contains(
                result.response?.statusCode ?? 0
            )
            print(emptyResponseAllowed,"///////////////")
            emptyResponseAllowed ?
            success([:], response.allHeaderFields) : failure(defaultError)
            return
        }
        
        var dictionary: [String: Any]?
        var serializationError: NSError?
        do {
            dictionary = try JSONSerialization.jsonObject(
                with: data, options: .allowFragments
            ) as? [String: Any]
            print(dictionary,"the dictionary======")
        } catch let exceptionError as NSError {
            serializationError = exceptionError
        }
        //Check for errors in validate() or API
        if let errorOcurred = APIClientSdk.handleCustomError(
            response.statusCode, dictionary: dictionary ?? [:]
        ) ?? result.error as NSError? {
            failure(errorOcurred)
            return
        }
        //Check for JSON serialization errors if any data received
        if let serializationError = serializationError {
            if (serializationError as NSError).code == 401 {
               // AppDelegate.shared.unexpectedLogout()
            }
            failure(serializationError)
        } else {
            print("reached here")
            success(dictionary ?? [:], response.allHeaderFields)
        }
    }
    fileprivate class func NewValidateResult(originalResult: AFDataResponse<Any>,
                                            decryptresult: Data?,
                                             resultRes:AnyObject?,
                                             
                                          success: @escaping SuccessCallback,
                                          failure: @escaping FailureCallback) {
        
        let defaultError = AppEr.error(
            domain: .generic,
            localizedDescription: "Error parsing response".localized
        )
        guard let response = resultRes else {
            failure(defaultError)
            return
        }
        
        guard
            let data = decryptresult,
            !data.isEmpty
        else {
            let emptyResponseAllowed = emptyDataStatusCodes.contains(
                resultRes?.statusCode ?? 0
            )
            emptyResponseAllowed ?
            success([:], response.allHeaderFields) : failure(defaultError)
            return
        }
        print(data,"the data after decryptions<====================")
        let strdata = String(data: data, encoding: .utf8)
        print(strdata)
       
        var dictionary: [String: Any]?
        var serializationError: NSError?
        do {
            
            dictionary = try JSONSerialization.jsonObject(
                with: decryptresult!, options:[]
            ) as? [String: Any]
            print(dictionary,"the expected dictionary<====")
        } catch let exceptionError as NSError {
            serializationError = exceptionError
        }
//     //   Check for errors in validate() or API
//        if let errorOcurred = APIClient.handleCustomError(
//            resultRes?.statusCode, dictionary: dictionary ?? [:]
//        ) ?? originalResult.error as NSError? {
//            failure(errorOcurred)
//            return
//        }
//        //Check for JSON serialization errors if any data received
        if let serializationError = serializationError {
            if (serializationError as NSError).code == 401 {
               // AppDelegate.shared.unexpectedLogout()
            }
            failure(serializationError)
        } else {
            success(dictionary ?? [:], response.allHeaderFields)
        }
    }
    
}
//Helper to retrieve the right string value for base64 API uploaders
extension Data {
  func asBase64Param(withType type: MimeType = .jpeg) -> String {
    return "data:\(type.rawValue);base64,\(self.base64EncodedString())"
  }
}

extension String {
    var encoded: String? {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }
}
