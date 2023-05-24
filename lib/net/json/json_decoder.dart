import 'package:flutter/cupertino.dart';

///README
///
///默认提供了json对应实例化的工具，若需要其他方式解析（如xml,yaml等）则对应需要自行创建解析类进行数据解析
///
///如果返回格式为json格式，对应使用本类去解析即可

///将json解析成对应的实体类
T? createObjByType<T>(json, Map<dynamic, Function> typeMapper) {
  if (json == null || json.toString().isEmpty) {
    return null;
  } else if (json is Map) {
    //如果是对象进行实例化对象解析
    return _findObjCreatorFunc<T>(typeMapper)(json);
  } else {
    //如果不是 则直接返回原始类型 fix 类型是基本数据类型报错的bug
    return json;
  }
}

///[List]对象解析
List<T> fromJSONArray<T>(json, Map<dynamic, Function> typeMapper) {
  final list = <T>[];
  final function = _findObjCreatorFunc<T>(typeMapper);
  try {
    json.forEach((itemJson) {
      list.add(function(itemJson));
    });
  } catch (e) {
    print(e);
  }
  return list;
}

Function _findObjCreatorFunc<T>(Map<dynamic, Function> mapper) {
  final function = mapper[T];
  if (function == null) {
    String typeName = T.toString();
    if (typeName.startsWith('List')) {
      print('请使用fromJSONArray函数来解析List对象，接口请使用requestList来请求');
    } else if (typeName.startsWith('PageObj')) {
      print('请使用PageObj.fromJson函数来解析PageObj对象，接口请使用requestPage来请求');
    } else if (T == String) {
      return (json) => json.toString();
    } else {
      debugPrint("--------- json error '没有注册类:$T解析函数'");
    }
    throw '没有注册类:$T解析函数';
  }
  return function;
}
