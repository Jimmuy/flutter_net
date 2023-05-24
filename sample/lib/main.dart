import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_net/net/constant/net_const.dart';
import 'package:flutter_net/net/error/net_exception.dart';

import 'bean/bean.dart';
import 'manager/net_manager.dart';

void main() {
  ///这个因为mock接口过期了所以加了一个跳过证书的操作，正常情况下不需要添加此行代码
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Net Sample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Net Sample'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({this.title}) : super();
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _content = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? ""),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            InkWell(
              onTap: () => sendGetRequest(),
              child: Container(
                alignment: Alignment.center,
                height: 50,
                margin: EdgeInsets.only(top: 20, left: 16, right: 16),
                color: Colors.blue[300],
                child: Text(
                  '点击发送GET/POST/PUT/DELETE等请求',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            InkWell(
              onTap: () => sendPageRequest(),
              child: Container(
                alignment: Alignment.center,
                height: 50,
                margin: EdgeInsets.only(top: 20, left: 16, right: 16),
                color: Colors.blue[300],
                child: Text(
                  '点击发送分页请求',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            InkWell(
              onTap: () => sendListRequest(),
              child: Container(
                alignment: Alignment.center,
                height: 50,
                margin: EdgeInsets.only(top: 20, left: 16, right: 16),
                color: Colors.blue[300],
                child: Text(
                  '点击发送列表请求',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              height: 30,
              margin: EdgeInsets.only(top: 20),
              color: Colors.blue[100],
              child: Text(
                '此sample为上层应用使用网络框架的示例用法，仅供参考',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.all(16),
                child: Text(
                  _content ?? "",
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  sendPageRequest() {
    setState(() {
      _content = "loading...";
    });

    requestPage<GetSampleBean>("/flutter_test/post", method: Method.POST)
        .then((value) => {
              setState(() {
                _content = "分页请求解析字段average值为： ${value.rows[0].rating?.average}";
              })
            })
        .catchError((error) {
      //错误处理，可以封装成顶层函数方便调用
      if (error is NetWorkException) {
        setState(() {
          _content = error.message;
        });
      }
    }).whenComplete(() => {
              //请求结束后，类似于finally,成功失败一定会走，在这里hideLoading
            });
  }

  sendGetRequest() {
    setState(() {
      _content = "loading...";
    });
    get<String>("/flutter_test/get")
        .then((value) => {
              setState(() {
                _content = "GET接口解析字段average值为： $value";
              })
            })
        .catchError((error) {
      //错误处理，可以封装成顶层函数方便调用
      if (error is NetWorkException) {
        setState(() {
          _content = error.message;
        });
      }
    }).whenComplete(() => {
              //请求结束后，类似于finally,成功失败一定会走，在这里hideLoading
            });
  }

  sendListRequest() {
    setState(() {
      _content = "loading...";
    });
    requestList<String>("/flutter_test/get_list")
        .then((value) => {
              setState(() {
                _content = "GET_LIST接口解析得到的数组第一个值为： ${value[0]}";
              })
            })
        .catchError((error) {
      //错误处理，可以封装成顶层函数方便调用
      if (error is NetWorkException) {
        setState(() {
          _content = error.message;
        });
      }
    }).whenComplete(() => {
              //请求结束后，类似于finally,成功失败一定会走，在这里hideLoading
            });
  }
}

///处理证书过期
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
