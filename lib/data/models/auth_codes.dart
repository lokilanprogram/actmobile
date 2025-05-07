class AuthCodes {
  final String smsCode;
  final String phoneCode;

  AuthCodes({
    required this.smsCode,
    required this.phoneCode,
  });

  factory AuthCodes.fromDetail(String detail) {
    final smsMatch = RegExp(r'SMS\s(\d+)').firstMatch(detail);
    final callMatch = RegExp(r'Звонок\s(\d+)').firstMatch(detail);

    final smsCode = smsMatch?.group(1) ?? '';
    final callCode = callMatch?.group(1) ?? '';

    return AuthCodes(
      smsCode: smsCode,
      phoneCode: callCode,
    );
  }

  @override
  String toString() => 'SMS: $smsCode, Звонок: $phoneCode';
}
