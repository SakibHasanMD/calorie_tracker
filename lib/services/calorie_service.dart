import '../models/meal.dart';

class CalorieService {
  static double totalCalories(List<Meal> meals) {
    return meals.fold(0.0, (sum, m) => sum + m.calories);
  }

  static Map<DateTime, List<Meal>> groupByDay(List<Meal> meals) {
    final Map<DateTime, List<Meal>> grouped = {};
    for (final meal in meals) {
      final dayKey = DateTime(
          meal.createdAt.year, meal.createdAt.month, meal.createdAt.day);
      grouped.putIfAbsent(dayKey, () => []).add(meal);
    }
    return grouped;
  }

  static List<Meal> mealsForDay(List<Meal> allMeals, DateTime date) {
    return allMeals
        .where((m) =>
            m.createdAt.year == date.year &&
            m.createdAt.month == date.month &&
            m.createdAt.day == date.day)
        .toList();
  }

  static List<Meal> mealsInLastDays(List<Meal> allMeals, int days) {
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));
    return allMeals.where((m) => !m.createdAt.isBefore(cutoff)).toList();
  }

  static List<Meal> mealsThisWeek(List<Meal> allMeals) {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    return allMeals.where((m) => !m.createdAt.isBefore(startOfWeek)).toList();
  }

  static List<Meal> mealsThisMonth(List<Meal> allMeals) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return allMeals.where((m) => !m.createdAt.isBefore(startOfMonth)).toList();
  }

  static double averagePerDay(List<Meal> allMeals, int days) {
    final recent = mealsInLastDays(allMeals, days);
    final total = totalCalories(recent);
    return total / days;
  }
}
