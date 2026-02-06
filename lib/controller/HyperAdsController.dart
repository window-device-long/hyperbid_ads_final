// import 'dart:async';
// import 'dart:convert';
//
// import 'package:flutter/cupertino.dart';
// import 'package:hyperbid_ads/core/modals/ad_revenue_modal.dart';
// import 'package:hyperbid_ads/core/services/wrapper/AdsRemoteConfig.dart';
//
// import '../channel/HyperbidAdsChannels.dart';
// import '../core/services/firebase_analytics.dart';
//
// class HyperAdsController {
//   HyperAdsController._();
//
//   // ================= STREAM =================
//
//   static Stream<Map<String, dynamic>>? _lifecycleStream;
//   static StreamSubscription? _lifecycleSub;
//
//   static Stream<Map<String, dynamic>> get lifecycleStream {
//     _lifecycleStream ??= HyperbidAdsChannels.lifecycle
//         .receiveBroadcastStream()
//         .map((e) => Map<String, dynamic>.from(e));
//     return _lifecycleStream!;
//   }
//
//   // ================= COMPLETER =================
//
//   static Completer<void>? _interstitialCompleter;
//   static Completer<bool>? _rewardCompleter;
//
//   static Map<String, dynamic> _safeDecodeJson(String raw) {
//     try {
//       return Map<String, dynamic>.from(jsonDecode(raw));
//     } catch (_) {
//       return {};
//     }
//   }
//
//   // ================= INIT =================
//
//   /// ⚠️ GỌI 1 LẦN KHI APP START (main / bootstrap)
//   static void bindLifecycle() {
//     _lifecycleSub ??= lifecycleStream.listen(
//       _handleLifecycleEvent,
//       onError: (_) {},
//     );
//   }
//
//   static Future<void> initSDK({
//     required String appId,
//     required String appKey,
//     String? userId,
//   }) {
//     // đảm bảo đã bind
//     bindLifecycle();
//
//     return HyperbidAdsChannels.command.invokeMethod("initSDK", {
//       "appId": appId,
//       "appKey": appKey,
//       "userId": userId,
//     });
//   }
//
//   // ================= EVENT HANDLER =================
//
//   static void _handleLifecycleEvent(Map<String, dynamic> event) {
//     final type = event['type'];
//
//     // ---------------- INTERSTITIAL ----------------
//     if (type == 'interstitial_hidden') {
//       if (_interstitialCompleter != null &&
//           !_interstitialCompleter!.isCompleted) {
//         _interstitialCompleter!.complete();
//       }
//       _interstitialCompleter = null;
//       return;
//     }
//     if (type == 'revenue') {
//       final raw = event['data'];
//       if (raw is String && raw.isNotEmpty) {
//         final Map<String, dynamic> json = _safeDecodeJson(raw);
//
//         _logRevenueInternal(json);
//       }
//       return;
//     }
//
//     // ---------------- REWARD ----------------
//     if (type == 'reward_earned') {
//       if (_rewardCompleter != null && !_rewardCompleter!.isCompleted) {
//         _rewardCompleter!.complete(true);
//       }
//       return;
//     }
//
//     if (type == 'reward_hidden') {
//       if (_rewardCompleter != null && !_rewardCompleter!.isCompleted) {
//         _rewardCompleter!.complete(false);
//       }
//       _rewardCompleter = null;
//       return;
//     }
//   }
//
//   static void _logRevenueInternal(Map<String, dynamic> data) {
//     try {
//       final value = (data['revenue'] as num?)?.toDouble() ?? 0;
//       if (value <= 0) return;
//
//       AnalyticsService().logAdImpression(
//         value: value,
//         currency: data['currency'] ?? 'USD',
//         adType: data['ad_type'] ?? 'unknown',
//         placement: data['mediation_placement_id'] ?? '',
//         network: data['network_name'] ?? '',
//         platform: data['ad_platform'] ?? 'android',
//
//         modal: AdRevenueModel.fromJson(data),
//         platforms: const [
//           AnalyticsPlatform.firebase,
//           AnalyticsPlatform.solar,
//           AnalyticsPlatform.adjust,
//         ],
//       );
//     } catch (_) {
//       debugPrint('❌ Failed to log ad revenue: $data');
//     }
//   }
//
//   // ================= APP OPEN =================
//
//   static Future<void> initAppOpen({required String placementId}) async {
//     await HyperbidAdsChannels.command.invokeMethod('initAppOpen', {
//       'placementId': placementId,
//     });
//   }
//
//   static Future<void> showAppOpen() async {
//     await HyperbidAdsChannels.command.invokeMethod('showAppOpen');
//   }
//
//   // ================= INTERSTITIAL =================
//
//   static Future<void> initInterstitial(String placementId) async {
//     await HyperbidAdsChannels.command.invokeMethod('initInterstitial', {
//       'placementId': placementId,
//     });
//   }
//
//   /// ✅ await đến khi ad ĐÓNG
//   static Future<void> showInterstitial({String? screen}) {
//     if (!AdsRemoteConfig.canShowInterstitial(screen: screen)) {
//       return Future.value();
//     }
//
//     if (_interstitialCompleter != null &&
//         !_interstitialCompleter!.isCompleted) {
//       return _interstitialCompleter!.future;
//     }
//
//     _interstitialCompleter = Completer<void>();
//     HyperbidAdsChannels.command.invokeMethod('showInterstitial');
//     return _interstitialCompleter!.future;
//   }
//
//   static Future<bool> isInterstitialReady() async {
//     return await HyperbidAdsChannels.command.invokeMethod(
//       'isInterstitialReady',
//     );
//   }
//
//   // ================= REWARD =================
//
//   static Future<void> initReward(String placementId) async {
//     await HyperbidAdsChannels.command.invokeMethod('initReward', {
//       'placementId': placementId,
//     });
//   }
//
//   static Future<bool> showReward({String? screen}) {
//     if (!AdsRemoteConfig.canShowReward(screen: screen)) {
//       return Future.value(false);
//     }
//     if (_rewardCompleter != null && !_rewardCompleter!.isCompleted) {
//       return _rewardCompleter!.future;
//     }
//
//     _rewardCompleter = Completer<bool>();
//     HyperbidAdsChannels.command.invokeMethod('showReward');
//     return _rewardCompleter!.future;
//   }
//
//   static Future<bool> isRewardReady() async {
//     return await HyperbidAdsChannels.command.invokeMethod('isRewardReady');
//   }
//
//   // ================= NATIVE =================
//
//   static Future<void> reloadNativeActive({required String viewId}) async {
//     await HyperbidAdsChannels.command.invokeMethod('reloadNativeActive', {
//       'viewId': viewId,
//     });
//   }
// }
