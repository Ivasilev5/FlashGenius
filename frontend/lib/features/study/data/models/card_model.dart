import 'package:json_annotation/json_annotation.dart';

part 'card_model.g.dart';

@JsonSerializable()
class StudyCardModel {
  const StudyCardModel({
    required this.id,
    required this.deckId,
    required this.question,
    required this.answer,
    this.questionImage,
    this.answerImage,
  });

  final String id;
  @JsonKey(name: 'deck_id')
  final String deckId;
  final String question;
  final String answer;
  @JsonKey(name: 'question_image')
  final String? questionImage;
  @JsonKey(name: 'answer_image')
  final String? answerImage;

  factory StudyCardModel.fromJson(Map<String, dynamic> json) =>
      _$StudyCardModelFromJson(json);
  Map<String, dynamic> toJson() => _$StudyCardModelToJson(this);
}
