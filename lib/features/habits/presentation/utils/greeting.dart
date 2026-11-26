/// Which greeting the Today header shows.
///
/// Presentation only (it decides a text, no habit rule depends on it), so it
/// lives here and not in the domain.
enum Greeting {
  morning,
  afternoon,
  evening;

  /// Morning is 5:00-11:59, afternoon 12:00-16:59, and the rest is evening.
  static Greeting at(DateTime time) => switch (time.hour) {
    >= 5 && < 12 => morning,
    >= 12 && < 17 => afternoon,
    _ => evening,
  };
}
