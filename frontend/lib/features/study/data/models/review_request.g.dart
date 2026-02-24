// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewRequest _$ReviewRequestFromJson(Map<String, dynamic> json) =>
    ReviewRequest(
      difficulty: json['difficulty'] as String,
      nextReviewIn: json['next_review_in'] as int?,
    );

Map<String, dynamic> _$ReviewRequestToJson(ReviewRequest instance) =>
    <String, dynamic>{
      'difficulty': instance.difficulty,
      'next_review_in': instance.nextReviewIn,
    };
