abstract final class AppRoutes {
  static const today = '/';
  static const allHabits = '/habits';
  static const newHabit = '/habits/new';

  /// The route definition (with the `:id` parameter).
  static const editHabitPattern = '/habits/:id/edit';

  /// The address of the edit screen of one habit.
  static String editHabit(String id) =>
      '/habits/${Uri.encodeComponent(id)}/edit';

  static const themeShowcase = '/dev/theme-showcase';
}
