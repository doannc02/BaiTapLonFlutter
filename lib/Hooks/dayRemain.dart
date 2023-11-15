import 'package:intl/intl.dart';

int calculateDaysRemaining(String apiDueDate) {
  DateTime dueDate = DateTime.parse(apiDueDate);
  DateTime now = DateTime.now();
  int daysRemaining = dueDate.difference(now).inDays;
  return daysRemaining;
}