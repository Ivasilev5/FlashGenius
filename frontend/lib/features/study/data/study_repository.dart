import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_exception.dart';
import 'models/card_model.dart';
import 'models/review_request.dart';
import 'models/study_stats_model.dart';

class StudyRepository {
  StudyRepository(this._dio);

  final Dio _dio;

  Future<StudyCardModel?> getNextCard(String deckId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.studyNext(deckId),
    );
    final data = response.data;
    if (data == null) return null;
    final inner = data['data'];
    if (inner == null) return null;
    if (inner is Map<String, dynamic>) {
      return StudyCardModel.fromJson(inner);
    }
    return null;
  }

  Future<void> submitReview(String cardId, ReviewRequest request) async {
    await _dio.post<Map<String, dynamic>>(
      ApiConstants.studyReview(cardId),
      data: request.toJson(),
    );
  }

  Future<StudyStatsModel> getStats(String deckId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.studyStats(deckId),
    );
    final data = response.data;
    if (data == null) throw ApiException(message: 'Empty response');
    final inner = data['data'];
    if (inner == null || inner is! Map<String, dynamic>) {
      throw ApiException(message: (data['error'] as String?) ?? 'Invalid response');
    }
    return StudyStatsModel.fromJson(inner);
  }
}
