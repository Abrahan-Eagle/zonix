// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Document _$DocumentFromJson(Map<String, dynamic> json) => Document(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String,
      number: (json['number'] as num?)?.toInt(),
      receiptN: (json['receiptN'] as num?)?.toInt(),
      rifUrl: json['rifUrl'] as String?,
      taxDomicile: json['taxDomicile'] as String?,
      frontImage: json['frontImage'] as String?,
      backImage: json['backImage'] as String?,
      issuedAt: json['issuedAt'] as String?,
      expiresAt: json['expiresAt'] as String?,
      approved: json['approved'] as bool,
      status: json['status'] as bool,
      profileId: (json['profileId'] as num).toInt(),
    );

Map<String, dynamic> _$DocumentToJson(Document instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'number': instance.number,
      'receiptN': instance.receiptN,
      'rifUrl': instance.rifUrl,
      'taxDomicile': instance.taxDomicile,
      'frontImage': instance.frontImage,
      'backImage': instance.backImage,
      'issuedAt': instance.issuedAt,
      'expiresAt': instance.expiresAt,
      'approved': instance.approved,
      'status': instance.status,
      'profileId': instance.profileId,
    };
