import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/calendar_helper.dart';
import '../providers/calendar_provider.dart';
import '../../journal/models/journal_model.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime focusedDay = DateTime.now();

  DateTime? selectedDay;

  @override
  Widget build(BuildContext context) {
    final month =
        "${focusedDay.year}${focusedDay.month.toString().padLeft(2, '0')}";
    final journalsAsync = ref.watch(monthlyJournalProvider(month));

    return Scaffold(
      appBar: AppBar(title: const Text("Calendar")),

      body: Column(
        children: [
          journalsAsync.when(
            data: (journals) {
              return TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),

                lastDay: DateTime.utc(2030, 12, 31),

                focusedDay: focusedDay,

                selectedDayPredicate: (day) {
                  return isSameDay(selectedDay, day);
                },

                onDaySelected: (selected, focused) {
                  setState(() {
                    selectedDay = selected;

                    focusedDay = focused;
                  });
                },

                onPageChanged: (focused) {
                  setState(() {
                    focusedDay = focused;
                  });
                },

                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, date, focused) {
                    final color = getStatusColor(date, journals);

                    final isToday = isSameDay(date, DateTime.now());
                    final isSelected = isSameDay(date, selectedDay);

                    if (color == Colors.grey) {
                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: isToday
                              ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "${date.day}",
                          style: TextStyle(
                            color: isToday ? Theme.of(context).colorScheme.primary : null,
                            fontWeight: isToday ? FontWeight.bold : null,
                          ),
                        ),
                      );
                    }

                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "${date.day}",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    );
                  },

                  todayBuilder: (context, date, focused) {
                    final color = getStatusColor(date, journals);

                    if (color == Colors.grey) {
                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "${date.day}",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }

                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "${date.day}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },

                  selectedBuilder: (context, date, focused) {
                    final color = getStatusColor(date, journals);

                    if (color == Colors.grey) {
                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "${date.day}",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }

                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "${date.day}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              );
            },

            loading: () => const Center(child: CircularProgressIndicator()),

            error: (e, st) => Center(child: Text("Error: $e")),
          ),

          const SizedBox(height: 20),

          if (selectedDay != null)
            _JournalDetail(selectedDay: selectedDay, journalsAsync: journalsAsync),
        ],
      ),
    );
  }
}

class _JournalDetail extends ConsumerWidget {
  final DateTime? selectedDay;

  final AsyncValue<List<Journal>> journalsAsync;

  const _JournalDetail({required this.selectedDay, required this.journalsAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (selectedDay == null) return const SizedBox.shrink();

    final id =
        "${selectedDay!.year}"
        "${selectedDay!.month.toString().padLeft(2, '0')}"
        "${selectedDay!.day.toString().padLeft(2, '0')}";

    return journalsAsync.when(
      data: (journals) {
        Journal? journal;

        for (final item in journals) {
          if (item.id == id) {
            journal = item;

            break;
          }
        }

        if (journal == null) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),

            child: Container(
              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),

                color: Colors.grey.shade200,
              ),

              child: Text(
                "No journal for ${selectedDay!.day}/${selectedDay!.month}/${selectedDay!.year}",
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),

          child: Container(
            width: double.infinity,

            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),

              color: Colors.grey.shade200,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  "${journal.productivity == 'productive' ? '🟢' : '🔴'} ${journal.productivity == 'productive' ? 'Productive' : 'Not Productive'}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text("Mood: ${journal.mood}", style: const TextStyle(fontSize: 16)),

                const SizedBox(height: 8),

                Text(journal.note, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        );
      },

      loading: () => const SizedBox.shrink(),

      error: (e, st) => const SizedBox.shrink(),
    );
  }
}
