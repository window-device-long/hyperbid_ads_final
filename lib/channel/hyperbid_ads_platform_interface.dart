import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'hyperbid_ads_method_channel.dart';

abstract class HyperbidAdsPlatform extends PlatformInterface {
  /// Constructs a HyperbidAdsPlatform.
  HyperbidAdsPlatform() : super(token: _token);

  static final Object _token = Object();

  // static MethodChannelHyperbidAds _instance = MethodChannelHyperbidAds();

  /// The default instance of [HyperbidAdsPlatform] to use.
  ///
  /// Defaults to [MethodChannelHyperbidAds].
  // static HyperbidAdsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [HyperbidAdsPlatform] when
  /// they register themselves.
  // static set instance(HyperbidAdsPlatform instance) {
  //   PlatformInterface.verifyToken(instance, _token);
  //   _instance = instance;
  // }

  static HyperbidAdsPlatform _instance = MethodChannelHyperbidAds();

  static HyperbidAdsPlatform get instance => _instance;

  static set instance(HyperbidAdsPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  // ================= SDK =================
  Future<void> initSDK({
    required String appId,
    required String appKey,
    String? userId,
  });

  // ================= App Open =================
  Future<void> initAppOpen(String placementId);
  Future<void> showAppOpen();

  // ================= Interstitial =================
  Future<void> initInterstitial(String placementId);
  Future<void> showInterstitial({String? screen});
  Future<bool> isInterstitialReady();

  // ================= Reward =================
  Future<void> initReward(String placementId);
  Future<void> showReward({String? screen});
  Future<bool> isRewardReady();

  // ================= Native =================
  Future<void> reloadNativeActive(String viewId);

  // ================= Lifecycle =================
  Stream<Map<String, dynamic>> get lifecycleStream;
}
