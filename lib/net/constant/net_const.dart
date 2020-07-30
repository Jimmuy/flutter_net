class Token {
  static String token;
}

///错误编码
class HttpCode {
  ///未知网络错误
  static const UNKNOWN_NET_ERROR = 10086;

  ///网络错误
  static const NETWORK_ERROR = -1001;

  ///网络超时
  static const CONNECT_TIMEOUT = -1002;
  static const SEND_TIMEOUT = -1003;
  static const RECEIVE_TIMEOUT = -1004;

  ///请求取消
  static const REQUEST_CANCEL = -1005;

  ///JSON解析异常
  static const PARSE_JSON_ERROR = -1006;

  ///成功的code
  static const SUCCESS = 0;

  ///超时时长
  static const TIME_OUT = 15000;
}

enum Method { GET, POST, PUT, DELETE }
