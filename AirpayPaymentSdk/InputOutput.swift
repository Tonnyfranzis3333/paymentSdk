//
//  InputOutput.swift
//  TimerWithLoader
//
//  Created by Tonny Franzis on 12/01/24.
//

import Foundation
import SwiftUI

public struct ScanAndPayFrameWork {
    public static var shared = ScanAndPayFrameWork()
    public typealias NavigationCallback = (TransactionStatusModel) -> Void
    public var navigationCallback: NavigationCallback?
    
    public func sdkView(order_id: String, merchant_id: String, first_name: String, last_name: String, amount: String, srNo: String,mobile:String,environment:String,isSwahili:Bool,channel_partner:String) -> some View {
        
        return ConfirmPayementView(order_id: order_id, merchant_id: merchant_id, first_name: first_name, last_name: last_name, amount: amount, srNo: srNo,mobile:mobile,environment:environment,isSwahili:isSwahili,channel_partner:channel_partner,navigationCallback: navigationCallback)
    }
}


