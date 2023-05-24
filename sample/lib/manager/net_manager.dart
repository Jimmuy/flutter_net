import 'package:flutter_net/net/flutter_net.dart';
import 'package:net_sample/bean/page.dart';
import 'package:net_sample/json/mapper.dart';

/// 简化网络请求而封装的顶层函数

///get 请求
Future<T> get<T>(String url, {params, Options? options, cancelToken}) async {
  return NetManager.getInstance().get<T>(url, params: params, options: options, token: cancelToken);
}

///post 请求
Future<T> post<T>(String url, {params, options, cancelToken}) async {
  return NetManager.getInstance().post<T>(url, params: params, options: options, token: cancelToken);
}

///delete 请求
Future<T> delete<T>(String url, {params, options, cancelToken}) async {
  return NetManager.getInstance().delete<T>(url, params: params, options: options, token: cancelToken);
}

///put 请求
Future<T> put<T>(String url, {params, options, cancelToken}) async {
  return NetManager.getInstance().put<T>(url, params: params, options: options, token: cancelToken);
}

///当网络请求返回格式为{"code":0,"msg":"OK","data":[]}形式的时候，使用requestList请求数据
Future<List<T>> requestList<T>(
  String url, {
  Method method: Method.GET,
  params,
  options,
  token,
}) async {
  return NetManager.getInstance().requestHttp<List<T>>(
    url,
    method,
    params: params,
    options: options,
    cancelToken: token,
    decode: (json) => fromJSONArray(json, objectMapper),
  );
}

///当网络请求返回格式为分页格式的时候，requestPage，分页的数据结构为PageObj仅供参考
Future<PageObj<T>> requestPage<T>(
  String url, {
  Method method: Method.GET,
  params,
  options,
  token,
}) async {
  return NetManager.getInstance().requestHttp<PageObj<T>>(
    url,
    method,
    params: params,
    options: options,
    cancelToken: token,
    decode: (json) => PageObj<T>.fromJson(json),
  );
}

///单例形式使用
class NetManager extends DioManager {
  NetManager._();

  static NetManager? _instance;

  static NetManager getInstance() {
    if (_instance == null) {
      _instance = NetManager._();
    }
    return _instance!;
  }

  @override
  T? decode<T>(response) => createObjByType<T>(response, objectMapper);

  @override
  String getBaseUrl() {
    return "https://mock.mengxuegu.com/mock/6073b60856076a4a7648458e/example";
  }

  @override
  bool isSuccess(Response response) {
    return response.data['code'] == HttpCode.SUCCESS;
  }

  @override
  NetWorkException getBusinessErrorResult<T>(int code, String error, T data) {
    return super.getBusinessErrorResult(code, error, data);
  }

  @override
  NetWorkException getHttpErrorResult(DioError e) {
    NetWorkException httpErrorResult = super.getHttpErrorResult(e);
    print("-----------------------HTTP ERROR ${httpErrorResult.data}");
    return httpErrorResult;
  }

  @override
  bool isShowLog() => true;

  @override
  void logout() {}
}
