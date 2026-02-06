import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hyperbid_ads/channel/hyperbid_ads_platform_interface.dart';
import 'package:hyperbid_ads/controller/HyperAdsController.dart';
import 'package:hyperbid_ads/views/HyperBidNative.dart';
import '../core/modals/hb_type_ad.dart';

enum _AdsFlowState { loading, interstitial, native1, native2, done }

class HyperbidFullscreenAdsFlow extends StatefulWidget {
  final String screen;
  final String group;
  final String interPlacementId;
  final String nativePlacementId;
  final VoidCallback onFinished;

  const HyperbidFullscreenAdsFlow({
    super.key,
    required this.screen,
    required this.group,
    required this.interPlacementId,
    required this.nativePlacementId,
    required this.onFinished,
  });

  @override
  State<HyperbidFullscreenAdsFlow> createState() =>
      _HyperbidFullscreenAdsFlowState();
}

class _HyperbidFullscreenAdsFlowState extends State<HyperbidFullscreenAdsFlow> {
  _AdsFlowState _state = _AdsFlowState.loading;

  Timer? _ticker;

  late final _AdProgress _native1;
  late final _AdProgress _native2;

  @override
  void initState() {
    super.initState();

    _native1 = _AdProgress(_randomBetween(4, 6));
    _native2 = _AdProgress(_randomBetween(2, 4));

    _startFlow();
  }

  // ================= FLOW =================

  Future<void> _startFlow() async {
    await Future.delayed(const Duration(milliseconds: 200));

    setState(() => _state = _AdsFlowState.interstitial);
    await HyperbidAdsPlatform.instance.showInterstitial(screen: widget.screen);

    _startNative1();
  }

  void _startNative1() {
    setState(() => _state = _AdsFlowState.native1);

    _runTickerWithDelay(progress: _native1, onDone: _startNative2);
  }

  void _startNative2() {
    setState(() => _state = _AdsFlowState.native2);

    _runTickerWithDelay(progress: _native2, onDone: _finishFlow);
  }

  void _finishFlow() {
    _ticker?.cancel();
    setState(() => _state = _AdsFlowState.done);
    widget.onFinished();
  }

  // ================= TICKER (DELAY 2s) =================

  void _runTickerWithDelay({
    required _AdProgress progress,
    required VoidCallback onDone,
    Duration delay = const Duration(seconds: 2),
  }) async {
    _ticker?.cancel();

    // ⏸️ buffer cho native render
    await Future.delayed(delay);
    if (!mounted) return;

    progress.start();

    _ticker = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted) return;

      setState(() {});

      if (progress.isDone) {
        t.cancel();
        onDone();
      }
    });
  }

  int _randomBetween(int min, int max) {
    final r = DateTime.now().microsecondsSinceEpoch;
    return min + (r % (max - min + 1));
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _whiteLoading(),

          _nativeLayer(
            visible: _state == _AdsFlowState.native1,
            viewId: "native_1",
          ),

          _nativeLayer(
            visible: _state == _AdsFlowState.native2,
            viewId: "native_2",
          ),

          _progressOverlay(active: _native1, next: _native2),
        ],
      ),
    );
  }

  Widget _whiteLoading() {
    return Offstage(
      offstage:
          _state != _AdsFlowState.loading &&
          _state != _AdsFlowState.interstitial,
      child: Container(
        color: Colors.white,
        alignment: Alignment.center,
        width: double.infinity,
        height: double.infinity,
        child: const CircularProgressIndicator(),
      ),
    );
  }

  Widget _nativeLayer({required bool visible, required String viewId}) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: HyperbidNativeAd(
            group: widget.group,
            screen: widget.screen,
            viewId: viewId,
            placementId: widget.nativePlacementId,
            typeAd: HBTypeAd.nativeFull,
          ),
        ),
      ),
    );
  }

  Widget _progressOverlay({required _AdProgress active, _AdProgress? next}) {
    return Positioned(
      left: 16,
      right: 16,
      top: 40,
      child: Row(
        children: [
          Expanded(flex: 2, child: _progressBar(active, active: true)),
          if (next != null) ...[
            const SizedBox(width: 6),
            Expanded(child: _progressBar(next, active: false)),
          ],
        ],
      ),
    );
  }

  Widget _progressBar(_AdProgress p, {required bool active}) {
    return LinearProgressIndicator(
      value: p.progress,
      minHeight: 4,
      borderRadius: BorderRadius.circular(4),
      backgroundColor: Colors.white24,
      valueColor: AlwaysStoppedAnimation(
        active ? Colors.greenAccent : Colors.white38,
      ),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

// ================= MODEL =================

class _AdProgress {
  final int duration; // seconds
  DateTime? _startTime;

  _AdProgress(this.duration);

  void start() {
    _startTime ??= DateTime.now();
  }

  double get progress {
    if (_startTime == null) return 0;
    final elapsed = DateTime.now().difference(_startTime!).inMilliseconds;
    return (elapsed / (duration * 1000)).clamp(0.0, 1.0);
  }

  bool get isDone => progress >= 1.0;
}
