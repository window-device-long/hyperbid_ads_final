import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'channel/HyperbidAdsChannels.dart';
import 'channel/hyperbid_ads_platform_interface.dart';
import 'channel/revenue_handler.dart';
import 'core/modals/hb_sdk_state.dart';
import 'core/services/firebase_analytics.dart';
import 'core/services/firebase_database_service.dart';
import 'core/services/firebase_remote_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/wrapper/AdsRemoteConfig.dart';

class HyperbidAds {
  static final HyperbidAds I = HyperbidAds._internal();

  HyperbidAds._internal();

  static HBSDKState _state = HBSDKState.sdkIdle;
  static Object? _lastError;

  static Completer<void>? _interstitialCompleter;
  static Completer<bool>? _rewardCompleter;

  static StreamSubscription? _lifecycleSub;
  static Stream<Map<String, dynamic>>? _lifecycleStream;
  static Stream<Map<String, dynamic>> get lifecycleStream {
    _lifecycleStream ??= HyperbidAdsChannels.lifecycle
        .receiveBroadcastStream()
        .map((e) => Map<String, dynamic>.from(e));
    return _lifecycleStream!;
  }

  static HBSDKState get state => _state;

  static bool get isReady => _state == HBSDKState.sdkInitialized;

  static Object? get lastError => _lastError;

