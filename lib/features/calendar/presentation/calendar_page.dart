import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/calendar_helper.dart';
import '../providers/calendar_provider.dart';
import '../../journal/models/journal_model.dart';
import '../../journal/providers/journal_provider.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  String viewMode = 'calendar'; // 'calendar' or 'heatmap'
  String heatmapRange = 'month'; // 'week', 'month', 'year'

  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CALENDAR", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                Expanded(
                  child: _brutalistTab(
                    text: "CALENDAR",
                    isSelected: viewMode == 'calendar',
                    onTap: () => setState(() => viewMode = 'calendar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _brutalistTab(
                    text: "HEATMAP",
                    isSelected: viewMode == 'heatmap',
                    onTap: () => setState(() => viewMode = 'heatmap'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: viewMode == 'calendar' ? _buildCalendar() : _buildHeatmap(),
          ),
        ],
      ),
    );
  }

  Widget _brutalistTab({required String text, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          border: Border.all(color: Colors.black, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    final month = "${focusedDay.year}${focusedDay.month.toString().padLeft(2, '0')}";
    final journalsAsync = ref.watch(monthlyJournalProvider(month));

    return SingleChildScrollView(
      child: Column(
        children: [
          journalsAsync.when(
            data: (journals) {
              return TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: focusedDay,
                selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                onDaySelected: (selected, focused) {
                  setState(() {
                    selectedDay = selected;
                    focusedDay = focused;
                  });
                },
                onPageChanged: (focused) => setState(() => focusedDay = focused),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, date, focused) {
                    final color = getStatusColor(date, journals);
                    final isToday = isSameDay(date, DateTime.now());
                    
                    if (color == Colors.grey) {
                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          border: isToday ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : null,
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
                        shape: BoxShape.rectangle,
                        color: color,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "${date.day}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    );
                  },
                  todayBuilder: (context, date, focused) {
                    final color = getStatusColor(date, journals);
                    if (color == Colors.grey) {
                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "${date.day}",
                          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                      );
                    }
                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: color,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      alignment: Alignment.center,
                      child: Text("${date.day}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    );
                  },
                  selectedBuilder: (context, date, focused) {
                    final color = getStatusColor(date, journals);
                    if (color == Colors.grey) {
                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "${date.day}",
                          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                      );
                    }
                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: color,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      alignment: Alignment.center,
                      child: Text("${date.day}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
            error: (e, st) => Center(child: Text("Error: $e")),
          ),
          const SizedBox(height: 20),
          if (selectedDay != null) _JournalDetail(selectedDay: selectedDay, journalsAsync: journalsAsync),
        ],
      ),
    );
  }

  Widget _buildHeatmap() {
    final allJournalsAsync = ref.watch(allJournalsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _heatmapFilterBtn("1 WEEK", 'week'),
              const SizedBox(width: 8),
              _heatmapFilterBtn("1 MONTH", 'month'),
              const SizedBox(width: 8),
              _heatmapFilterBtn("1 YEAR", 'year'),
            ],
          ),
        ),
        Expanded(
          child: allJournalsAsync.when(
            data: (journals) {
              int daysCount;
              if (heatmapRange == 'week') {
                daysCount = 7;
              } else if (heatmapRange == 'month') {
                daysCount = 30;
              } else {
                daysCount = 365;
              }

              final today = DateTime.now();
              final startDate = today.subtract(Duration(days: daysCount - 1));

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: heatmapRange == 'week' ? (7 * 30.0 + 6 * 4.0) : (7 * 14.0 + 6 * 4.0),
                        child: Wrap(
                          direction: Axis.horizontal,
                          spacing: 4,
                          runSpacing: 4,
                          children: List.generate(daysCount, (index) {
                            final currentDate = startDate.add(Duration(days: index));
                            final dateStr = "${currentDate.year}${currentDate.month.toString().padLeft(2, '0')}${currentDate.day.toString().padLeft(2, '0')}";
                            
                            bool? isProductive;
                            for (final j in journals) {
                              if (j["date"] == dateStr) {
                                isProductive = j["productive"] == true || j["productive"] == "productive";
                                break;
                              }
                            }

                            Color boxColor = const Color(0xFFE5E7EB);
                            if (isProductive == true) boxColor = const Color(0xFF4ADE80);
                            else if (isProductive == false) boxColor = const Color(0xFFEF4444);

                            double size = heatmapRange == 'week' ? 30 : 14;

                            return Tooltip(
                              message: "${currentDate.day}/${currentDate.month}/${currentDate.year}",
                              child: Container(
                                width: size,
                                height: size,
                                decoration: BoxDecoration(
                                  color: boxColor,
                                  border: Border.all(color: Colors.black, width: 1),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text("Error: $e")),
          ),
        ),
      ],
    );
  }

  Widget _heatmapFilterBtn(String text, String mode) {
    final isSelected = heatmapRange == mode;
    return InkWell(
      onTap: () => setState(() => heatmapRange = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
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

    final id = "${selectedDay!.year}${selectedDay!.month.toString().padLeft(2, '0')}${selectedDay!.day.toString().padLeft(2, '0')}";

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
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Text("No journal for ${selectedDay!.day}/${selectedDay!.month}/${selectedDay!.year}"),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${journal.productivity == 'productive' ? '🟢' : '🔴'} ${journal.productivity == 'productive' ? 'Productive' : 'Not Productive'}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
