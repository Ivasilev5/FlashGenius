import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_exception.dart';
import 'models/deck_model.dart';

class DeckRepository {
  DeckRepository(this._dio);

  final Dio _dio;

  Future<List<DeckModel>> getDecks({int limit = 20, int offset = 0}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.decks(),
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return _parseList(response, DeckModel.fromJson);
  }

  Future<DeckModel> getDeck(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(ApiConstants.deck(id));
    return _parseOne(response, DeckModel.fromJson);
  }

  Future<DeckModel> createDeck({
    required String title,
    String? description,
    bool isPublic = false,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.decks(),
      data: {
        'title': title,
        if (description != null) 'description': description,
        'is_public': isPublic,
      },
    );
    return _parseOne(response, DeckModel.fromJson);
  }

  Future<DeckModel> updateDeck(
    String id, {
    String? title,
    String? description,
    bool? isPublic,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      ApiConstants.deck(id),
      data: {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (isPublic != null) 'is_public': isPublic,
      },
    );
    return _parseOne(response, DeckModel.fromJson);
  }

  Future<void> deleteDeck(String id) async {
    await _dio.delete(ApiConstants.deck(id));
  }

  Future<List<CardModel>> getCards(String deckId, {int limit = 100, int offset = 0}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.deckCards(deckId),
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return _parseList(response, CardModel.fromJson);
  }

  Future<CardModel> createCard(
    String deckId, {
    required String question,
    required String answer,
    String? questionImage,
    String? answerImage,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.deckCards(deckId),
      data: {
        'question': question,
        'answer': answer,
        if (questionImage != null) 'question_image': questionImage,
        if (answerImage != null) 'answer_image': answerImage,
      },
    );
    return _parseOne(response, CardModel.fromJson);
  }

  Future<CardModel> updateCard(
    String id, {
    String? question,
    String? answer,
    String? questionImage,
    String? answerImage,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      ApiConstants.card(id),
      data: {
        if (question != null) 'question': question,
        if (answer != null) 'answer': answer,
        if (questionImage != null) 'question_image': questionImage,
        if (answerImage != null) 'answer_image': answerImage,
      },
    );
    return _parseOne(response, CardModel.fromJson);
  }

  Future<void> deleteCard(String id) async {
    await _dio.delete(ApiConstants.card(id));
  }

  T _parseOne<T>(Response<Map<String, dynamic>> response, T Function(Map<String, dynamic>) fromJson) {
    final data = response.data;
    if (data == null) throw ApiException(message: 'Empty response');
    final inner = data['data'];
    if (inner == null || inner is! Map<String, dynamic>) {
      throw ApiException(message: (data['error'] as String?) ?? 'Invalid response');
    }
    return fromJson(inner);
  }

  List<T> _parseList<T>(Response<Map<String, dynamic>> response, T Function(Map<String, dynamic>) fromJson) {
    final data = response.data;
    if (data == null) throw ApiException(message: 'Empty response');
    final inner = data['data'];
    if (inner == null) return [];
    final list = inner is List
        ? inner
        : (inner is Map ? (inner['items'] as List?) : null);
    if (list == null) return [];
    return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }
}
