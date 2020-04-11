
/// 网络异常类


class NetWorkException implements Exception {
  int code;
  String message;

  NetWorkException(this.code, this.message);
}
