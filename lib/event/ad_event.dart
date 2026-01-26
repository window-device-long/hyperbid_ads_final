class AdEvent {
  final String type;
  final String placementId;

  AdEvent(this.type, this.placementId);

  factory AdEvent.fromMap(Map<String, dynamic> map) {
    return AdEvent(map["type"], map["placementId"]);
  }
}
