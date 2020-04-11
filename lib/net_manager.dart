
import 'dio_manager.dart';

/// 简化网络请求而封装的顶层函数

Future<T> get<T>(String url, {params, options, cancelToken}) =>
    DioManager.getInstance().get<T>(url, params: params, options: options, token: cancelToken);

Future<T> post<T>(String url, {params, options, cancelToken}) =>
    DioManager.getInstance().post<T>(url, params: params, options: options, token: cancelToken);

Future<T> delete<T>(String url, {params, options, cancelToken}) =>
    DioManager.getInstance().delete<T>(url, params: params, options: options, token: cancelToken);

Future<T> put<T>(String url, {params, options, cancelToken}) =>
    DioManager.getInstance().put<T>(url, params: params, options: options, token: cancelToken);
