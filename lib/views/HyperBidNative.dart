import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyperbid_ads/core/modals/hb_type_ad.dart';
import 'package:hyperbid_ads/core/services/wrapper/AdsRemoteConfig.dart';

import '../core/services/native_ad_state_store.dart';

class HyperbidNativeAd extends StatefulWidget {
  final HBTypeAd typeAd;
  final String group;
  final String screen;
  final String viewId;
  final String placementId;

  const HyperbidNativeAd({
    super.key,
    required this.group,
    this.screen = "Home",
    required this.viewId,
    required this.placementId,
    this.typeAd = HBTypeAd.native,
  });

  @override
  State<HyperbidNativeAd> createState() => _HyperbidNativeAdState();
}

class _HyperbidNativeAdState extends State<HyperbidNativeAd>
    with AutomaticKeepAliveClientMixin {
  late final ValueNotifier<NativeAdState> _state;
  late final bool _allowShow;

  bool _visible = true;

  @override
  void initState() {
    super.initState();

    _allowShow = AdsRemoteConfig.canShowNative(
      type: widget.typeAd,
      placementId: widget.placementId,
      group: widget.group,
      screen: widget.screen,
    );

    if (!_allowShow) {
      _visible = false;
      return;
    }

    _state = NativeAdStateStore.instance.watch(widget.viewId);
    _state.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (!mounted) return;

    if (_state.value == NativeAdState.failed && _visible) {
      setState(() {
        _visible = false; // 🔥 collapse hoàn toàn
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!_allowShow || !_visible) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: widget.typeAd.width,
      height: widget.typeAd.height,
      child: AndroidView(
        key: ValueKey(widget.viewId),
        viewType: 'hyperbid_ads/native',
        creationParams: {
          'group': widget.group,
          'placementId': widget.placementId,
          'type': widget.typeAd.id,
          'viewId': widget.viewId,
        },
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }

  @override
  void dispose() {
    if (_allowShow) {
      _state.removeListener(_onStateChanged);
      NativeAdStateStore.instance.dispose(widget.viewId);
    }
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
