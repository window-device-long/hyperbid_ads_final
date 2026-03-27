//
//  HyperbidManager.swift
//  
//
//  Created by LongDev on 16/3/26.
//

import Foundation
import MCSDK
import Flutter
 

   
class HyperbidManager: NSObject, MCInitDelegate, MCMediationUpdateDelegate {
    private var initResult: FlutterResult?
    private(set) var state: HyperbidInitState = .idle

    private var pendingTasks: [() -> Void] = []

    func didMediationUpdated(_ newAppSettings: [AnyHashable : Any]!, oldAppSettings: [AnyHashable : Any]!) {
        print("HyperBid updated: ")
    }
    
    func didMediationInitFinished(_ successMediationIdList: [NSNumber]!, failedError: MCError!) {
        print("HyperBid init finished:")
        if failedError == nil {
               state = .success
               initResult?(true)

               // 🔥 chạy tất cả task đang chờ
               pendingTasks.forEach { $0() }
               pendingTasks.removeAll()

           } else {
               state = .failed
               initResult?(false)
           }
        self.initResult = nil
    }
    
    
    func runWhenReady(_ task: @escaping () -> Void) {

        switch state {

        case .success:
            task()

        case .initializing:
            print("⏳ SDK chưa xong → add vào queue")
            pendingTasks.append(task)

        case .idle:
            print("⚠️ SDK chưa init")
            pendingTasks.append(task)

        case .failed:
            print("❌ SDK init failed → không chạy")
        }
    }
    
    static let shared = HyperbidManager()
    func initSDK(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let appID = args["appId"] as? String,
              let appKey = args["appKey"] as? String
        else {
            result(false)
            
            return
        }
        self.initResult = result   // 🔥 giữ lại

        if state == .success {
                result(true)
                return
            }
        state = .initializing
        initResult = result

        MCSDK.MCAPI.sharedInstance().setMediationUpdateDelegate(self)

        let config = MCSDK.MCInitConfig()
        config.appId = appID
        config.appKey = appKey
        config.timeoutForUseDefaultStrategy = 0
        config.isPrivacySettingsEnabled = true

        DispatchQueue.main.async {
            MCSDK.MCAPI.sharedInstance().initWith(config, delegate: self)
        }

    
        }
    
}
