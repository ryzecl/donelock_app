import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/journal_repository.dart';

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepository(FirebaseFirestore.instance, FirebaseAuth.instance);
});

final allJournalsProvider = StreamProvider((ref) {
  return ref.read(journalRepositoryProvider).getAllJournalsStream();
});
