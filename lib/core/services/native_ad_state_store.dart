import 'package:flutter/foundation.dart';

enum NativeAdState { ready, failed }

class NativeAdStateStore {
  NativeAdStateStore._();
  static final instance = NativeAdStateStore._();

  final Map<String, ValueNotifier<NativeAdState>> _states = {};

  void handleEvent(Map<String, dynamic> event) {
    if (event['type'] != 'native_state') return;

    final viewId = event['viewId'];
    final state = event['state'];

    if (state == 'READY') {
      setReady(viewId);
    } else if (state == 'FAILED') {
      setFailed(viewId);
    }
  }

  ValueNotifier<NativeAdState> watch(String viewId) {
    return _states.putIfAbsent(
      viewId,
      () => ValueNotifier(NativeAdState.ready),
    );
  }

  void setReady(String viewId) {
    watch(viewId).value = NativeAdState.ready;
  }

  void setFailed(String viewId) {
    watch(viewId).value = NativeAdState.failed;
  }

  void dispose(String viewId) {
    _states.remove(viewId)?.dispose();
  }
}
