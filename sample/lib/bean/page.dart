import 'package:flutter_net/net/json/json_decoder.dart';
import 'package:net_sample/json/mapper.dart';

///分页逻辑的实体类，如分页方式与字段不同，最好使用PageObj作为类名，解析错误的话会有错误提示（非必须）
class PageObj<T> {
  int pageNo;
  int pageSize;
  int totalPage;
  int total;
  bool hasNextPage;
  bool hasPreviousPage;
  bool firstPage;
  bool lastPage;
  List<T> rows = [];

  PageObj();

  PageObj.fromJson(Map<String, dynamic> json) {
    this.pageNo = json['pageNo'];
    this.pageSize = json['pageSize'];
    this.totalPage = json['totalPage'];
    this.total = json['total'];
    this.hasNextPage = json['hasNextPage'];
    this.hasPreviousPage = json['hasPreviousPage'];
    this.firstPage = json['firstPage'];
    this.lastPage = json['lastPage'];
    rows = fromJSONArray<T>(json['rows'] ?? [], objectMapper);
  }
}
