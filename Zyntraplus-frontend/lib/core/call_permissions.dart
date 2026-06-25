import 'call_service.dart';

/// Thrown when mic/camera permission is denied for a call.
class CallPermissionException implements Exception {
  final String message;
  const CallPermissionException(this.message);

  @override
  String toString() => message;
}

abstract final class CallPermissions {
  /// Browser/OS permission prompts are triggered by getUserMedia in [CallService].
  static Future<void> ensureForCall(CallType callType) async {}
}
