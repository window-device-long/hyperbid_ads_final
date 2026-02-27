import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_ad_revenue.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:hyperbid_ads/core/services/local_data.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:se_flutter_sdk_us/solar_engine_core/solar_engine.dart';
import 'package:se_flutter_sdk_us/solar_engine_core/solar_engine_config.dart';
import 'package:se_flutter_sdk_us/solar_engine_core/solar_engine_event_data.dart';

import '../modals/ad_revenue_modal.dart';

enum AnalyticsPlatform { firebase, adjust, solar }

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();

  factory AnalyticsService() => _instance;

  AnalyticsService._internal();

  bool _initialized = false;
  bool _adjustReady = false;
  bool _solarReady = false;

  late final FirebaseAnalytics _analytics;

  String? _appVersion;
  String? _buildNumber;

  // ================= INIT =================

  Future<void> init({
    String? userId,
    bool sandbox = true,
    String? adjustKey,
    String? solarKey,
  }) async {
    if (_initialized) return;

    _analytics = FirebaseAnalytics.instance;

    final info = await PackageInfo.fromPlatform();
    _appVersion = info.version;
    _buildNumber = info.buildNumber;

    if (userId != null) {
      await _analytics.setUserId(id: userId);
    }

    if (adjustKey != null) {
      AdjustEnvironment envAdjust = sandbox
          ? AdjustEnvironment.sandbox
          : AdjustEnvironment.production;

      final config = AdjustConfig(adjustKey, envAdjust);
      config.logLevel = AdjustLogLevel.info;

      Adjust.initSdk(config);
      _adjustReady = true;
    }

    if (solarKey != null) {
      SolarEngineConfig config = SolarEngineConfig();
      config.logEnabled = true;
      config.isDebugModel = sandbox;
      config.logEnabled = true;

      SolarEngine.preInitialize(solarKey);
      SolarEngine.initializeWithAppkey(solarKey, config);
      _solarReady = true;
    }

    if (!PreferencesService.instance.getBool("already_opened")) {
      _analytics.logEvent(name: "version_${_appVersion}_first_open");
      PreferencesService.instance.setBool("already_opened", true);
    }
    _initialized = true;
  }

  void logEventNormal(String name, Map<String, Object>? parameters) async {
    if (!_initialized) return;

    _analytics.logEvent(name: name, parameters: parameters);
  }

  // ================= SCREEN =================

  Future<void> logScreen(String screen) async {
    if (!_initialized || kDebugMode) return;

    await _analytics.logScreenView(screenName: screen, screenClass: screen);
  }

  // ================= ADS IMPRESSION =================

  Future<void> logAdImpression({
    required String adType, // native / interstitial / reward
    required String placement,
    required String network,
    required double value,
    String currency = "USD",
    AdRevenueModel? modal,
    String platform = "android",
    List<AnalyticsPlatform> platforms = const [
      AnalyticsPlatform.firebase,
      AnalyticsPlatform.adjust,
      AnalyticsPlatform.solar,
    ],
  }) async {
    if (!_initialized) return;
    for (final p in platforms) {
      switch (p) {
        case AnalyticsPlatform.firebase:
          await _logFirebaseAdImpression(modal!);
          break;
        case AnalyticsPlatform.adjust:
          _logAdjustAdImpression(modal!);
          break;
        case AnalyticsPlatform.solar:
          _logSolarAdImpression(modal!);
          break;
      }
    }
  }

  Future<void> _logFirebaseAdImpression(AdRevenueModel modal) async {
    try {
      String? keyShow = {
        true: "_show_",
        false: "_first_open_show_",
      }[PreferencesService.instance.getBool("show_first_time_${modal.adType}")];

      PreferencesService.instance.setBool(
        "show_first_time_${modal.adType}",
        true,
      );

      _analytics.logEvent(
        name: "version_$_appVersion$keyShow${modal.adType}",
        parameters: modal.toJsonFirebase()?.map(
          (k, v) => MapEntry(k, v as Object),
        ),
      );

      _analytics.logAdImpression(
        value: modal.revenue,
        currency: modal.currency,
        adFormat: modal.adFormat,
        adPlatform: modal.adPlatform,
        adSource: modal.networkName,
        adUnitName: modal.mediationPlacementId,
      );

      debugPrint("[Analytics] Firebase ad_impression: $modal");
    } catch (e) {
      debugPrint("[Analytics] Firebase ad_impression failed: $e");
    }
  }

  // ================= OTHER PLATFORMS =================
  void _logAdjustAdImpression(AdRevenueModel modal) {
    debugPrint("[Analytics] Adjust ad_impression: $modal");
    if (_adjustReady) {
      final adRevenue = AdjustAdRevenue(modal.adPlatform);
      adRevenue.setRevenue(modal.revenue, modal.currency);
      adRevenue.adRevenueNetwork = modal.networkName;
      adRevenue.adRevenuePlacement = modal.mediationPlacementId;
      adRevenue.adRevenueUnit = modal.adFormat;
      Adjust.trackAdRevenue(adRevenue);
    }
  }

  void _logSolarAdImpression(AdRevenueModel params) {
    debugPrint("[Analytics] Solar ad_impression: $params");
    if (_solarReady) {
      final adRevenue = SEAppImpressionData()
        ..adNetworkPlatform = params.adPlatform
        ..adType = 1
        ..mediationPlatform = params.networkName
        ..ecpm = params.ecpm
        ..adNetworkADID = params.networkPlacementId
        ..currencyType = params.currency
        ..isRenderSuccess = true;

      SolarEngine.trackAppImpress(adRevenue);
    }
  }
}
