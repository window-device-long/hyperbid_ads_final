import 'package:flutter/services.dart';

class HyperbidAdsChannels {
  static const MethodChannel command = MethodChannel('hyperbid_ads/command');

  static const EventChannel lifecycle = EventChannel('hyperbid_ads/lifecycle');
}
