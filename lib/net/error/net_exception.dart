/// 网络异常类

class NetWorkException implements Exception {
  int code;
  String message;

  NetWorkException(this.code, this.message);

  @override
  String toString() {
    return '网络异常{code: $code, message: $message}';
  }
}
