import 'dart:convert';

import 'package:hyperbid_ads/core/modals/hb_type_ad.dart';
import '../firebase_remote_service.dart';

class AdsRemoteConfig {
  static final _rc = RemoteConfigService();

  /// ================================
  /// PUBLIC API
  /// ================================
  static bool canShowNative({
    required HBTypeAd type,
    required String placementId,
    required String group,
    required String screen,
  }) {
    // 1️⃣ GLOBAL KILL
    if (!_rc.getBool('ads_native_enabled', defaultValue: true)) {
      return false;
    }

    // 2️⃣ TYPE LEVEL
    final typeKey = 'ads_native_enabled_${type.name}';
    if (_rc.hasKey(typeKey) && !_rc.getBool(typeKey, defaultValue: true)) {
      return false;
    }

    // 3️⃣ SCREEN LEVEL (JSON)
    if (!_isScreenAllowed(screen)) {
      return false;
    }

    return true;
  }

  static bool canShowBanner({
    required String placementId,
    required String screen,
  }) {
    // 1️⃣ GLOBAL KILL
    if (!_rc.getBool('ads_banner_enabled', defaultValue: true)) {
      return false;
    }

    if (!_rc.hasKey('ads_banner_screens')) {
      return true;
    }

    try {
      final raw = _rc.getString('ads_banner_screens');
      if (raw.isEmpty) return true;

      final Map<String, dynamic> map = json.decode(raw) as Map<String, dynamic>;

      // Ưu tiên screen cụ thể
      if (map.containsKey(screen)) {
        return map[screen] == true;
      }

      // Fallback default
      if (map.containsKey('default')) {
        return map['default'] == true;
      }

      return true;
    } catch (_) {
      return true;
    }
  }

  /// ================================
  /// PRIVATE HELPERS
  /// ================================

  /// ads_native_screens = {
  ///   "home": true,
  ///   "feed": false,
  ///   "player": true,
  ///   "default": true
  /// }
  static bool _isScreenAllowed(String screen) {
    if (!_rc.hasKey('ads_native_screens')) {
      return true; // không cấu hình → cho phép
    }

    try {
      final raw = _rc.getString('ads_native_screens');
      if (raw.isEmpty) return true;

      final Map<String, dynamic> map = json.decode(raw) as Map<String, dynamic>;

      // Ưu tiên screen cụ thể
      if (map.containsKey(screen)) {
        return map[screen] == true;
      }

      // Fallback default
      if (map.containsKey('default')) {
        return map['default'] == true;
      }

      return true;
    } catch (_) {
      // lỗi JSON → fail-open
      return true;
    }
  }

  static bool canShowInterstitial({String? screen}) {
    // 1️⃣ Global
    if (!_rc.getBool('ads_interstitial_enabled', defaultValue: true)) {
      return false;
    }

    // 3️⃣ Screen
    if (!_rc.hasKey('ads_interstitial_screen')) {
      return true; // không cấu hình → cho phép
    }

    try {
      final raw = _rc.getString('ads_interstitial_screen');
      if (raw.isEmpty) return true;

      final Map<String, dynamic> map = json.decode(raw) as Map<String, dynamic>;

      // Ưu tiên screen cụ thể
      if (map.containsKey(screen)) {
        return map[screen] == true;
      }

      // Fallback default
      if (map.containsKey('default')) {
        return map['default'] == true;
      }

      return true;
    } catch (_) {
      return true;
    }
  }

  // ================= REWARD =================

  static bool canShowReward({String? screen}) {
    // 1️⃣ Global
    if (!_rc.getBool('ads_reward_enabled', defaultValue: true)) {
      return false;
    }

    // 3️⃣ Screen
    if (!_rc.hasKey('ads_reward_screen')) {
      return true; // không cấu hình → cho phép
    }

    try {
      final raw = _rc.getString('ads_reward_screen');
      if (raw.isEmpty) return true;

      final Map<String, dynamic> map = json.decode(raw) as Map<String, dynamic>;

      // Ưu tiên screen cụ thể
      if (map.containsKey(screen)) {
        return map[screen] == true;
      }

      // Fallback default
      if (map.containsKey('default')) {
        return map['default'] == true;
      }

      return true;
    } catch (_) {
      return true;
    }
  }
}
