/// 网络异常类

class NetWorkException<T> implements Exception {
  int? code;
  String? message;
  T? data;

  NetWorkException(this.code, this.message, {this.data});

  @override
  String toString() {
    return '网络异常{code: $code, message: $message, data: $data}';
  }
}
