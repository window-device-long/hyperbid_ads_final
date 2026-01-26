import 'package:flutter_test/flutter_test.dart';
import 'package:hyperbid_ads/channel/hyperbid_ads_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockHyperbidAdsPlatform
    with MockPlatformInterfaceMixin
    implements HyperbidAdsPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  // final HyperbidAdsPlatform initialPlatform = HyperbidAdsPlatform.instance;
  //
  // test('$MethodChannelHyperbidAds is the default instance', () {
  //   expect(initialPlatform, isInstanceOf<MethodChannelHyperbidAds>());
  // });
  //
  // test('getPlatformVersion', () async {
  //   HyperbidAds hyperbidAdsPlugin = HyperbidAds();
  //   MockHyperbidAdsPlatform fakePlatform = MockHyperbidAdsPlatform();
  //   HyperbidAdsPlatform.instance = fakePlatform;
  //
  //   expect(await hyperbidAdsPlugin.getPlatformVersion(), '42');
  // });
}
