import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/network/api_exception.dart';
import 'models/card_model.dart';
import 'models/review_request.dart';
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
      _firestore.collection('users/$_uid/decks').doc(deckId).collection('cards');

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

  Future<void> submitReview(String deckId, String cardId, ReviewRequest request) async {
    final docRef = _decksCol(deckId).doc(cardId);
    final snap = await docRef.get();
    if (!snap.exists) {
      throw ApiException(message: 'Card not found');
    }
    final data = snap.data()!;
    var repetition = (data['repetition'] as int?) ?? 0;
    var interval = (data['interval'] as int?) ?? 0;
    var easiness = (data['easiness'] as num?)?.toDouble() ?? 2.5;

    final q = _difficultyToQuality(request.difficulty);
    if (q < 3) {
      repetition = 0;
      interval = 1;
    } else {
      if (repetition == 0) {
        interval = 1;
      } else if (repetition == 1) {
        interval = 6;
      } else {
        interval = (interval * easiness).round();
      }
      repetition += 1;
      easiness = easiness + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
      easiness = max(1.3, easiness);
    }

    final nextReview = DateTime.now().add(Duration(days: interval));

    await docRef.update({
      'repetition': repetition,
      'interval': interval,
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
}
