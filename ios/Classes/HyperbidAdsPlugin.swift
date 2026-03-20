import Flutter
import UIKit

public class HyperbidAdsPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
   
    private static var appStateNotifier: FLTAppStateNotifier?

    private var commandChannel: FlutterMethodChannel!
        private var lifecycleChannel: FlutterEventChannel!
        private var lifecycleSink: FlutterEventSink?

        public static var viewController: UIViewController?
  public static func register(with registrar: FlutterPluginRegistrar) {
      let instance = HyperbidAdsPlugin()
      instance.commandChannel = FlutterMethodChannel(
        name: "hyperbid_ads/command", binaryMessenger: registrar.messenger()
      )
      instance.lifecycleChannel = FlutterEventChannel(name: "hyperbid_ads/lifecycle", binaryMessenger: registrar.messenger())
      
      
      let instanceAppState = FLTAppStateNotifier(messenger: registrar.messenger())

      Self.appStateNotifier = instanceAppState
      
      registrar.register(HbBannerViewFactory(
        messenger: registrar.messenger()
      ), withId: "hyperbid_ads/banner")
      
      registrar.register(HbNativeViewFactory(
        messenger: registrar.messenger()
      ), withId: "hyperbid_ads/native")
      
      registrar.addMethodCallDelegate(instance, channel: instance.commandChannel)
      instance.lifecycleChannel.setStreamHandler(instance)
      
      
      
  }
    
    // MARK: -- MethodChannel
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        lifecycleSink = events
        
        HBEventDispatcher.shared.sink = events
        
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        lifecycleSink = nil
        HBEventDispatcher.shared.sink = nil
        return nil
    }
    

    //MARK: handle even
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "initSDK":
           HyperbidManager.shared.initSDK(call: call, result: result)

       // ================= App Open =================
       case "initAppOpen":
        let args = call.arguments as? [String: Any]
           let placement = args?["placementId"] as? String
           HBAppOpenManager.shared.initAd(placementId: placement)
           result(true)

       case "showAppOpen":
           HBAppOpenManager.shared.show()
           result(true)

       // ================= Interstitial =================
       case "initInterstitial":
        let args = call.arguments as? [String: Any]
           let placement = args?["placementId"] as? String
        HBInterstitialManager.shared.initAd(placementId: placement)
           result(true)

       case "showInterstitial":

        HBInterstitialManager.shared.show()
           result(true)

       case "isInterstitialReady":
        result(HBInterstitialManager.shared.isReady)

       // ================= Reward =================
       case "initReward":
        let args = call.arguments as? [String: Any]
           let placement = args?["placementId"] as? String
        HBRewardManager.shared.initAd(placementId: placement)
           result(true)

       case "showReward":
           HBRewardManager.shared.show()
           result(true)

       case "isRewardReady":
           result(HBRewardManager.shared.isReady())

       // ================= Native =================
       case "reloadNativeActive":
        let args = call.arguments as? [String: Any]
        _ = args?["placementId"] as? String
            let viewId = args?["viewId"] as? String
           HBNativeManager.shared.reload(viewId: viewId)
           result(true)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
