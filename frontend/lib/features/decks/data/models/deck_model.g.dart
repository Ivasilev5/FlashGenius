// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeckModel _$DeckModelFromJson(Map<String, dynamic> json) => DeckModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      isPublic: json['is_public'] as bool? ?? false,
      cardCount: json['card_count'] as int? ?? 0,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      cards: (json['cards'] as List<dynamic>?)
          ?.map((e) => CardModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DeckModelToJson(DeckModel instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'title': instance.title,
      'description': instance.description,
      'is_public': instance.isPublic,
      'card_count': instance.cardCount,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'cards': instance.cards,
    };

CardModel _$CardModelFromJson(Map<String, dynamic> json) => CardModel(
      id: json['id'] as String,
      deckId: json['deck_id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      questionImage: json['question_image'] as String?,
      answerImage: json['answer_image'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$CardModelToJson(CardModel instance) => <String, dynamic>{
      'id': instance.id,
      'deck_id': instance.deckId,
      'question': instance.question,
      'answer': instance.answer,
      'question_image': instance.questionImage,
      'answer_image': instance.answerImage,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
