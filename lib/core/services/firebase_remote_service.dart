import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();

  factory RemoteConfigService() => _instance;

  RemoteConfigService._internal();

  late final FirebaseRemoteConfig _remoteConfig;

  Future<void> init() async {
    try {
      _remoteConfig = FirebaseRemoteConfig.instance;
      // final jsonStr = await rootBundle.loadString('assets/remote_config.json');
      //
      // final Map<String, dynamic> defaults = json.decode(jsonStr);
      //
      // await _remoteConfig.setDefaults(defaults);

      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: kDebugMode
              ? Duration.zero
              : const Duration(hours: 12),
        ),
      );

      await _remoteConfig.fetch();
      final check = await _remoteConfig.activate();

      debugPrint('✅ RemoteConfig fetched and activated: $check');
      print(
        "Remote Config Values: ${getString("remote_data", defaultValue: "default")}",
      );
    } catch (e) {
      debugPrint('❌ RemoteConfig init error: $e');
    }
  }

  /// Kiểm tra key có tồn tại không
  bool hasKey(String key) {
    return _remoteConfig.getAll().containsKey(key);
  }

  /// Lấy giá trị dạng String
  String getString(String key, {String defaultValue = ''}) {
    return hasKey(key) ? _remoteConfig.getString(key) : defaultValue;
  }

  /// Lấy giá trị bool
  bool getBool(String key, {bool defaultValue = true}) {
    return hasKey(key) ? _remoteConfig.getBool(key) : defaultValue;
  }

  /// Lấy giá trị số (int/double)
  int getInt(String key, {int defaultValue = 0}) {
    return hasKey(key) ? _remoteConfig.getInt(key) : defaultValue;
  }

  double getDouble(String key, {double defaultValue = 0}) {
    return hasKey(key) ? _remoteConfig.getDouble(key) : defaultValue;
  }
}
