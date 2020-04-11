import 'package:dio/dio.dart';

import 'abstract_dio_manager.dart';
import 'net_const.dart';
import 'net_exception.dart';

/// 网络请求管理类
class DioManager extends AbstractDioManager {
  static DioManager _instance; //单例管理

  static DioManager getInstance() {
    if (_instance == null) {
      _instance = DioManager();
    }
    return _instance;
  }

  ///统一配置，用于添加统一头，单度添加请求配置请在请求中填写，单次的配置只影响单次的请求，并不影响统一配置
  @override
  BaseOptions configBaseOptions() {
    return BaseOptions(
        connectTimeout: HttpCode.TIME_OUT,
        receiveTimeout: HttpCode.TIME_OUT,
        headers: {
//          "Authorization": "bearer xxxxxx"
        },
        responseType: ResponseType.json);
  }

  @override
  void configDio() {
    dio.interceptors.add(LogInterceptor(responseBody: true)); //是否开启请求日志
  }

  ///业务逻辑报错映射，目前暂时不做翻译工作，默认返回服务端返回的报错信息
  @override
  NetWorkException getBusinessErrorResult(int code, String error) => NetWorkException(code, error);

  /// HTTP层网络请求错误翻译
  @override
  NetWorkException getHttpErrorResult(DioError e) {
    Response errorResponse;
    if (e.response != null) {
      errorResponse = e.response;
    } else {
      errorResponse = new Response(statusCode: HttpCode.UNKNOWN_NET_ERROR, statusMessage: "未知错误");
    }
    if (e.type == DioErrorType.CONNECT_TIMEOUT) {
      errorResponse.statusMessage = "连接超时";
      errorResponse.statusCode = HttpCode.CONNECT_TIMEOUT;
    } else if (e.type == DioErrorType.SEND_TIMEOUT) {
      errorResponse.statusMessage = "请求超时";
      errorResponse.statusCode = HttpCode.SEND_TIMEOUT;
    } else if (e.type == DioErrorType.RECEIVE_TIMEOUT) {
      errorResponse.statusMessage = "响应超时";
      errorResponse.statusCode = HttpCode.RECEIVE_TIMEOUT;
    } else if (e.type == DioErrorType.CANCEL) {
      errorResponse.statusMessage = "请求取消";
      errorResponse.statusCode = HttpCode.REQUEST_CANCEL;
    } else if (e.type == DioErrorType.RESPONSE) {
      switch (e.response?.statusCode) {
        case 400:
          errorResponse.statusMessage = "请求语法错误";
          break;
        case 401:
          errorResponse.statusMessage = "鉴权失败";
          break;
        case 403:
          errorResponse.statusMessage = "服务器拒绝执行";
          break;
        case 404:
          errorResponse.statusMessage = "无法连接服务器";
          break;
        case 405:
          errorResponse.statusMessage = "请求方法被禁止";
          break;
        case 500:
          errorResponse.statusMessage = "服务器内部错误";
          break;
        case 502:
          errorResponse.statusMessage = "无效的请求";
          break;
        case 503:
          errorResponse.statusMessage = "服务器挂了";
          break;
        case 505:
          errorResponse.statusMessage = "不支持HTTP协议请求";
          break;
        default:
          errorResponse.statusMessage = "未知错误";
          break;
      }
    } else {
      errorResponse.statusMessage = "未知错误";
      errorResponse.statusCode = HttpCode.UNKNOWN_NET_ERROR;
    }
    return new NetWorkException(errorResponse.statusCode, errorResponse.statusMessage);
  }

  @override
  bool isSuccess(Response response) => response.data["code"] != HttpCode.SUCCESS || !response.data["success"];

  @override
  ///默认实现返回json String 返回其他实体请使用json序列化库进行序列化实体
  T decode<T>(Response response) => response.data["data"].toString() as T;
}
