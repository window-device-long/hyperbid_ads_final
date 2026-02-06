class AdRevenueModel {
  // ===== REQUIRED (IAdInfo) =====
  final String? mediationPlacementId;
  final String? scenarioId;
  final String? networkPlacementId;

  final String adFormat;
  final String adType;

  final double revenue;
  final double ecpm;
  final String revenuePrecision;

  final String currency;
  final String? country;

  final String? networkName;
  final int networkFirmId;

  final String? mediationName;
  final int mediationSecretId;

  final int biddingType;
  final String? networkTransId;

  // ===== EXTRA =====
  final Map<String, dynamic> mediationExtra;
  final String originJson;

  // ===== DERIVED =====
  final String adPlatform;

  AdRevenueModel({
    required this.mediationPlacementId,
    required this.scenarioId,
    required this.networkPlacementId,
    required this.adFormat,
    required this.adType,

    required this.revenue,
    required this.ecpm,
    required this.revenuePrecision,
    required this.currency,
    required this.country,
    required this.networkName,
    required this.networkFirmId,
    required this.mediationName,
    required this.mediationSecretId,
    required this.biddingType,
    required this.networkTransId,
    required this.mediationExtra,
    required this.originJson,
    required this.adPlatform,
  });

  factory AdRevenueModel.fromJson(Map<String, dynamic> json) {
    return AdRevenueModel(
      mediationPlacementId: json['mediation_placement_id'],
      scenarioId: json['scenario_id'],
      networkPlacementId: json['network_placement_id'],

      adFormat: json['ad_format'] ?? '',
      adType: json['ad_type'] ?? '',

      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      ecpm: (json['ecpm'] as num?)?.toDouble() ?? 0.0,
      revenuePrecision: json['revenue_precision'] ?? '',

      currency: json['currency'] ?? 'USD',
      country: json['country'],

      networkName: json['network_name'],
      networkFirmId: json['network_firm_id'] ?? 0,

      mediationName: json['mediation_name'],
      mediationSecretId: json['mediation_secret_id'] ?? 0,

      biddingType: json['bidding_type'] ?? -1,
      networkTransId: json['network_trans_id'],

      mediationExtra: Map<String, dynamic>.from(
        json['mediation_extra'] ?? const {},
      ),

      originJson: json['origin_json'] ?? '',
      adPlatform: json['ad_platform'] ?? 'unknown',
    );
  }

  Map<String, dynamic>? toJsonFirebase() {
    return {
      'mediation_placement_id': mediationPlacementId,
      'ad_format': adFormat,
      'ad_type': adType,
      'revenue': revenue,
      'revenue_precision': revenuePrecision,
      'currency': currency,
      'country': country,
      'network_name': networkName,
      'mediation_name': mediationName,
      'ad_platform': adPlatform,
    };
  }
}
