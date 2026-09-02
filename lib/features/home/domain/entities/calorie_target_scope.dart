/// How far a calorie-target change applies relative to the date being edited.
///
/// `day` affects only that date; `week` fills the containing Sat→Fri week;
/// `month` the calendar month; `year` the calendar year.
enum CalorieTargetScope { day, week, month, year }