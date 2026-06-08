import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../workout/presentation/providers/workout_generator_provider.dart';

// ─── Onboarding State ─────────────────────────────────────────────────────────

class _OnboardingData {
  String? goal;
  String? experience;
  int?    daysPerWeek;
  int?    age;
  double? heightCm;
  double? weightKg;
  String? gender;
}

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pages = PageController();
  final _data = _OnboardingData();
  int  _step      = 0;
  bool _isLoading = false;

  final _totalSteps = 4;

  void _next() {
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
      _pages.animateToPage(_step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
      _pages.animateToPage(_step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut);
    }
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioProvider);

      // 1. Save profile stats
      await dio.post(ApiEndpoints.profile, data: {
        'age':         _data.age,
        'heightCm':    _data.heightCm,
        'weightKg':    _data.weightKg,
        'gender':      _data.gender,
        'isOnboarded': true,
      });

      // 2. Generate workout plan
      await dio.post(ApiEndpoints.workoutGenerate, data: {
        'goal':        _data.goal        ?? 'general',
        'experience':  _data.experience  ?? 'beginner',
        'daysPerWeek': _data.daysPerWeek ?? 3,
      });

      // 3. Invalidate workout provider so home screen refreshes
      ref.invalidate(workoutGeneratorProvider);

      // 4. Navigate to gym selection
      if (mounted) context.go('/select-gym');

    } catch (e) {
      if (!mounted) return;

      // Show specific error message
      final msg = e.toString().contains('404')
          ? 'Profile endpoint not found. Check backend.'
          : e.toString().contains('401')
          ? 'Session expired. Please login again.'
          : 'Something went wrong. Please try again.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Skip',
            textColor: Colors.white,
            onPressed: () {
              // Allow skipping to gym selection even if save fails
              context.go('/select-gym');
            },
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool get _canContinue {
    switch (_step) {
      case 0: return _data.goal != null;
      case 1: return _data.experience != null;
      case 2: return _data.daysPerWeek != null;
      case 3: return _data.age != null && _data.gender != null;
      default: return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _step > 0) _back();
      },
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              children: [
                // ── Progress dots ────────────────────────────
                _buildDots(),
                const SizedBox(height: 28),

                // ── Page content ─────────────────────────────
                Expanded(
                  child: PageView(
                    controller: _pages,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _GoalStep(selected: _data.goal,
                        onSelect: (v) => setState(() => _data.goal = v)),
                      _ExperienceStep(selected: _data.experience,
                        onSelect: (v) => setState(() => _data.experience = v)),
                      _DaysStep(selected: _data.daysPerWeek,
                        onSelect: (v) => setState(() => _data.daysPerWeek = v)),
                      _StatsStep(data: _data,
                        onChanged: () => setState(() {})),
                    ],
                  ),
                ),

                // ── Buttons ──────────────────────────────────
                Row(children: [
                  if (_step > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _back,
                        child: const Text('Back'),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _canContinue && !_isLoading ? _next : null,
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.bgPrimary))
                          : Text(_step == _totalSteps - 1
                              ? 'Build my plan 🚀' : 'Continue'),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      children: List.generate(_totalSteps, (i) => Flexible(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(right: 6),
          height: 4,
          decoration: BoxDecoration(
            color: i <= _step
                ? AppColors.accentGreen
                : AppColors.accentGreen.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      )),
    );
  }
}

// ─── Step 1 — Goal ────────────────────────────────────────────────────────────

class _GoalStep extends StatelessWidget {
  final String? selected;
  final void Function(String) onSelect;
  const _GoalStep({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      title: "What's your main goal?",
      subtitle: "We'll build your entire plan around this.",
      child: _OptionGrid(
        options: const [
          _Option('lose_fat',    '🔥', 'Lose Fat'),
          _Option('muscle_gain', '💪', 'Build Muscle'),
          _Option('strength',    '⚡', 'Build Strength'),
          _Option('general',     '❤️', 'Stay Fit'),
        ],
        selected: selected,
        onSelect: onSelect,
      ),
    );
  }
}

// ─── Step 2 — Experience ──────────────────────────────────────────────────────

class _ExperienceStep extends StatelessWidget {
  final String? selected;
  final void Function(String) onSelect;
  const _ExperienceStep({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      title: "Your experience level?",
      subtitle: "Be honest — this sets your workout difficulty.",
      child: _OptionGrid(
        options: const [
          _Option('beginner',     '🌱', 'Beginner'),
          _Option('intermediate', '🌿', 'Intermediate'),
          _Option('advanced',     '🌳', 'Advanced'),
          _Option('athlete',      '🏆', 'Athlete'),
        ],
        selected: selected,
        onSelect: onSelect,
      ),
    );
  }
}

// ─── Step 3 — Days ────────────────────────────────────────────────────────────

