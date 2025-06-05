class ApiError {
  final List<ErrorDetail> detail;

  ApiError({required this.detail});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      detail:
          (json['detail'] as List)
              .map((e) => ErrorDetail.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }
}

class ErrorDetail {
  final List<String> loc;
  final String msg;
  final String type;

  ErrorDetail({required this.loc, required this.msg, required this.type});

  factory ErrorDetail.fromJson(Map<String, dynamic> json) {
    return ErrorDetail(
      loc: (json['loc'] as List).map((e) => e as String).toList(),
      msg: json['msg'] as String,
      type: json['type'] as String,
    );
  }
}
