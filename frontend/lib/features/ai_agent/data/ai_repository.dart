import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_exception.dart';
import '../../decks/data/models/deck_model.dart';

class AiRepository {
  AiRepository(this._dio);

  final Dio _dio;

  /// Start generation by topic. Returns job_id for polling.
  Future<String> generateCards({
    String? deckId,
    required String topic,
    required int count,
    required String language,
    required String difficulty,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.aiGenerateCards,
      data: {
        if (deckId != null) 'deck_id': deckId,
        'topic': topic,
        'count': count.clamp(AppConstants.minAiCards, AppConstants.maxAiCards),
        'language': language,
        'difficulty': difficulty,
      },
    );
    final data = response.data;
    if (data == null) throw ApiException(message: 'Empty response');
    final inner = data['data'];
    if (inner == null || inner is! Map<String, dynamic>) {
      throw ApiException(message: (data['error'] as String?) ?? 'Invalid response');
    }
    final jobId = inner['job_id'] as String?;
    if (jobId == null) throw ApiException(message: 'No job_id in response');
    return jobId;
  }

  /// Poll job status. Returns status and optional cards when done.
  Future<AiJobStatus> getJobStatus(String jobId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.aiJob(jobId),
    );
    final data = response.data;
    if (data == null) throw ApiException(message: 'Empty response');
    final inner = data['data'];
    if (inner == null || inner is! Map<String, dynamic>) {
      throw ApiException(message: (data['error'] as String?) ?? 'Invalid response');
    }
    final status = inner['status'] as String? ?? 'pending';
    final cards = inner['cards'];
    List<Map<String, String>>? list;
    if (cards is List) {
      list = cards.map((e) {
        final m = e as Map<String, dynamic>;
        return {'question': '${m['question']}', 'answer': '${m['answer']}'};
      }).toList();
    }
    return AiJobStatus(status: status, cards: list);
  }

  /// Upload PDF and start generation. Returns job_id.
  Future<String> generateFromPdf({
    required File file,
    String? deckId,
    required int count,
    String language = 'ru',
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: file.path.split(Platform.pathSeparator).last),
      if (deckId != null) 'deck_id': deckId,
      'count': count.clamp(AppConstants.minAiCards, AppConstants.maxAiCards),
      'language': language,
    });
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.aiGenerateFromPdf,
      data: formData,
    );
    final data = response.data;
    if (data == null) throw ApiException(message: 'Empty response');
    final inner = data['data'];
    if (inner == null || inner is! Map<String, dynamic>) {
      throw ApiException(message: (data['error'] as String?) ?? 'Invalid response');
    }
    final jobId = inner['job_id'] as String?;
    if (jobId == null) throw ApiException(message: 'No job_id in response');
    return jobId;
  }
}

class AiJobStatus {
  AiJobStatus({required this.status, this.cards});

  final String status;
  final List<Map<String, String>>? cards;
}
