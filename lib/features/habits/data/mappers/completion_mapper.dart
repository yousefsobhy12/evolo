import 'package:evolo/core/database/app_database.dart';
import 'package:evolo/features/habits/domain/entities/completion.dart';

extension CompletionRowMapper on CompletionRow {
  Completion toEntity() {
    return Completion(habitId: habitId, day: day, count: count, target: target);
  }
}
