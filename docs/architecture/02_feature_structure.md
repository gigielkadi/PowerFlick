# PowerFlick — Feature Structure & Naming Conventions (v1.0)

These conventions refine the generic Flutter layout for **PowerFlick**, the Supabase‑backed energy‑management app.  
Default state‑management is **Riverpod 2**. For flows that warrant Bloc/Cubit, place them in a `/bloc/` sub‑folder.

---

## 1  Directory Hierarchy
```
lib/
  ├── core/
  │   ├── constants/           # K‑prefixed sizes, colors …
  │   ├── themes/
  │   └── routing/
  └── powerflick/
      └── <feature>/           # e.g. energy, automation, auth
          ├── application/
          │   ├── notifiers/
          │   │   └── energy_notifier.dart
          │   ├── providers.dart
          │   └── bloc/        # optional: cubit or bloc files live here
          ├── domain/
          │   ├── models/
          │   │   └── device_model.dart
          │   ├── services/
          │   │   └── i_device_service.dart
          │   └── errors/
          ├── infrastructure/
          │   ├── dtos/
          │   │   └── device_dto.dart
          │   └── supabase/
          │       └── device_service.dart
          └── presentation/
              ├── pages/
              │   └── energy_dashboard_page.dart
              └── widgets/
                  ├── energy_gauge_widget.dart
                  └── _local_icon.dart
```

---

## 2  Files & Naming

| Category | File Suffix | Example |
|----------|-------------|---------|
| **Notifier** | `_notifier.dart` | `energy_notifier.dart` |
| **Provider reg.** | `providers.dart` | `providers.dart` |
| **Cubit (opt.)** | `_cubit.dart` | `automation_cubit.dart` |
| **Bloc (opt.)** | `_bloc.dart` | `auth_bloc.dart` |
| **State (Cubit)** | `_state.dart` | `automation_state.dart` |
| **Model** | `_model.dart` | `reading_model.dart` |
| **DTO** | `_dto.dart` | `reading_dto.dart` |
| **Widget** | `_widget.dart` | `device_tile_widget.dart` |
| **Page / Screen** | `_page.dart` | `settings_page.dart` |
| **Constants** | `k_*.dart` | `k_sizes.dart` |

> All names are **snake_case**; classes are **PascalCase**.

---

## 3  Application‑Layer Conventions
### Riverpod
* Register *feature‑scoped* providers in `<feature>/application/providers.dart`.
* Notify state via `Notifier`/`AsyncNotifier` classes in `notifiers/`.
* Expose immutable state models (Freezed preferred).

### Bloc/Cubit (edge cases)
* Only when stream transformers or complex FSM justify it.
* Live in `application/bloc/`.
* Keep Cubit's `state.dart` in same folder.

---

## 4  Layout Constants (KSizes)

* Use `KSize` helpers **everywhere**—no magic numbers.
* Follow a 4‑point scale: `4, 8, 12, 16, 20, 24`, etc.
```dart
class KSize {
  // spacing
  static const s4  = 4.0;
  static const s8  = 8.0;
  static const s12 = 12.0;
  // fonts
  static const fontS = 12.0;
  static const fontM = 16.0;
}
```

---

## 5  Code‑Organization Checklist
- [ ] Each layer (domain, infra, app, UI) isolated via interfaces.
- [ ] Presentation contains *zero* business logic.
- [ ] No Supabase import outside `infrastructure/`.
- [ ] Providers re‑export only what UI needs.

---

## 6  Testing Layout
```
test/
  └── powerflick/
      └── <feature>/
          ├── application/
          │   ├── notifiers/
          │   │   └── energy_notifier_test.dart
          │   └── bloc/
          ├── domain/
          ├── infrastructure/
          └── presentation/
              └── widgets/
```
* Use `mocktail` + `supabase_flutter` mocks for infra.
* Widget tests wrap page in `ProviderScope`.

---

## 7  Best Practices
1. Keep widgets ≤ 200 LOC; break down otherwise.
2. Use **extension methods** for padding helpers: `context.paddingHorizontal(KSize.s16)`.
3. Expose **typed** IDs (`typedef DeviceId = String;`) to avoid mix‑ups.
4. Prefer **sealed error unions** (`ReadingError`) over generic `Exception`. 