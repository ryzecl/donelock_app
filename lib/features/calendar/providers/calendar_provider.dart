import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../journal/providers/journal_provider.dart';

final monthlyJournalProvider = StreamProvider.family((ref, String month) {
  final repository = ref.read(journalRepositoryProvider);

  return repository.getMonthlyJournalsStream(month);
});
