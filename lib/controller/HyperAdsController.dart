import '../channel/HyperbidAdsChannels.dart';

class HyperAdsController {
  HyperAdsController._();
  static Stream<Map<String, dynamic>>? _lifecycleStream;

  static Stream<Map<String, dynamic>> get lifecycleStream {
    _lifecycleStream ??= HyperbidAdsChannels.lifecycle
        .receiveBroadcastStream()
        .map((e) => Map<String, dynamic>.from(e));
    return _lifecycleStream!;
  }

  static Future<void> initSDK({
    required String appId,
    required String appKey,
    String? userId,
  }) {
    return HyperbidAdsChannels.command.invokeMethod("initSDK", {
      "appId": appId,
      "appKey": appKey,
      "userId": userId,
    });
  }
}
