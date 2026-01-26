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

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
