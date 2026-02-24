import 'package:json_annotation/json_annotation.dart';

part 'study_stats_model.g.dart';

@JsonSerializable()
class StudyStatsModel {
  const StudyStatsModel({
    this.newCount = 0,
    this.reviewCount = 0,
    this.learnedCount = 0,
  });

  @JsonKey(name: 'new_count')
  final int newCount;
  @JsonKey(name: 'review_count')
  final int reviewCount;
  @JsonKey(name: 'learned_count')
  final int learnedCount;

  factory StudyStatsModel.fromJson(Map<String, dynamic> json) =>
      _$StudyStatsModelFromJson(json);
  Map<String, dynamic> toJson() => _$StudyStatsModelToJson(this);
}
