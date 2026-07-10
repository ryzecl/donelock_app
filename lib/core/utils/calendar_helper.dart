import 'package:flutter/material.dart';

import '../../features/journal/models/journal_model.dart';

Color getStatusColor(DateTime date, List<Journal> journals) {
  final id =
      "${date.year}"
      "${date.month.toString().padLeft(2, '0')}"
      "${date.day.toString().padLeft(2, '0')}";

  Journal? journal;

  for (final item in journals) {
    if (item.id == id) {
      journal = item;

      break;
    }
  }

  if (journal == null) {
    return Colors.grey;
  }

  if (journal.productivity == "productive") {
    return Colors.green;
  }

  return Colors.red;
}
