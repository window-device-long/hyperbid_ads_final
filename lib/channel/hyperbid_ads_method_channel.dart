import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../core/services/wrapper/AdsRemoteConfig.dart';
import 'hyperbid_ads_platform_interface.dart';

/// An implementation of [HyperbidAdsPlatform] that uses method channels.
class MethodChannelHyperbidAds extends HyperbidAdsPlatform {
  @visibleForTesting
  final MethodChannel methodChannel = const MethodChannel('hyperbid_ads');

  final MethodChannel _command = const MethodChannel('hyperbid_ads/command');

  final EventChannel _lifecycle = const EventChannel('hyperbid_ads/lifecycle');

  // ================= SDK =================

  @override
  Future<void> initSDK({
    required String appId,
    required String appKey,
    String? userId,
  }) {
    return _command.invokeMethod('initSDK', {
      'appId': appId,
      'appKey': appKey,
      'userId': userId,
    });
  }

  // ================= App Open =================

  @override
  Future<void> initAppOpen(String placementId) {
    return _command.invokeMethod('initAppOpen', {'placementId': placementId});
  }

  @override
  Future<void> showAppOpen() {
    return _command.invokeMethod('showAppOpen');
  }

  // ================= Interstitial =================

  @override
  Future<void> initInterstitial(String placementId) {
    return _command.invokeMethod('initInterstitial', {
      'placementId': placementId,
    });
  }

  @override
  Future<void> showInterstitial({String? screen}) {
    if (!AdsRemoteConfig.canShowInterstitial(screen: screen)) {
      return Future.value();
    }
    return _command.invokeMethod('showInterstitial');
  }

  @override
  Future<bool> isInterstitialReady() async {
    final result = await _command.invokeMethod<bool>('isInterstitialReady');
    return result ?? false;
  }

  // ================= Reward =================

  @override
  Future<void> initReward(String placementId) {
    return _command.invokeMethod('initReward', {'placementId': placementId});
  }

  @override
  Future<void> showReward({String? screen}) {
    if (!AdsRemoteConfig.canShowReward(screen: screen)) {
      return Future.value(false);
    }
    return _command.invokeMethod('showReward');
  }

  @override
  Future<bool> isRewardReady() async {
    final result = await _command.invokeMethod<bool>('isRewardReady');
    return result ?? false;
  }

  // ================= Native =================

  @override
  Future<void> reloadNativeActive(String viewId) {
    return _command.invokeMethod('reloadNativeActive', {'viewId': viewId});
  }

  // ================= Lifecycle =================

  @override
  Stream<Map<String, dynamic>> get lifecycleStream => _lifecycle
      .receiveBroadcastStream()
      .map((event) => Map<String, dynamic>.from(event));
}
