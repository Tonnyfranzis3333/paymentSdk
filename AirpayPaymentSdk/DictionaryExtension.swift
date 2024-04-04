//
//  DictionaryExtension.swift
//  Yakom
//
//  Created by Vysag K on 16/10/23.
//

import Foundation
extension Dictionary {
    
    /// Convert Dictionary to JSON string
    /// - Throws: exception if dictionary cannot be converted to JSON data or when data cannot be converted to UTF8 string
    /// - Returns: JSON string
    func toJson() throws -> String {
        let data = try JSONSerialization.data(withJSONObject: self)
        if let string = String(data: data, encoding: .utf8) {
            return string
        }
        
        throw NSError(domain: "Dictionary", code: 1, userInfo: ["message": "Data cannot be converted to .utf8 string"])
    }
}
