# 使用方式：

```
  添加如下项目的 pubspec.yaml 文件的dependencies中

  flutter_net:
     git:
       url: https://github.com/Jimmuy/flutter_net.git

```
# 摘要：

Flutter项目中的网络请求采用的是dio网络请求库，dio是一个强大的Dart Http请求库，支持Restful API、FormData、拦截器、请求取消、Cookie管理、文件上传/下载、超时、自定义适配器等...

关于dio的使用本文档不多作介绍，感兴趣可以 [到这里](https://github.com/flutterchina/dio/blob/master/README-ZH.md)查阅具体的使用

由于看到的封装方式都是基于回调的形式，那么再多个网络组合操作时不得不再用RxDart进行封装，而返回future形式很大程度上解决了这些问题。

本文档主要说明对dio使用的上层封装，简化了dio的使用，方便上层开发进行网络通信。

## 类文件说明：

```
/**
* 网络请求管理实现类，可根据项目需求进行自定义参数配置
*/
class DioManager extends AbstractDioManager{}
```


```
/**
* 网络请求管理类抽象层
* 负责执行网络请求的通用逻辑
* 不同项目的不同配置交给上层实现
*/
abstract class AbstractDioManager {}
```


```
/**
*常量类，定义了通用的网络请求错误以及常用的请求方式枚举（GET/POST/PUT/DELETE）,以及HTTP层的错误码
*/
class HttpCode {}
```

```
/**
* 网络异常类
*/
class NetWorkException implements Exception {}
```

```
/**

* json解析相关类 json_decoder.dart,负责json实例化

*/
```

```
net_manager
/**
* 简化网络请求而封装的顶层函数,提供常用的几种请求
*/
Future<T> get<T>(String url, {params, options, cancelToken}) =>
DioManager.getInstance().get<T>(url, params: params, options: options, token: cancelToken);
Future<T> post<T>(String url, {params, options, cancelToken}) =>
DioManager.getInstance().post<T>(url, params: params, options: options, token: cancelToken);
Future<T> delete<T>(String url, {params, options, cancelToken}) =>
DioManager.getInstance().delete<T>(url, params: params, options: options, token: cancelToken);
Future<T> put<T>(String url, {params, options, cancelToken}) =>
DioManager.getInstance().put<T>(url, params: params, options: options, token: cancelToken);

///当网络请求返回格式为{"code":0,"msg":"OK","data":[]}形式的时候，使用requestList请求数据

Future<List<T>> requestList <T>(String url , {Method method: Method. GET，  params , options , token , })

///当网络请求返回格式为分页形式的时候，使用requestList请求数据,，分页的数据结构为PageObj仅供参考

Future<List<T>> requestPage <T>(String url , Method method:Method. GET , params , options , token})

```
详情使用方式参见sample项目说明，请求库中默认提供了针对Json数据的的解析，sample中同样提供了推荐的json实例化方式，推荐使用

[json对象生成工具](https://javiercbk.github.io/json_to_dart/)工具来进行数据对象Model的生成。


## 使用：

通常情况下服务器返回的格式为code,message,data这种json形式，DioManager在初始化的时候也添加了对应的通用头，和业务错误码映射以及json解析方式等根据项目定制的功能，如果需要自定义请自行继承AbstractDioManager实现抽象方法来适配服务器的返回。在项目中默认默认实现好的为DioManger.

若需要自定义，通常需要实现如下方法

```
///具体的解析逻辑上层实现 diomanager 默认返回jsonstring 若需要实例化成实体请使用json序列化库进行实例化
T decode<T>(Response response);
///业务逻辑报错映射
NetWorkException getBusinessErrorResult(int code, String error);
/// HTTP层网络请求错误翻译
NetWorkException getHttpErrorResult(DioError e);
///初始化dio参数,统一配置参数
BaseOptions configBaseOptions();
///判断业务层的返回成功还是失败，失败后报错，成功后进行数据解析
bool isSuccess(Response response);
///默认是“code”获取response code 若服务器请求返回的code的key不一样,请重写此方法
int getCode(Response response) {
return response.data["code"];
}
///默认是“message”获取response message 若服务器请求返回的message的key不一样,请重写此方法
String getMessage(Response response) {
return response.data["message"];
}
///dio的配置工作，进行添加拦截器等操作
void configDio();
```


通常情况下使用DioManager默认实现即可，以get请求为例，如下：

```

/**
* @Model->数据实体，若想返回json string则可以直接将泛型定义为String
* @URL->请求的url
* @param->请求参数，可不填，不填为null,参数类型Map。
* @data->返回数据，填写泛型则返回实例化的对象
* @error->通常情况下返回包装好的 NetWorkException 对象，可以从对象中获取code和msg
*/
get<Model>(URL, params: map).then((data){
//使用网络请求返回值进行业务代码编写
}).catchError((error) {
//网络请求异常
}.whenComplete((){
//网络请求结束，类似于finally
});
//post delete put 请求的使用同理。
```
## 使用进阶：

调用顶层函数get/post/put/delete（为了方便，以下均采用post方式请求作为说明）返回值均为Future对象，所以使用Future可以组合出很多种请求方式。

e.g：A,B,C三个请求，A->B->C,即为A执行完之后执行B，B执行完之后执行C，C执行完这时网络请求流程结束。

```
Future(() {
return get<Model>(URL_A);
})
.then((data) {
//根据第一个请求的返回值请求下一个请求
return get<Model>(URL_B,data.param);
})
.then((data) {
//这里处理第二次请求的结果
return get<Model>(URL_C,data.param);
})
.then((data) {
//这里处理第三次次请求的结果
})
.catchError((error) {
// 这里处理请求异常的情况，包括http层code!=200的情况以及业务层code!=0的情况,这种写法可以在第一个网络请求失败后直接结束剩下的网络请求，也可以针对每次请求单独的获取异常的情况，具体的参照Future的使用，因为每个网络请求返回的类型都是Future类型，所以可以根据业务的不同定制流程。
```
})

