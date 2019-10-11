// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) {
  return CategoryModel(
    json['categoryName'] as String,
    (json['items'] as List)
        ?.map((e) =>
            e == null ? null : CategoryItem.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$CategoryModelToJson(CategoryModel instance) =>
    <String, dynamic>{
      'categoryName': instance.categoryName,
      'items': instance.items,
    };

CategoryItem _$CategoryItemFromJson(Map<String, dynamic> json) {
  return CategoryItem(
    json['name'] as String,
    json['image'] as String,
    json['sort'] as int,
  );
}

Map<String, dynamic> _$CategoryItemToJson(CategoryItem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'image': instance.image,
      'sort': instance.sort,
    };
