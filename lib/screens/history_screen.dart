import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/meal.dart';
import '../services/calorie_service.dart';
import 'day_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _loading = true;
  List<DateTime> _days = [];
  Map<DateTime, List<Meal>> _grouped = {};

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    final allMeals = await DBHelper.instance.getAllMeals();
    final grouped = CalorieService.groupByDay(allMeals);
    final days = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // newest first
    setState(() {
      _grouped = grouped;
      _days = days;
      _loading = false;
    });
  }

  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) return 'Today';
    if (date == yesterday) return 'Yesterday';

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _days.isEmpty
              ? const Center(child: Text('No history yet.'))
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.builder(
                    itemCount: _days.length,
                    itemBuilder: (context, index) {
                      final day = _days[index];
                      final meals = _grouped[day]!;
                      final total = CalorieService.totalCalories(meals);
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          title: Text(_dayLabel(day),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${total.toStringAsFixed(0)} kcal'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DayDetailScreen(
                                    date: day, dayLabel: _dayLabel(day)),
                              ),
                            );
                            _loadHistory(); // refresh in case entries were deleted
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