class _DaysStep extends StatelessWidget {
  final int? selected;
  final void Function(int) onSelect;
  const _DaysStep({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      title: "How many days per week?",
      subtitle: "Choose how often you can commit.",
      child: Column(
        children: [
          _DayOption(days: 3, label: '3 days — Light',    emoji: '☀️',
            selected: selected == 3, onTap: () => onSelect(3)),
          _DayOption(days: 4, label: '4 days — Moderate', emoji: '🔥',
            selected: selected == 4, onTap: () => onSelect(4)),
          _DayOption(days: 5, label: '5 days — Serious',  emoji: '⚡',
            selected: selected == 5, onTap: () => onSelect(5)),
          _DayOption(days: 6, label: '6 days — Intense',  emoji: '💥',
            selected: selected == 6, onTap: () => onSelect(6)),
        ],
      ),
    );
  }
}

class _DayOption extends StatelessWidget {
  final int days; final String label; final String emoji;
  final bool selected; final VoidCallback onTap;
  const _DayOption({required this.days, required this.label,
    required this.emoji, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.accentGreen.withValues(alpha: 0.08)
            : AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? AppColors.accentGreen : AppColors.border,
          width: selected ? 1.5 : 0.5),
      ),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(
          color: selected ? AppColors.accentGreen : AppColors.textPrimary,
          fontSize: 14, fontWeight: FontWeight.w500)),
        const Spacer(),
        if (selected)
          const Icon(Icons.check_circle,
            color: AppColors.accentGreen, size: 18),
      ]),
    ),
  );
}

// ─── Step 4 — Body Stats ──────────────────────────────────────────────────────

class _StatsStep extends StatelessWidget {
  final _OnboardingData data;
  final VoidCallback onChanged;
  const _StatsStep({required this.data, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      title: "Your body stats",
      subtitle: "Used to personalise your nutrition & plan.",
      child: Column(children: [
        Row(children: [
          Expanded(child: _NumField(
            label: 'Age',
            hint: 'e.g. 24',
            onChanged: (v) { data.age = int.tryParse(v); onChanged(); },
          )),
          const SizedBox(width: 12),
          Expanded(child: _NumField(
            label: 'Height (cm)',
            hint: 'e.g. 175',
            onChanged: (v) { data.heightCm = double.tryParse(v); onChanged(); },
          )),
        ]),
        const SizedBox(height: 12),
        _NumField(
          label: 'Weight (kg)',
          hint: 'e.g. 72',
          onChanged: (v) { data.weightKg = double.tryParse(v); onChanged(); },
        ),
        const SizedBox(height: 12),
        Row(children: [
          _GenderBtn(label: '♂ Male',   value: 'male',
            selected: data.gender == 'male',
            onTap: () { data.gender = 'male'; onChanged(); }),
          const SizedBox(width: 10),
          _GenderBtn(label: '♀ Female', value: 'female',
            selected: data.gender == 'female',
            onTap: () { data.gender = 'female'; onChanged(); }),
        ]),
      ]),
    );
  }
}

class _NumField extends StatelessWidget {
  final String label, hint;
  final void Function(String) onChanged;
  const _NumField({required this.label, required this.hint,
    required this.onChanged});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(
        color: AppColors.textMuted, fontSize: 12)),
      const SizedBox(height: 6),
      TextField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(hintText: hint),
        onChanged: onChanged,
      ),
    ],
  );
}

class _GenderBtn extends StatelessWidget {
  final String label, value;
  final bool selected;
  final VoidCallback onTap;
  const _GenderBtn({required this.label, required this.value,
    required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accentGreen.withValues(alpha: 0.08)
              : AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.accentGreen : AppColors.border,
            width: selected ? 1.5 : 0.5),
        ),
        child: Center(child: Text(label, style: TextStyle(
          color: selected ? AppColors.accentGreen : AppColors.textPrimary,
          fontWeight: FontWeight.w500))),
      ),
    ),
  );
}

// ─── Shared ───────────────────────────────────────────────────────────────────

class _StepShell extends StatelessWidget {
  final String title, subtitle;
  final Widget child;
  const _StepShell({required this.title, required this.subtitle,
    required this.child});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 22, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      Text(subtitle, style: const TextStyle(
        color: AppColors.textMuted, fontSize: 14)),
      const SizedBox(height: 24),
      Expanded(child: SingleChildScrollView(child: child)),
    ],
  );
}

class _Option {
  final String value, emoji, label;
  const _Option(this.value, this.emoji, this.label);
}

class _OptionGrid extends StatelessWidget {
  final List<_Option> options;
  final String? selected;
  final void Function(String) onSelect;
  const _OptionGrid({required this.options,
    required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
    childAspectRatio: 1.3,
    children: options.map((o) => GestureDetector(
      onTap: () => onSelect(o.value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected == o.value
              ? AppColors.accentGreen.withValues(alpha: 0.08)
              : AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected == o.value
                ? AppColors.accentGreen : AppColors.border,
            width: selected == o.value ? 1.5 : 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(o.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(o.label, style: TextStyle(
              color: selected == o.value
                  ? AppColors.accentGreen : AppColors.textPrimary,
              fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    )).toList(),
  );
}