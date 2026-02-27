import Flutter
import UIKit

public class HyperbidAdsPlugin: NSObject, FlutterPlugin {
  private var lifecycleObservers: FlutterEventSink?
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "hyperbid_ads", binaryMessenger: registrar.messenger())
    let instance = HyperbidAdsPlugin()
      
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    default: 
      result(FlutterMethodNotImplemented)
    }
  }
}
