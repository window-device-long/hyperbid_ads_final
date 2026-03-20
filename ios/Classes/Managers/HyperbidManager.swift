//
//  HyperbidManager.swift
//  
//
//  Created by LongDev on 16/3/26.
//

import Foundation
import MCSDK
import Flutter
 
class HyperbidManager: NSObject, MCInitDelegate {
    func didMediationInitFinished(_ successMediationIdList: [NSNumber]!, failedError: MCError!) {
        print("HyperBid init finished:")
    }
    
    static let shared = HyperbidManager()
    func initSDK(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let appID = args["appId"] as? String,
              let appKey = args["appKey"] as? String
        else {
            result(false)
            
            return }
        
    
        let config = MCInitConfig()
        config.appId = appID
        config.appKey = appKey
        
        config.isPrivacySettingsEnabled = true
        
    
        MCAPI.sharedInstance().initWith(config, delegate: self)
        
        
        result(true)
    }
    
}
