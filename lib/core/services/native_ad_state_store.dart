import 'package:flutter/foundation.dart';

enum NativeAdState { ready, failed }

class NativeAdStateStore {
  NativeAdStateStore._();
  static final instance = NativeAdStateStore._();

  final Map<String, ValueNotifier<NativeAdState>> _states = {};

  ValueNotifier<NativeAdState> watch(String viewId) {
    return _states.putIfAbsent(
      viewId,
      () => ValueNotifier(NativeAdState.ready),
    );
  }

  void update(String viewId, NativeAdState state) {
    final notifier = _states[viewId];
    if (notifier != null && notifier.value != state) {
      notifier.value = state;
    }
  }

  void dispose(String viewId) {
    _states.remove(viewId)?.dispose();
  }

  void setReady(String viewId) {
    watch(viewId).value = NativeAdState.ready;
  }

  void setFailed(String viewId) {
    watch(viewId).value = NativeAdState.failed;
  }
}
