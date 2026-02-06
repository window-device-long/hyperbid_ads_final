import 'package:flutter/foundation.dart';
import 'package:hyperbid_ads/core/modals/ad_revenue_modal.dart';
import 'package:hyperbid_ads/core/services/firebase_analytics.dart';

class AdRevenueHandler {
  static void handle(Map<String, dynamic> data) {
    try {
      final value = (data['revenue'] as num?)?.toDouble() ?? 0;
      if (value <= 0) return;

      AnalyticsService().logAdImpression(
        value: value,
        currency: data['currency'] ?? 'USD',
        adType: data['ad_type'] ?? 'unknown',
        placement: data['mediation_placement_id'] ?? '',
        network: data['network_name'] ?? '',
        platform: data['ad_platform'] ?? 'android',
        modal: AdRevenueModel.fromJson(data),
        platforms: const [
          AnalyticsPlatform.firebase,
          AnalyticsPlatform.solar,
          AnalyticsPlatform.adjust,
        ],
      );
    } catch (e) {
      debugPrint('❌ Failed to log ad revenue: $data');
    }
  }
}
