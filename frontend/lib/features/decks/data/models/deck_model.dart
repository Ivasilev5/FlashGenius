import 'package:json_annotation/json_annotation.dart';

part 'deck_model.g.dart';

@JsonSerializable()
class DeckModel {
  const DeckModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.isPublic = false,
    this.cardCount = 0,
    this.createdAt,
    this.updatedAt,
    this.cards,
  });

  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final String title;
  final String? description;
  @JsonKey(name: 'is_public')
  final bool isPublic;
  @JsonKey(name: 'card_count')
  final int cardCount;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  final List<CardModel>? cards;

  factory DeckModel.fromJson(Map<String, dynamic> json) =>
      _$DeckModelFromJson(json);
  Map<String, dynamic> toJson() => _$DeckModelToJson(this);
}

@JsonSerializable()
class CardModel {
  const CardModel({
    required this.id,
    required this.deckId,
    required this.question,
    required this.answer,
    this.questionImage,
    this.answerImage,
    this.createdAt,
    this.updatedAt,
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
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  factory CardModel.fromJson(Map<String, dynamic> json) =>
      _$CardModelFromJson(json);
  Map<String, dynamic> toJson() => _$CardModelToJson(this);
}
