import 'package:dio/dio.dart';

import '../constant/net_const.dart';
import '../error/net_exception.dart';

/// 网络请求管理类抽象层\
/// 负责执行网络请求的通用逻辑
/// 不同项目的不同配置交给上层实现

abstract class AbstractDioManager {
  late Dio dio;

  AbstractDioManager() {
    dio = new Dio(configBaseOptions());
    configDio();
  }

  ///get请求
  Future<T> get<T>(String url, {Map<String, dynamic>? params, Options? options, token}) async {
    return requestHttp<T>(
      url,
      Method.GET,
      params: params,
      options: options,
      cancelToken: token,
      decode: this.decode,
    );
  }

  ///post请求
  Future<T> post<T>(String url, {Map<String, dynamic>? params, Options? options, token}) async {
    return requestHttp<T>(
      url,
      Method.POST,
      params: params,
      options: options,
      cancelToken: token,
      decode: this.decode,
    );
  }

  Future<T> delete<T>(String url, {Map<String, dynamic>? params, Options? options, token}) async {
    return requestHttp<T>(
      url,
      Method.DELETE,
      params: params,
      options: options,
      cancelToken: token,
      decode: this.decode,
    );
  }

  Future<T> put<T>(String url, {Map<String, dynamic>? params, Options? options, token}) async {
    return requestHttp<T>(
      url,
      Method.PUT,
      params: params,
      options: options,
      cancelToken: token,
      decode: this.decode,
    );
  }

  Future<T> patch<T>(String url, {Map<String, dynamic>? params, Options? options, token}) async {
    return requestHttp<T>(
      url,
      Method.PATCH,
      params: params,
      options: options,
      cancelToken: token,
      decode: this.decode,
    );
  }

  Future<R> requestHttp<R>(String url,
      Method method, {
        Map<String, dynamic>? params,
        Map<String, dynamic>? headers,
        String mediaType = 'application/json; charset=utf-8',
        options,
        cancelToken,
        required R? decode(dynamic json),
      }) {
    final methodName = method.toString().split('.')[1];
    if (method == Method.GET) {
      return request(
        url,
        methodName,
        params: params,
        headers: headers,
        mediaType: mediaType,
        cancelToken: cancelToken,
        options: options,
        decode: decode,
      );
    }
    return request(
      url,
      methodName,
      body: params,
      headers: headers,
      mediaType: mediaType,
      cancelToken: cancelToken,
      options: options,
      decode: decode,
    );
  }

  ///R是返回类型，T是数据类型
  Future<R> request<R>(String url,
      String method, {
        Map<String, dynamic>? params,
        Map<String, dynamic>? body,
        Map<String, dynamic>? headers,
        String mediaType = 'application/json; charset=utf-8',
        Options? options,
        cancelToken,
        required R? decode(dynamic json),
      }) async {
    Response response;


    final opt = options ?? Options();
    try {
      response = await dio.request(
        url,
        data: body,
        options: opt.copyWith(
          headers: headers,
          method: method.toUpperCase(),
          responseType: ResponseType.json,
          contentType: mediaType,
        ),
        queryParameters: params,
      );
    } on DioError catch (error) {
      if (isShowLog()) printParams(params ?? body ?? {}, url, headers, null);
      print("---------- net error $error");
      throw getHttpErrorResult(error);
    }

    ///打印日志
    if (isShowLog()) printParams(params ?? body ?? {}, url, headers, response);
    dynamic data;
    //优先解析请求是否出错
    if (!isSuccess(response)) {
      handleFailed(response, data, decode);
    } else {
      //确保请求成功的情况下，再实例化数据
      data = handleSuccess(data, decode, response);
    }
    return data;
  }

  R handleSuccess<R>(data, decode(dynamic json), Response<dynamic> response) {
    //确保请求成功的情况下，再实例化数据
    try {
      data = decode(response.data['data']);
      return data as R;
    } catch (e) {
      throw getBusinessErrorResult(HttpCode.PARSE_JSON_ERROR, "json parse error 0 ~ $e", null);
    }
  }

  handleFailed(Response<dynamic> response, data, decode(dynamic json)) {
    if (response.data is Map && response.data["data"] != null) {
      try {
        data = decode(response.data['data']);
      } catch (e) {
        ///解析数据出错
        throw getBusinessErrorResult(HttpCode.PARSE_JSON_ERROR, "json parse error 1 ~ $e", null);
      }

      ///抛出含有数据的error
      throw getBusinessErrorResult(getCode(response), getMessage(response), data);
    } else {
      ///抛出没有数据的error
      throw getBusinessErrorResult(getCode(response), getMessage(response), null);
    }
  }

  void printParams(Map<String, dynamic> params, url, headers, response) {
    print("------ url:$url");
    print("------ headers:$headers");

    final pms = params.toString();
    final len = pms.length;
    final res = response == null ? "" : response.data?.toString() ?? "";
    try {
      if (len > 100) {
        int startIndex = 0;
        int endIndex = 100;
        while (true) {
          print("---------- params: ${pms.substring(startIndex, endIndex)}");
          if (endIndex == pms.length) {
            break;
          }
          startIndex = endIndex;
          endIndex += 100;
          if (endIndex > pms.length) {
            endIndex = pms.length;
          }
        }
      } else {
        print("---------- params: $pms");
      }
    } catch (e) {
      print("---------- printLog()打印参数异常----");
    }
    try {
      int length = 1500;
      final len = res.length;
      if (len > length) {
        int startIndex = 0;
        int endIndex = length;
        while (true) {
          print("------------response: ${res.substring(startIndex, endIndex)}");
          if (endIndex == res.length) {
            break;
          }
          startIndex = endIndex;
          endIndex += length;
          if (endIndex > res.length) {
            endIndex = res.length;
          }
        }
      } else {
        print("------------response: $res");
      }
    } catch (e) {
      print("---------- printLog()打印response异常----");
    }
  }

  ///具体的解析逻辑上层实现
  T? decode<T>(dynamic response);

  ///业务逻辑报错映射
  NetWorkException getBusinessErrorResult<T>(int code, String error, T data);

  /// HTTP层网络请求错误翻译
  NetWorkException getHttpErrorResult(DioError e);

  ///初始化dio参数
  BaseOptions configBaseOptions();

  ///判断业务层的返回成功还是失败，失败后报错，成功后进行数据解析
  bool isSuccess(Response response);

  ///默认是“code”获取response code 若服务器请求返回的code的key不一样,请重写此方法
  int getCode(Response response) {
    return response.data["code"];
  }

  ///是否显示log日志
  bool isShowLog() => false;

  ///默认是“message”获取response message 若服务器请求返回的message的key不一样,请重写此方法
  String getMessage(Response response) {
    return response.data["message"];
  }

  ///dio的配置工作，进行添加拦截器等操作
  void configDio();
}
