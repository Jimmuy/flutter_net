import 'package:dio/dio.dart';

import '../constant/net_const.dart';
import '../error/net_exception.dart';
import 'abstract_dio_manager.dart';

/// dio网络请求管理类，实现了大部分通用逻辑，需要按照项目需求自定义的部分请在子类中实现，子类应是单例

abstract class DioManager extends AbstractDioManager {
  ///统一配置，用于添加统一头，单度添加请求配置请在请求中填写，单次的配置只影响单次的请求，并不影响统一配置
  @override
  BaseOptions configBaseOptions() {
    return BaseOptions(
        connectTimeout: HttpCode.TIME_OUT, receiveTimeout: HttpCode.TIME_OUT, baseUrl: getBaseUrl(), responseType: ResponseType.json);
  }

  @override
  void configDio() {
    dio.interceptors.add(LogInterceptor(requestBody: isShowLog(), responseBody: isShowLog())); //是否开启请求日志
  }

  ///业务逻辑报错映射，目前暂时不做翻译工作，默认返回服务端返回的报错信息
  @override
  NetWorkException getBusinessErrorResult<T>(int code, String error, T data) => NetWorkException<T>(code, error, data: data);

  /// HTTP层网络请求错误翻译
  @override
  NetWorkException getHttpErrorResult(DioError e) {
    String? statusMessage;
    int? statusCode;
    if (e.response != null) {
      statusCode = e.response?.statusCode;
      statusMessage = e.response?.statusMessage;
    }
    if (e.type == DioErrorType.connectTimeout) {
      statusMessage = "连接超时";
      statusCode = HttpCode.CONNECT_TIMEOUT;
    } else if (e.type == DioErrorType.sendTimeout) {
      statusMessage = "请求超时";
      statusCode = HttpCode.SEND_TIMEOUT;
    } else if (e.type == DioErrorType.receiveTimeout) {
      statusMessage = "响应超时";
      statusCode = HttpCode.RECEIVE_TIMEOUT;
    } else if (e.type == DioErrorType.cancel) {
      statusMessage = "请求取消";
      statusCode = HttpCode.REQUEST_CANCEL;
    } else if (e.type == DioErrorType.response) {
      check(e.response);
      switch (e.response?.statusCode) {
        case 400:
          statusMessage = "请求语法错误";
          break;
        case 401:
          //退出登录
          logout();
          statusMessage = "鉴权失败";
          break;
        case 403:
          statusMessage = "服务器拒绝执行";
          break;
        case 404:
          statusMessage = "无法连接服务器";
          break;
        case 405:
          statusMessage = "请求方法被禁止";
          break;
        case 500:
          statusMessage = "服务器内部错误";
          break;
        case 502:
          statusMessage = "无效的请求";
          break;
        case 503:
          statusMessage = "服务器挂了";
          break;
        case 505:
          statusMessage = "不支持HTTP协议请求";
          break;
        default:
          statusMessage = "未知错误";
          break;
      }
    } else {
      statusMessage = "未知错误";
      statusCode = HttpCode.UNKNOWN_NET_ERROR;
    }
    return new NetWorkException(statusCode, statusMessage, data: e);
  }

  ///判断网络请求是否成功
  @override
  bool isSuccess(Response response) => response.data["code"] == HttpCode.SUCCESS && response.data["success"];

  ///设置baseURl
  String getBaseUrl();

  ///token失效登出逻辑
  void logout();

  bool needCheck403() => false;

  ///  * 为了不影响以前业务以及别的业务线
  ///  * 网关端在响应头里新增字段 X-Status-Code 来区分是真的401还是403，此时 response?.statusCode 返回的仍是401
  ///  * 是403时 body会返回没有权限的 权限码和名字json(目前已跟产品确认不需要toast提示)
  ///  * 包含此字段时才去判断 不包含则继续维持之前逻辑 ,如果是真的403  则将response?.statusCode赋值为403
  ///
  void check(Response? response) {
    if (response != null) {
      Headers headers = response.headers;
      var code;
      try {
        code = headers.value(Authority.AUTHORITY_ERROR_HEADER_KEY);
      } catch (e) {
        code = null;
      }
      if (Authority.AUTHORITY_ERROR_CODE.toString() == code) {
        ///如果响应头里 X-Status-Code有值且是403 说明是真的没有权限 此时把code赋值为403，
        response.statusCode = Authority.AUTHORITY_ERROR_CODE;
      }
    }
  }
}
