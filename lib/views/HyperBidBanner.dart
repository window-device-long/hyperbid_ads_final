import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HyperBidBanner extends StatelessWidget {
  final String placementId;
  final String name;
  final String type;

  const HyperBidBanner({
    super.key,
    required this.placementId,
    required this.name,
    this.type = "banner",
  });

  @override
  Widget build(BuildContext context) {
    return AndroidView(
      viewType: "hyperbid_ads/banner",
      creationParams: {"placementId": placementId, "name": name, "type": type},
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
