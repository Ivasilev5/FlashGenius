// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudyCardModel _$StudyCardModelFromJson(Map<String, dynamic> json) =>
    StudyCardModel(
      id: json['id'] as String,
      deckId: json['deck_id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      questionImage: json['question_image'] as String?,
      answerImage: json['answer_image'] as String?,
    );

Map<String, dynamic> _$StudyCardModelToJson(StudyCardModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deck_id': instance.deckId,
      'question': instance.question,
      'answer': instance.answer,
      'question_image': instance.questionImage,
      'answer_image': instance.answerImage,
    };
