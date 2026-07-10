import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../journal/providers/journal_provider.dart';

final monthlyJournalProvider = FutureProvider.family((ref, String month) async {
  final repository = ref.read(journalRepositoryProvider);

  return await repository.getMonthlyJournals(month);
});
