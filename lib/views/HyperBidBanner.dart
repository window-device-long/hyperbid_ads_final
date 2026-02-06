import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyperbid_ads/core/services/wrapper/AdsRemoteConfig.dart';

class HyperBidBanner extends StatefulWidget {
  final String placementId;
  final String name;
  final String type;
  final String screen;

  const HyperBidBanner({
    super.key,
    required this.placementId,
    required this.name,
    this.type = "banner",
    this.screen = "Home",
  });

  @override
  State<HyperBidBanner> createState() => _HyperBidBannerState();
}

class _HyperBidBannerState extends State<HyperBidBanner> {
  late final bool _allowShow;

  @override
  void initState() {
    super.initState();
    _allowShow = AdsRemoteConfig.canShowBanner(
      placementId: widget.placementId,
      screen: widget.screen,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_allowShow) {
      return const SizedBox.shrink();
    }

    return AndroidView(
      viewType: "hyperbid_ads/banner",
      creationParams: {
        "placementId": widget.placementId,
        "name": widget.name,
        "type": widget.type,
      },
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
