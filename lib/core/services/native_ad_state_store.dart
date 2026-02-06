import 'package:flutter/foundation.dart';

enum NativeAdState { loading, ready, failed }

class NativeAdStateStore {
  NativeAdStateStore._();
  static final instance = NativeAdStateStore._();

  final Map<String, ValueNotifier<NativeAdState>> _states = {};

  ValueNotifier<NativeAdState> watch(String viewId) {
    return _states.putIfAbsent(
      viewId,
      () => ValueNotifier(NativeAdState.loading),
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
}
