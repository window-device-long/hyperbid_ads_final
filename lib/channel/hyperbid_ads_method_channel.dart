import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'hyperbid_ads_platform_interface.dart';

/// An implementation of [HyperbidAdsPlatform] that uses method channels.
class MethodChannelHyperbidAds extends HyperbidAdsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('hyperbid_ads');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
