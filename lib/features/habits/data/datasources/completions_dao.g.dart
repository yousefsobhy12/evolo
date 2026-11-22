// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completions_dao.dart';

// ignore_for_file: type=lint
mixin _$CompletionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $HabitsTable get habits => attachedDatabase.habits;
  $CompletionsTable get completions => attachedDatabase.completions;
  CompletionsDaoManager get managers => CompletionsDaoManager(this);
}

class CompletionsDaoManager {
  final _$CompletionsDaoMixin _db;
  CompletionsDaoManager(this._db);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db.attachedDatabase, _db.habits);
  $$CompletionsTableTableManager get completions =>
      $$CompletionsTableTableManager(_db.attachedDatabase, _db.completions);
}
