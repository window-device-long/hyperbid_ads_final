import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyperbid_ads/core/modals/hb_type_ad.dart';

class HyperbidNativeAd extends StatelessWidget {
  final HBTypeAd typeAd;
  final String group;
  final String placementId;

  const HyperbidNativeAd({
    super.key,
    required this.group,
    required this.placementId,
    this.typeAd = HBTypeAd.native,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: typeAd.width,
      height: typeAd.height,
      child: AndroidView(
        viewType: 'hyperbid_ads/native',
        creationParams: {
          'group': group,
          'placementId': placementId,
          'type': typeAd.id,
        },
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }
}
