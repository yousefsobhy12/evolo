import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/l10n/l10n.dart';
import 'package:evolo/core/theme/app_radius.dart';
import 'package:evolo/core/theme/app_spacing.dart';
import 'package:evolo/core/widgets/circle_icon_button.dart';
import 'package:evolo/core/widgets/max_content_width.dart';
import 'package:evolo/core/widgets/page_header.dart';
import 'package:evolo/features/reminders/presentation/widgets/reminder_card.dart';
import 'package:material_ui/material_ui.dart';

/// TEMPORARY (S2): visual check for tokens. Strings are hard-coded on purpose;
/// real screens use ARB files (S3). Delete before release (S14).
class ThemeShowcasePage extends StatelessWidget {
  const new({
    required this.onToggleTheme,
    required this.onToggleLocale,
    super.key,
  });

  final VoidCallback onToggleTheme;
  final VoidCallback onToggleLocale;

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Showcase'),
        actions: [
          IconButton(
            onPressed: onToggleLocale,
            icon: const Icon(Icons.translate),
            tooltip: 'Language',
          ),
          IconButton(
            onPressed: onToggleTheme,
            icon: Icon(context.isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Theme',
          ),
        ],
      ),
      body: MaxContentWidth(
        child: ListView(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.screen,
            vertical: AppSpacing.s16,
          ),
          children: [
            _Section(
              title: 'Page header',
              child: PageHeader(
                title: isArabic ? 'عادة جديدة' : 'New habit',
                trailing: CircleIconButton(
                  icon: Icons.close,
                  tooltip: isArabic ? 'إغلاق' : 'Close',
                  onPressed: () {},
                ),
              ),
            ),
            _Section(
              title: 'Typography',
              child: _TypographyBlock(isArabic: isArabic),
            ),
            const _Section(title: 'Colors', child: _ColorsBlock()),
            const _Section(title: 'Contrast pairs', child: _ContrastBlock()),
            const _Section(title: 'Spacing', child: _SpacingBlock()),
            const _Section(title: 'Radius', child: _RadiusBlock()),
            _Section(
              title: 'Buttons',
              child: Column(
                children: [
                  FilledButton(
                    onPressed: () {},
                    child: Text(isArabic ? 'حفظ' : 'Save'),
                  ).fullWidth(),
                  12.vSpace,
                  FilledButton(
                    onPressed: null,
                    child: Text(isArabic ? 'غير متاح' : 'Disabled'),
                  ).fullWidth(),
                ],
              ),
            ),
            _Section(
              title: 'Reminder card',
              child: ReminderCard(
                title: context.l10n.reminderCardTitle,
                message: context.l10n.reminderCardMessage,
                actionLabel: context.l10n.reminderCardAction,
                onAction: () {},
              ),
            ),
            _Section(
              title: 'Inputs',
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: isArabic ? 'اسم العادة' : 'Habit name',
                      hintText: isArabic ? 'مثال: قراءة' : 'e.g. Reading',
                    ),
                  ),
                  12.vSpace,
                  TextField(
                    decoration: InputDecoration(
                      labelText: isArabic ? 'الهدف' : 'Goal',
                      errorText: isArabic ? 'الحقل مطلوب' : 'Required field',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const new({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.textTheme.headlineMedium),
        12.vSpace,
        child,
        AppSpacing.s32.vSpace,
      ],
    );
  }
}

class _TypographyBlock extends StatelessWidget {
  const new({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final t = context.textTheme;
    final sample = isArabic ? 'عادة جديدة كل يوم' : 'A new habit every day';
    final styles = <(String, TextStyle?)>[
      ('H1 32', t.headlineLarge),
      ('H2 22', t.headlineMedium),
      ('Title 17', t.titleMedium),
      ('Body 15', t.bodyMedium),
      ('Caption 13', t.bodySmall),
      ('Button 17', t.labelLarge),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (label, style) in styles) ...[
          Text('$label  $sample', style: style),
          8.vSpace,
        ],
        // Fallback check: Latin text inside an Arabic UI and the reverse.
        Text('Habit: قراءة القرآن · Streak 12 يوم', style: t.bodyMedium),
        8.vSpace,
        Text('٠١٢٣٤٥٦٧٨٩ 0123456789', style: t.bodyMedium),
      ],
    );
  }
}

