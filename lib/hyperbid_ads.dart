import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:hyperbid_ads/core/services/local_data.dart';
import 'package:hyperbid_ads/core/services/notification_service.dart';

import 'channel/hyperbid_ads_platform_interface.dart';
import 'channel/revenue_handler.dart';
import 'core/modals/hb_sdk_state.dart';
import 'core/services/firebase_analytics.dart';
import 'core/services/firebase_database_service.dart';
import 'core/services/firebase_remote_service.dart';
import 'core/services/native_ad_state_store.dart';

class HyperbidAds {
  static final HyperbidAds I = HyperbidAds._internal();

  HyperbidAds._internal();

  static HBSDKState _state = HBSDKState.sdkIdle;
  static Object? _lastError;

  static HBSDKState get state => _state;

  static bool get isReady => _state == HBSDKState.sdkInitialized;

  static Object? get lastError => _lastError;

  Future<void> initSdk({
    FirebaseOptions? firebase,
    String appName = "Default",
    required String appId,
    required String appKey,
    String? solarKey,
    String? adjustKey,
    bool sandbox = false,
  }) async {
    if (_state == HBSDKState.sdkInitializing ||
        _state == HBSDKState.sdkInitialized) {
      debugPrint('⚠️ HyperbidAds already initialized or initializing');
      return;
    }

    _state = HBSDKState.sdkInitializing;
    _lastError = null;

    try {
      bindLifecycle();

      // 1️⃣ Firebase
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(name: appName, options: firebase);
      }
      await _initCrashlytics(sandbox: sandbox);
      await Future.wait([
        PreferencesService.init(),
        analytics.init(
          sandbox: sandbox,
          adjustKey: adjustKey,
          solarKey: solarKey,
        ),
        remote.init(),
        database.init(),
        notification.init(),
      ]);
      // 2️⃣ Native SDK
      await HyperbidAdsPlatform.instance.initSDK(appId: appId, appKey: appKey);

      _state = HBSDKState.sdkInitialized;
      debugPrint('✅ HyperbidAds initialized');
    } catch (e, s) {
      _state = HBSDKState.sdkInitializationFailed;
      _lastError = e;

      // 🔥 Log vào Crashlytics
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'HyperbidAds initSdk failed',
        fatal: true,
      );

      debugPrint('❌ HyperbidAds init failed: $e');
      debugPrint('$s');

      rethrow; // cho app xử lý nếu muốn
    }
  }

  Future<void> _initCrashlytics({required bool sandbox}) async {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      !sandbox,
    );

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    debugPrint('🔥 Firebase Crashlytics initialized');
  }

  static void bindLifecycle() {
    HyperbidAdsPlatform.instance.lifecycleStream.listen(_handleEvent);
  }

  static Future<void> showInterstitial({String? screen}) {
    _interstitialCompleter ??= Completer<void>();
    HyperbidAdsPlatform.instance.showInterstitial(screen: screen);
    return _interstitialCompleter!.future;
  }

  static void _handleEvent(Map<String, dynamic> event) {
    switch (event['type']) {
      case 'interstitial_hidden':
        _interstitialCompleter?.complete();
        _interstitialCompleter = null;
        break;
      case 'reward_earned':
        _rewardCompleter?.complete(true);
        break;
      case 'reward_hidden':
        _rewardCompleter?.complete(false);
        _rewardCompleter = null;
        break;
      case 'revenue':
        final raw = event['data'];
        if (raw is Map<String, dynamic>) {
          AdRevenueHandler.handle(raw);
        }
        break;

      case 'native_state':
        final viewId = event['viewId'];
        final state = event['state'];

        if (viewId == null || state == null) return;

        switch (state) {
          case 'READY':
            NativeAdStateStore.instance.update(viewId, NativeAdState.ready);
            break;

          case 'FAILED':
            NativeAdStateStore.instance.update(viewId, NativeAdState.failed);
            break;

          case 'LOADING':
            NativeAdStateStore.instance.update(viewId, NativeAdState.loading);
            break;
        }
    }
  }

  static Completer<void>? _interstitialCompleter;
  static Completer<bool>? _rewardCompleter;

  final analytics = AnalyticsService();
  final remote = RemoteConfigService();
  final database = FirebaseRestoreService();
  final notification = NotificationService();
}
