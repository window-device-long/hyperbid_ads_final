import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyperbid_ads/core/modals/hb_type_ad.dart';
import 'package:hyperbid_ads/hyperbid_ads.dart';

class HyperbidNativeAd extends StatefulWidget {
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
  State<HyperbidNativeAd> createState() => _HyperbidNativeAdState();
}

class _HyperbidNativeAdState extends State<HyperbidNativeAd>
    with AutomaticKeepAliveClientMixin {
  late final String _adKey;
  MethodChannel? _channel;
  int? _viewId;

  @override
  void initState() {
    super.initState();
    _adKey = buildAdKey(widget.group, widget.placementId, widget.typeAd.id);
  }

  String buildAdKey(String group, String placementId, String type) {
    return '$group|$placementId|$type';
  }

  @override
  void dispose() {
    if (_viewId != null) {
      _channel?.invokeMethod('onDetach', {'adKey': _adKey});
      HyperbidAdRegistry.instance.detach(_adKey);
    }
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true; // ⭐ GIỮ VIEW KHI SCROLL

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SizedBox(
      width: widget.typeAd.width,
      height: widget.typeAd.height,
      child: AndroidView(
        key: ValueKey(_adKey),
        viewType: 'hyperbid_ads/native',
        creationParams: {
          'adKey': _adKey,
          'group': widget.group,
          'placementId': widget.placementId,
          'type': widget.typeAd.id,
        },
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      ),
    );
  }

  void _onPlatformViewCreated(int id) {
    _viewId = id;
    _channel = MethodChannel('hyperbid_ads/native_$id');

    HyperbidAdRegistry.instance.attach(_adKey, id);

    _channel!.invokeMethod('onAttach', {'adKey': _adKey});
  }
}
