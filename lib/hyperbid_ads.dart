class HyperbidAds {
  // Future<String?> getPlatformVersion() {
  //   // return HyperbidAdsPlatform.instance.getPlatformVersion();
  // }
}

class HyperbidAdRegistry {
  HyperbidAdRegistry._();
  static final instance = HyperbidAdRegistry._();

  final Map<String, int> _attachedViews = {};

  bool isAttached(String adKey) => _attachedViews.containsKey(adKey);

  void attach(String adKey, int viewId) {
    _attachedViews[adKey] = viewId;
  }

  void detach(String adKey) {
    _attachedViews.remove(adKey);
  }

  int? viewIdOf(String adKey) => _attachedViews[adKey];
}
