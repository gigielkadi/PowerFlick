# PowerFlick — Presentation Layer Rules (v1.0)

The presentation layer is **UI‑only**. Business logic stays in application/domain.  
Default state‑management is **Riverpod 2** using `ConsumerWidget` and `ref.watch`.  
Bloc/Cubit can be used when a finite‑state machine or debounced streams are required; those files live under `presentation/bloc/`.

---

## 1  Directory Structure
```
lib/
  └── powerflick/
      └── <feature>/
          └── presentation/
              ├── pages/
              │   └── energy_dashboard_page.dart
              ├── widgets/
              │   └── live_power_gauge_widget.dart
              └── bloc/              # optional
                  ├── automation_cubit.dart
                  └── automation_state.dart
```

---

## 2  Page Conventions
| Guideline | Detail |
|-----------|--------|
| **Single responsibility** | One purpose per page (e.g., EnergyDashboardPage) |
| **State access** | Use `ConsumerWidget` + `ref.watch(provider)` |
| **UI States** | Handle loading / error / data within page or a separate handler widget |
| **Layout** | All spacing via `KSize` constants; never hard‑coded numbers |
| **Keys** | Give root widgets a `ValueKey` for testability |

### Example Page (Riverpod)
```dart
class EnergyDashboardPage extends ConsumerWidget {
  const EnergyDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(energyNotifierProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(KSize.s16),
          child: state.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e,_) => ErrorView(
              message: e.toString(),
              onRetry: () => ref.read(energyNotifierProvider.notifier).refresh(),
            ),
            data: (_) => const EnergyDashboardView(),
          ),
        ),
      ),
    );
  }
}
```

---

## 3  Widget Conventions
* **Small & Focused** – under 200 LOC.
* **Stateless** unless they manage local animation controllers.
* Accept **named, required** parameters.
* Use `KSize` for padding, radius, font sizes.

```dart
class LivePowerGaugeWidget extends StatelessWidget {
  const LivePowerGaugeWidget({
    super.key,
    required this.watts,
  });

  final int watts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KSize.s12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(KSize.radius),
      ),
      child: Text('$watts W'),
    );
  }
}
```

---

## 4  Naming Rules
| Type | File Suffix | Example |
|------|-------------|---------|
| **Page** | `_page.dart` | `settings_page.dart` |
| **Widget** | `_widget.dart` | `device_tile_widget.dart` |
| **Cubit/Bloc** | `_cubit.dart` / `_bloc.dart` | `automation_cubit.dart` |
Classes mirror file names in **PascalCase** and end in `Page`, `Widget`, or `Cubit`.

---

## 5  State Handling Patterns
* `Notifier`/`AsyncNotifier` ➜ `ref.watch(...)` for rendering.
* `ref.listen` in `initState` (if using `ConsumerStatefulWidget`) for side effects.
* For Bloc, pair `BlocBuilder` + `BlocListener`.

---

## 6  Error Handling
* Display friendly copy (`"Something went wrong – pull to retry"`).
* Provide retry callbacks.
* Use `ErrorView` widget across app for consistency.

---

## 7  Testing
```
test/powerflick/<feature>/presentation/
  ├── pages/
  │   └── energy_dashboard_page_test.dart
  └── widgets/
      └── live_power_gauge_widget_test.dart
```
* Wrap widgets in `ProviderScope` with mocked providers.
* Use `WidgetTester.pumpWidget` for golden tests.
* Verify error & loading states.

---

## 8  Checklist
- [ ] Page uses `KSize` constants for spacing.
- [ ] No direct Supabase calls (should go via provider).
- [ ] Widgets under `/widgets/` are reusable.
- [ ] All state branches covered in widget tests. 