e.g:A,B,C三个网络请求，C请求要等待A,B请求返回后进行请求。

```
Future.wait([
get<Model>(URL.A),
get<Model>(URL.B)
]).then((data) {
return get<DeviceListObj>(URL.C);
}).then((data) {
}).catchError((error) {
});
```
同样的，dart1.9后提供了await和aysnc的方式进行异步同步操作，aysnc的返回值依然是一个Future,可根据自己的喜好去处理组合的网络请求.
### 处理网络请求错误：

当单个网络请求时，可以使用catchError来获取服务器定义的请求失败的信息。

例如：

```
get<DeviceListObj>(URL.C).then((data) {
//success
}).catchError((error) {
if (error is NetWorkException){
//根据error.code 和 error.message 处理请求错误逻辑
}
```
});
当多个网络请求组合的时候，需要根据业务需求去判断是否需要针对每个网络请求返回的Future进行单独的catchError,值得注意的是，catchError的返回值依然是个future对象，若A->B->C的串行请求在A处进行了catchError操作而不在闭包里threw error或者return Future.error的话，这个串行请求就会继续下去，如果在最后进行catchError那么在A处发生失败时，剩下的请求就不会进行下去了.

```
//第一种情况
Future(() {
return get<Model>(URL_A);
})
.then((data) {
//根据第一个请求的返回值请求下一个请求
return get<Model>(URL_B,data.param);
})
.then((data) {
//这里处理第二次请求的结果
return get<Model>(URL_C,data.param);
})
.then((data) {
//这里处理第三次次请求的结果
})
.catchError((error) {
//这种情况，当A出错，后面的B和C都不会执行，error是A的error response
})
//第二种情况
Future(() {
return get<Model>(URL_A);
}).then((data) {
//根据第一个请求的返回值请求下一个请求
return get<Model>(URL_B,data.param);
}) .catchError((error) {
//这种情况，当A出错，后面的B和C依然会执行若想终端剩下的操作，则需要threw error 或者 return Future.error
})
.then((data) {
//这里处理第二次请求的结果
return get<Model>(URL_C,data.param);
})
.then((data) {
//这里处理第三次次请求的结果
})
```
### 终止网络请求：

```
CancelToken token = CancelToken();
dio.get(url, cancelToken: token)
.catchError((DioError err){
if (CancelToken.isCancel(err)) {
print('Request canceled! '+ err.message)
}else{
// handle error.
}
});
// cancel the requests with "cancelled" message.
token.cancel("cancelled");
```
注意: 同一个cancel token 可以用于多个请求，当一个cancel token取消时，所有使用该cancel token的请求都会被取消。CancelToken的内部实现是使用了Completer
关于Completer的使用大概是下面这样。

```
// 实例化一个Completer
var completer = Completer();
// 这里可以拿到这个completer内部的Future
var future = completer.future;
// 需要的话串上回调函数。
future.then((value)=> print('$value'));
//做些其它事情
...
// 设置为完成状态
completer.complete("done");
```
上述代码片段中，当你创建了一个Completer以后，其内部会包含一个Future。你可以在这个Future上通过then, catchError和whenComplete串上你需要的回调。拿着这个Completer实例，在你的代码里的合适位置，通过调用complete函数即可完成这个Completer对应的Future。控制权完全在你自己的代码手里。当然你也可以通过调用completeError来以异常的方式结束这个Future。
除了dio提供的cancel方式之外，Steam流也可以实现类似的效果：

```
var asStream = get<Model>(URL).asStream();
var listen = asStream.listen((data){
//处理逻辑
});
listen.cancel();
```
通过listene去监听数据流然后通过cancel方法可以取消监听，如果需要取消网络请求，还是推荐使用封装好的cancelToken。
