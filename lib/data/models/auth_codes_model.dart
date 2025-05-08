class AuthCodesModel {
  final String smsCode;
  final String phoneCode;

  AuthCodesModel({
    required this.smsCode,
    required this.phoneCode,
  });

  factory AuthCodesModel.fromDetail(String detail) {
    final smsMatch = RegExp(r'SMS\s(\d+)').firstMatch(detail);
    final callMatch = RegExp(r'Звонок\s(\d+)').firstMatch(detail);

    final smsCode = smsMatch?.group(1) ?? '';
    final callCode = callMatch?.group(1) ?? '';

    return AuthCodesModel(
      smsCode: smsCode,
      phoneCode: callCode,
    );
  }

  @override
  String toString() => 'SMS: $smsCode, Звонок: $phoneCode';
}
