import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../../core/network/api_exception.dart';
import 'models/card_model.dart';
import 'models/review_request.dart';
import 'models/study_progress_summary.dart';
import 'models/study_stats_model.dart';

class StudyRepository {
  StudyRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw ApiException(message: 'Not authenticated');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> _decksCol(String deckId) =>
      _firestore
          .collection('users/$_uid/decks')
          .doc(deckId)
          .collection('cards');

  CollectionReference<Map<String, dynamic>> get _activityCol =>
      _firestore.collection('users/$_uid/study_activity');

  Future<StudyCardModel?> getNextCard(String deckId) async {
    final now = DateTime.now();
    final col = _decksCol(deckId);
    final dueSnapshot = await col
        .where('due_date', isLessThanOrEqualTo: now.toIso8601String())
        .orderBy('due_date')
        .limit(1)
        .get();
    if (dueSnapshot.docs.isNotEmpty) {
      final doc = dueSnapshot.docs.first;
      final data = doc.data();
      return StudyCardModel(
        id: doc.id,
        deckId: deckId,
        question: data['question'] as String? ?? '',
        answer: data['answer'] as String? ?? '',
        questionImage: data['question_image'] as String?,
        answerImage: data['answer_image'] as String?,
      );
    }
    final allSnapshot = await col.limit(1).get();
    if (allSnapshot.docs.isEmpty) return null;
    final doc = allSnapshot.docs.first;
    final data = doc.data();
    return StudyCardModel(
      id: doc.id,
      deckId: deckId,
      question: data['question'] as String? ?? '',
      answer: data['answer'] as String? ?? '',
      questionImage: data['question_image'] as String?,
      answerImage: data['answer_image'] as String?,
    );
  }

  Future<void> submitReview(
      String deckId, String cardId, ReviewRequest request) async {
    final docRef = _decksCol(deckId).doc(cardId);
    final snap = await docRef.get();
    if (!snap.exists) {
      throw ApiException(message: 'Card not found');
    }
    final data = snap.data()!;
    var repetition = (data['repetition'] as int?) ?? 0;
    var intervalMinutes = (data['interval_minutes'] as int?) ??
        (((data['interval'] as int?) ?? 0) * 1440);
    var easiness = (data['easiness'] as num?)?.toDouble() ?? 2.5;

    final q = _difficultyToQuality(request.difficulty);
    if (q < 3) {
      repetition = 0;
      intervalMinutes = 8; // "<10 минут"
    } else {
      if (repetition == 0) {
        // Custom first-step intervals (minutes).
        switch (request.difficulty) {
          case 'hard':
            intervalMinutes = 60; // 1 час
            break;
          case 'easy':
            intervalMinutes = 4 * 1440; // 4 дня
            break;
          case 'good':
          default:
            intervalMinutes = 1440; // 1 день
            break;
        }
      } else if (repetition == 1) {
        // Second successful review. Keep SM-2 feel, but let "hard/easy" diverge a bit.
        switch (request.difficulty) {
          case 'hard':
            intervalMinutes = 3 * 1440;
            break;
          case 'easy':
            intervalMinutes = 8 * 1440;
            break;
          case 'good':
          default:
            intervalMinutes = 6 * 1440;
            break;
        }
      } else {
        final currentDays = max(1, (intervalMinutes / 1440).round());
        final nextDays = max(1, (currentDays * easiness).round());
        intervalMinutes = nextDays * 1440;
      }
      repetition += 1;
      easiness = easiness + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
      easiness = max(1.3, easiness);
    }

    final nextReview = DateTime.now().add(Duration(minutes: intervalMinutes));
    final intervalDaysForCompat = max(1, (intervalMinutes / 1440).ceil());

    await docRef.update({
      'repetition': repetition,
      'interval_minutes': intervalMinutes,
      'interval': intervalDaysForCompat,
      'easiness': easiness,
      'due_date': nextReview.toIso8601String(),
    });
  }

  int _difficultyToQuality(String difficulty) {
    switch (difficulty) {
      case 'again':
        return 1;
      case 'hard':
        return 3;
      case 'good':
        return 4;
      case 'easy':
        return 5;
      default:
        return 3;
    }
  }

  Future<StudyStatsModel> getStats(String deckId) async {
    final col = _decksCol(deckId);
    final now = DateTime.now();
    final all = await col.get();
    int due = 0;
    for (final doc in all.docs) {
      final dueStr = doc.data()['due_date'] as String?;
      if (dueStr == null) continue;
      final d = DateTime.tryParse(dueStr);
      if (d != null && !d.isAfter(now)) {
        due++;
      }
    }
    return StudyStatsModel(
      totalCards: all.docs.length,
      dueToday: due,
      learnedCards: 0,
    );
  }

  Future<void> recordStudyActivity({
    required int reviewedCards,
    required int durationSeconds,
  }) async {
    if (reviewedCards <= 0 && durationSeconds <= 0) return;

    final now = DateTime.now();
    final docId = DateFormat('yyyy-MM-dd').format(now);
    final docRef = _activityCol.doc(docId);

    await docRef.set({
      'date': docId,
      'reviewed_cards': FieldValue.increment(reviewedCards),
      'duration_seconds': FieldValue.increment(durationSeconds),
      'updated_at': now.toIso8601String(),
      'last_study_at': now.toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<StudyProgressSummary> getStudyProgressSummary({
    int dailyGoal = 20,
  }) async {
    final now = DateTime.now();
    final todayId = DateFormat('yyyy-MM-dd').format(now);
    final rawDocs = await _activityCol.get();
    final sortedDocs = rawDocs.docs.toList()
      ..sort((a, b) => b.id.compareTo(a.id));
    final recentDocs = sortedDocs.take(90).toList();

    int reviewedToday = 0;
    int secondsSpentToday = 0;
    int currentStreak = 0;
    DateTime? lastStudyDate;

    final docsById = {for (final doc in recentDocs) doc.id: doc.data()};
    final todayData = docsById[todayId];

    if (todayData != null) {
      reviewedToday = (todayData['reviewed_cards'] as num?)?.toInt() ?? 0;
      secondsSpentToday = (todayData['duration_seconds'] as num?)?.toInt() ?? 0;
    }

    if (recentDocs.isNotEmpty) {
      lastStudyDate = DateTime.tryParse('${recentDocs.first.id}T00:00:00');
    }

    if (todayData != null && reviewedToday > 0) {
      for (var offset = 0; offset < 90; offset++) {
        final date = now.subtract(Duration(days: offset));
        final dateId = DateFormat('yyyy-MM-dd').format(date);
        final data = docsById[dateId];
        final reviewed = (data?['reviewed_cards'] as num?)?.toInt() ?? 0;
        if (reviewed <= 0) {
          break;
        }
        currentStreak++;
      }
    }

    return StudyProgressSummary(
      reviewedToday: reviewedToday,
      secondsSpentToday: secondsSpentToday,
      currentStreak: currentStreak,
      dailyGoal: dailyGoal,
      lastStudyDate: lastStudyDate,
    );
  }
}
