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
      case HBTypeAd.nativeCollapse:
        return 80;

      case HBTypeAd.nativeSmall:
        return 120;

      case HBTypeAd.native:
        return 160;

      case HBTypeAd.nativeMedium:
      case HBTypeAd.nativeMediumCollapse:
        return 250;

      case HBTypeAd.nativeFull:
        return 420; // kiểu TikTok full media + overlay

      default:
        return 160;
    }
  }

  double get width => double.infinity;
}
