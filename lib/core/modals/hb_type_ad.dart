enum HBTypeAd {
  banner("banner"),
  bannerMedium("banner_medium"),
  bannerCollapse("banner_collapse"),
  interstitial("interstitial"),
  rewardedVideo("rewarded_video"),
  native("native"),
  nativeBanner("native_banner"),
  nativeMedium("native_medium"),
  nativeSmall("native_small"),
  nativeCollapse("native_collapse"),
  nativeMediumCollapse("native_medium_collapse"),
  nativeFull("native_full"),
  unknown("unknown");

  final String id;
  const HBTypeAd(this.id);
}

extension HBTypeAdSize on HBTypeAd {
  double get height {
    switch (this) {
      case HBTypeAd.nativeBanner:
        return 90;

      case HBTypeAd.nativeSmall:
        return 50;

      case HBTypeAd.native:
        return 160;

      case HBTypeAd.nativeMedium:
        return 250;
      case HBTypeAd.nativeCollapse:
      case HBTypeAd.nativeMediumCollapse:
        return 50;

      case HBTypeAd.nativeFull:
        return double.infinity;

      default:
        return 50;
    }
  }

  double get width => double.infinity;
}
