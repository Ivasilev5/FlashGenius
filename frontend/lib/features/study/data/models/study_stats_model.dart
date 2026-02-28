import 'package:json_annotation/json_annotation.dart';

part 'study_stats_model.g.dart';

@JsonSerializable()
class StudyStatsModel {
  const StudyStatsModel({
    this.totalCards = 0,
    this.dueToday = 0,
    this.learnedCards = 0,
  });

  final int totalCards;
  final int dueToday;
  final int learnedCards;

  factory StudyStatsModel.fromJson(Map<String, dynamic> json) =>
      _$StudyStatsModelFromJson(json);
  Map<String, dynamic> toJson() => _$StudyStatsModelToJson(this);
}
