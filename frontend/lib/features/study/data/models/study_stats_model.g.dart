// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudyStatsModel _$StudyStatsModelFromJson(Map<String, dynamic> json) =>
    StudyStatsModel(
      totalCards: json['totalCards'] as int? ?? 0,
      dueToday: json['dueToday'] as int? ?? 0,
      learnedCards: json['learnedCards'] as int? ?? 0,
    );

Map<String, dynamic> _$StudyStatsModelToJson(StudyStatsModel instance) =>
    <String, dynamic>{
      'totalCards': instance.totalCards,
      'dueToday': instance.dueToday,
      'learnedCards': instance.learnedCards,
    };