class _ColorsBlock extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final entries = <(String, Color)>[
      ('background', c.background),
      ('surface', c.surface),
      ('surfaceMuted', c.surfaceMuted),
      ('dayPill', c.dayPill),
      ('primary', c.primary),
      ('primaryDark', c.primaryDark),
      ('ink', c.ink),
      ('reminderCard', c.reminderCard),
      ('textPrimary', c.textPrimary),
      ('textSecondary', c.textSecondary),
      ('textAccent', c.textAccent),
      ('tileOrange', c.tileOrange),
      ('tileGreen', c.tileGreen),
      ('tilePink', c.tilePink),
      ('barBrown', c.barBrown),
      ('barRust', c.barRust),
      ('barOlive', c.barOlive),
      ('barPink', c.barPink),
      ('barTrack', c.barTrack),
      ('checkRing', c.checkRing),
      ('error', c.error),
    ];

    return Wrap(
      spacing: AppSpacing.s8,
      runSpacing: AppSpacing.s8,
      children: [
        for (final (name, color) in entries) _Swatch(name: name, color: color),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const new({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final onColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Container(
      width: 104,
      height: 64,
      padding: const EdgeInsetsDirectional.all(AppSpacing.s8),
      alignment: AlignmentDirectional.bottomStart,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.tile),
        // Outline so near-background swatches stay visible.
        border: Border.all(
          color: context.colors.textSecondary.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        name,
        style: context.textTheme.bodySmall?.copyWith(
          color: onColor,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _ContrastBlock extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pairs = <(String, Color, Color)>[
      ('primary / onPrimary', c.primary, c.onPrimary),
      ('primaryDark / onPrimaryDark', c.primaryDark, c.onPrimaryDark),
      ('ink / onInk', c.ink, c.onInk),
      ('error / onError', c.error, c.onError),
      ('background / textAccent', c.background, c.textAccent),
      ('background / textSecondary', c.background, c.textSecondary),
      ('surface / textPrimary', c.surface, c.textPrimary),
    ];

    return Column(
      children: [
        for (final (label, bg, fg) in pairs)
          Container(
            width: double.infinity,
            margin: const EdgeInsetsDirectional.only(bottom: AppSpacing.s8),
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s12,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadius.tile),
              border: Border.all(color: c.textSecondary.withValues(alpha: 0.3)),
            ),
            child: Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(color: fg),
            ),
          ),
      ],
    );
  }
}

class _SpacingBlock extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    const values = [
      AppSpacing.s4,
      AppSpacing.s8,
      AppSpacing.s12,
      AppSpacing.s16,
      AppSpacing.s20,
      AppSpacing.s24,
      AppSpacing.s32,
    ];

    return Column(
      children: [
        for (final v in values)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.s8),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  child: Text(
                    '${v.toInt()}',
                    style: context.textTheme.bodySmall,
                  ),
                ),
                Container(width: v, height: 16, color: context.colors.primary),
              ],
            ),
          ),
      ],
    );
  }
}

class _RadiusBlock extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final items = <(String, double)>[
      ('tile 14', AppRadius.tile),
      ('input 20', AppRadius.input),
      ('card 20', AppRadius.card),
      ('reminder 24', AppRadius.reminder),
      ('pill', AppRadius.pill),
    ];

    return Wrap(
      spacing: AppSpacing.s12,
      runSpacing: AppSpacing.s12,
      children: [
        for (final (name, radius) in items)
          Container(
            width: 96,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: c.textAccent),
            ),
            child: Text(name, style: context.textTheme.bodySmall),
          ),
      ],
    );
  }
}
