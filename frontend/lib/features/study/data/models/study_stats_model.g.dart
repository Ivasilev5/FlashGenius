// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudyStatsModel _$StudyStatsModelFromJson(Map<String, dynamic> json) =>
    StudyStatsModel(
      newCount: json['new_count'] as int? ?? 0,
      reviewCount: json['review_count'] as int? ?? 0,
      learnedCount: json['learned_count'] as int? ?? 0,
    );

Map<String, dynamic> _$StudyStatsModelToJson(StudyStatsModel instance) =>
    <String, dynamic>{
      'new_count': instance.newCount,
      'review_count': instance.reviewCount,
      'learned_count': instance.learnedCount,
    };
