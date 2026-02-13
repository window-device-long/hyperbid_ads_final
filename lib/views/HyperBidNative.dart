import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyperbid_ads/core/modals/hb_type_ad.dart';
import 'package:hyperbid_ads/core/services/wrapper/AdsRemoteConfig.dart';

import '../channel/hyperbid_ads_platform_interface.dart';
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
  late final String _viewId;
  late final PageStorageKey _storageKey;
  late final bool _allowShow;
  late final ValueNotifier<NativeAdState> _state;

  @override
  void initState() {
    super.initState();

    _viewId = widget.viewId;
    _storageKey = PageStorageKey(_viewId);

    _allowShow = AdsRemoteConfig.canShowNative(
      type: widget.typeAd,
      placementId: widget.placementId,
      group: widget.group,
      screen: widget.screen,
    );

    _state = NativeAdStateStore.instance.watch(_viewId);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!_allowShow) return const SizedBox.shrink();

    return ValueListenableBuilder<NativeAdState>(
      valueListenable: _state,
      builder: (_, state, __) {
        return AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: widget.typeAd.width,
            height: state == NativeAdState.failed ? 0 : widget.typeAd.height,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: _slideTransition,
              child: _buildByState(state),
            ),
          ),
        );
      },
    );
  }

  /// ================= UI =================

  Widget _buildByState(NativeAdState state) {
    switch (state) {
      case NativeAdState.ready:
        return _buildNativeView(const ValueKey('native'));

      case NativeAdState.failed:
      default:
        return const SizedBox(key: ValueKey('empty'));
    }
  }

  Widget _buildLoading(Key key) {
    return Container(
      key: key,
      color: Colors.black.withOpacity(0.04),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildNativeView(Key key) {
    return AndroidView(
      key: key,
      viewType: 'hyperbid_ads/native',
      creationParams: {
        'group': widget.group,
        'placementId': widget.placementId,
        'type': widget.typeAd.id,
        'viewId': _viewId,
      },
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  Widget _slideTransition(Widget child, Animation<double> animation) {
    final slide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero);

    return SlideTransition(position: animation.drive(slide), child: child);
  }

  /// ================= RELOAD WHEN COME BACK =================

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_state.value == NativeAdState.failed) {
      _reloadNative();
    }
  }

  void _reloadNative() {
    HyperbidAdsPlatform.instance.reloadNativeActive(_viewId);

    _state.value = NativeAdState.ready;
  }

  /// ================= CLEANUP =================

  @override
  void dispose() {
    NativeAdStateStore.instance.dispose(_viewId);
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