  // ================= INIT =================

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
      return;
    }

    _state = HBSDKState.sdkInitializing;
    _lastError = null;

    final totalWatch = Stopwatch()..start();

    void logStep(String msg) {
      debugPrint('[HyperbidInit] $msg');
    }

    Future<T> measure<T>(String name, Future<T> Function() action) async {
      final sw = Stopwatch()..start();
      logStep('▶️ START $name');
      final result = await action();
      sw.stop();
      logStep('✅ DONE  $name (${sw.elapsedMilliseconds} ms)');

      if (name.contains("RemoteConfigService.init")) {
        analytics.logEventNormal("RemoteConfigService.init", {
          "time_init": sw.elapsedMilliseconds.toString(),
        });
      }
      return result;
    }

    try {
      // 1️⃣ Firebase init
      if (Firebase.apps.isEmpty) {
        await measure('Firebase.initializeApp', () {
          return Firebase.initializeApp(name: appName, options: firebase);
        });
      } else {
        logStep('ℹ️ Firebase already initialized');
      }

      // await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
      await measure('Crashlytics init', () {
        return _initCrashlytics(sandbox: sandbox);
      });

      // 3️⃣ Hyperbid native SDK
      await measure('HyperbidAdsPlatform.initSDK', () {
        return HyperbidAdsPlatform.instance.initSDK(
          appId: appId,
          appKey: appKey,
        );
      });

      // 7️⃣ Analytics / Adjust / Solar (background)
      unawaited(
        measure('AnalyticsService.init (bg)', () {
          return analytics.init(
            sandbox: sandbox,
            adjustKey: adjustKey,
            solarKey: solarKey,
          );
        }),
      );

      // 4️⃣ Remote Config (await vì có thể ảnh hưởng logic)
      await measure('RemoteConfigService.init', () {
        return remote.init();
      });

      // 5️⃣ Database (background)
      unawaited(
        measure('FirebaseRestoreService.init (bg)', () {
          return database.init();
        }),
      );

      // 6️⃣ Notification (background)
      unawaited(
        measure('NotificationService.init (bg)', () {
          return notification.init();
        }),
      );

      // 8️⃣ Bind lifecycle (nhẹ)
      measure('Bind lifecycle', () async {
        _bindLifecycle();
      });

      _state = HBSDKState.sdkInitialized;

      totalWatch.stop();
      logStep(
        '🎉 INIT SDK FINISHED | TOTAL = ${totalWatch.elapsedMilliseconds} ms',
      );
    } catch (e, s) {
      totalWatch.stop();
      logStep('❌ INIT SDK FAILED after ${totalWatch.elapsedMilliseconds} ms');

      _state = HBSDKState.sdkInitializationFailed;
      _lastError = e;

      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'HyperbidAds initSdk failed',
        fatal: true,
      );

      rethrow;
    }
  }

  // ================= LIFECYCLE =================

  static void _bindLifecycle() {
    print("Bind lifecycle called");

    _lifecycleSub ??= lifecycleStream.listen(
      _handleEvent,
      onError: (_) {
        debugPrint('❌ Failed to handle lifecycle event');
      },
    );
  }

  static void _handleEvent(Map<String, dynamic> event) {
    switch (event['type']) {
      case 'interstitial_hidden':
        _interstitialCompleter?.complete();
        _interstitialCompleter = null;
        break;

      case 'reward_earned':
        if (_rewardCompleter != null && !_rewardCompleter!.isCompleted) {
          _rewardCompleter!.complete(true);
        }
        break;

      case 'reward_hidden':
        if (_rewardCompleter != null && !_rewardCompleter!.isCompleted) {
          _rewardCompleter!.complete(false);
        }
        _rewardCompleter = null;
        break;

      case 'revenue':
        final raw = event['data'];
        if (raw is Map<String, dynamic>) {
          AdRevenueHandler.handle(raw);
        }
        break;
    }
  }

  // ================= INTERSTITIAL =================

  static Future<void> initInterstitial(String placementId) {
    return HyperbidAdsPlatform.instance.initInterstitial(placementId);
  }

  static Future<bool> isInterstitialReady() {
    return HyperbidAdsPlatform.instance.isInterstitialReady();
  }

  static Future<void> showInterstitial({String? screen}) {
    if (!AdsRemoteConfig.canShowInterstitial(screen: screen)) {
      return Future.value();
    }
    if (_interstitialCompleter != null &&
        !_interstitialCompleter!.isCompleted) {
      return _interstitialCompleter!.future;
    }

    _interstitialCompleter = Completer<void>();
    HyperbidAdsPlatform.instance.showInterstitial(screen: screen);
    return _interstitialCompleter!.future;
  }

  // ================= REWARD =================

  static Future<void> initReward({required String placementId}) {
    return HyperbidAdsPlatform.instance.initReward(placementId);
  }

  static Future<bool> isRewardReady() {
    return HyperbidAdsPlatform.instance.isRewardReady();
  }

  static Future<bool> showReward({
    String? screen,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    if (!AdsRemoteConfig.canShowReward(screen: screen)) {
      return Future.value(true);
    }
    if (_rewardCompleter != null && !_rewardCompleter!.isCompleted) {
      return _rewardCompleter!.future;
    }

    _rewardCompleter = Completer<bool>();
    await HyperbidAdsPlatform.instance.showReward(screen: screen);

    if (_rewardCompleter != null && !_rewardCompleter!.isCompleted) {
      _rewardCompleter!.complete(true);
    }

    return _rewardCompleter!.future.timeout(
      timeout,
      onTimeout: () {
        debugPrint('⏱ Reward timeout → treat as FAILED');

        if (_rewardCompleter != null && !_rewardCompleter!.isCompleted) {
          _rewardCompleter!.complete(false);
        }
        _rewardCompleter = null;

        return false;
      },
    );
  }

  // ================= APP OPEN =================

  static Future<void> initAppOpen({required String placementId}) {
    return HyperbidAdsPlatform.instance.initAppOpen(placementId);
  }

  static Future<void> showAppOpen() {
    return HyperbidAdsPlatform.instance.showAppOpen();
  }

  // ================= SERVICES =================

  final analytics = AnalyticsService();
  final remote = RemoteConfigService();
  final database = FirebaseRestoreService();
  final notification = NotificationService();

  Future<void> _initCrashlytics({required bool sandbox}) async {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      !sandbox,
    );

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
}

class HyperbidAdRegistry {
  HyperbidAdRegistry._();
  static final instance = HyperbidAdRegistry._();

  final Map<String, int> _attachedViews = {};

  bool isAttached(String adKey) => _attachedViews.containsKey(adKey);

  void attach(String adKey, int viewId) {
    _attachedViews[adKey] = viewId;
  }

  void detach(String adKey) {
    _attachedViews.remove(adKey);
  }

  int? viewIdOf(String adKey) => _attachedViews[adKey];
}
