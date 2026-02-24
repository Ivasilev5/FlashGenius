import 'package:json_annotation/json_annotation.dart';

part 'review_request.g.dart';

@JsonSerializable()
class ReviewRequest {
  const ReviewRequest({
    required this.difficulty,
    this.nextReviewIn,
  });

  final String difficulty;
  @JsonKey(name: 'next_review_in')
  final int? nextReviewIn;

  factory ReviewRequest.fromJson(Map<String, dynamic> json) =>
      _$ReviewRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewRequestToJson(this);
}
