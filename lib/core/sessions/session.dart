class Session {
  final String deviceId;
  final String aptCode;
  final String aptName;
  final String bouncerCode;
  final String bouncerName;

  const Session({
    required this.deviceId,
    required this.aptCode,
    required this.aptName,
    required this.bouncerCode,
    required this.bouncerName,
  });
 
  @override
  String toString() {
    return 'Session(deviceId=$deviceId, aptCode=$aptCode, bouncerCode=$bouncerCode)';
  }
}