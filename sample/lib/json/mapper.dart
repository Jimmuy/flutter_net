import 'package:net_sample/bean/bean.dart';

///维护Type和Creator的对应关系
final objectMapper = {
  GetSampleBean: (json) => GetSampleBean.fromJson(json),
};
