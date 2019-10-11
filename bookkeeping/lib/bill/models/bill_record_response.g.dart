// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_record_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillRecordResponse _$BillRecordResponseFromJson(Map<String, dynamic> json) {
  return BillRecordResponse(
    json['code'] as int,
    (json['data'] as List)
        ?.map((e) => e == null
            ? null
            : BillRecordModel.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['msg'] as String,
  );
}

Map<String, dynamic> _$BillRecordResponseToJson(BillRecordResponse instance) =>
    <String, dynamic>{
      'code': instance.code,
      'data': instance.data,
      'msg': instance.msg,
    };

BillRecordModel _$BillRecordModelFromJson(Map<String, dynamic> json) {
  return BillRecordModel(
    json['id'] as int,
    (json['money'] as num)?.toDouble(),
    json['remark'] as String,
    json['type'] as int,
    json['categoryName'] as String,
    json['image'] as String,
    json['createTime'] as String,
    json['createTimestamp'] as int,
    json['updateTime'] as String,
    json['updateTimestamp'] as int,
  )
    ..isSync = json['isSync'] as int
    ..isDelete = json['isDelete'] as int;
}

Map<String, dynamic> _$BillRecordModelToJson(BillRecordModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'money': instance.money,
      'remark': instance.remark,
      'categoryName': instance.categoryName,
      'image': instance.image,
      'type': instance.type,
      'isSync': instance.isSync,
      'isDelete': instance.isDelete,
      'createTime': instance.createTime,
      'createTimestamp': instance.createTimestamp,
      'updateTime': instance.updateTime,
      'updateTimestamp': instance.updateTimestamp,
    };
