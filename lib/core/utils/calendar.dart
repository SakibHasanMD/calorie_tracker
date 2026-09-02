/// Shared, locale-aware calendar helpers.
///
/// The week convention used across the app is **Saturday → Friday** (the user
/// locale's week starts on Saturday), so History's week view, Statistics'
/// "this week" total and the calorie target's week scope all agree on what a
/// week means.
library;

/// Strips the time component, returning [d] at local midnight.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// The Saturday that starts the week containing [d].
DateTime weekStart(DateTime d) {
  final day = dateOnly(d);
  // DateTime.weekday: 1 = Monday ... 6 = Saturday, 7 = Sunday.
  // Days since the last Saturday: (weekday - 6) mod 7.
  return day.subtract(Duration(days: (day.weekday - 6) % 7));
}

/// The Friday that ends the week containing [d] (Sat→Fri, inclusive).
DateTime weekEnd(DateTime d) => weekStart(d).add(const Duration(days: 6));

/// Formats [d] as `YYYY-MM-DD` in local time.
String formatYmd(DateTime d) {
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}