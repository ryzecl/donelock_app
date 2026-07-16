import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/calendar_helper.dart';
import '../../../core/widgets/brutalist_loading.dart';
import '../../../core/utils/ui_utils.dart';
import '../providers/calendar_provider.dart';

import '../../journal/providers/journal_provider.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  String heatmapRange = 'month'; // 'week', 'month', 'year'
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  void _showJournalModal(BuildContext context, DateTime date) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _JournalModalBody(date: date),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CALENDAR", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCalendar(),
            const Divider(height: 40, thickness: 3, color: Colors.black),
            _buildHeatmap(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    final month = "${focusedDay.year}${focusedDay.month.toString().padLeft(2, '0')}";
    final journalsAsync = ref.watch(monthlyJournalProvider(month));

    return journalsAsync.when(
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
            _showJournalModal(context, selected);
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
                    borderRadius: BorderRadius.circular(8),
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
                  borderRadius: BorderRadius.circular(8),
                  color: color,
                  border: Border.all(color: Colors.black, width: 2),
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
                    borderRadius: BorderRadius.circular(8),
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
                  borderRadius: BorderRadius.circular(8),
                  color: color,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  "${date.day}",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              );
            },
            selectedBuilder: (context, date, focused) {
              final color = getStatusColor(date, journals);
              return Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: color == Colors.grey ? Colors.black : color,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  "${date.day}",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: BrutalistLoading())),
      error: (e, st) => Center(child: Text("Error: $e")),
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
        allJournalsAsync.when(
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
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  height: heatmapRange == 'week' ? (7 * 30.0 + 6 * 4.0) : (7 * 14.0 + 6 * 4.0),
                  child: Wrap(
                    direction: Axis.vertical,
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
                      else if (isProductive == false) boxColor = const Color(0xFFFF90E8);

                      double size = heatmapRange == 'week' ? 30 : 14;

                      return InkWell(
                        onTap: () => _showJournalModal(context, currentDate),
                        child: Tooltip(
                          message: "${currentDate.day}/${currentDate.month}/${currentDate.year}",
                          child: Container(
                            width: size,
                            height: size,
                            decoration: UIUtils.neoBox(
                              color: boxColor,
                              borderWidth: 1,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            );
          },
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: BrutalistLoading())),
          error: (e, st) => Center(child: Text("Error: $e")),
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
        decoration: UIUtils.neoBox(
          color: isSelected ? Colors.black : Colors.white,
          borderWidth: 2,
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

class _JournalModalBody extends ConsumerWidget {
  final DateTime date;
  
  const _JournalModalBody({required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncJournals = ref.watch(allJournalsProvider);
    final id = "${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}";

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Colors.black, width: 3),
          left: BorderSide(color: Colors.black, width: 3),
          right: BorderSide(color: Colors.black, width: 3),
        ),
      ),
      child: asyncJournals.when(
        data: (journals) {
          Map<String, dynamic>? journal;
          for (final j in journals) {
            if (j['date'] == id) {
              journal = j;
              break;
            }
          }

          if (journal == null) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("NO JOURNAL FOR ${date.day}/${date.month}/${date.year}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/journal_edit', extra: date);
                  },
                  child: const Text("📝 ADD JOURNAL"),
                ),
              ],
            );
          }

          final isProd = journal['productive'] == true || journal['productive'] == 'productive';
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${date.day}/${date.month}/${date.year}",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Text(
                "${isProd ? '🟢' : '🔴'} ${isProd ? 'Productive' : 'Not Productive'}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Mood: ${journal['mood']}", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: UIUtils.neoBox(color: Colors.white, borderWidth: 2),
                child: Text(journal['note'] ?? journal['content'] ?? '', style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
        loading: () => const Center(child: BrutalistLoading()),
        error: (e, st) => Text("Error: $e"),
      ),
    );
  }
}
