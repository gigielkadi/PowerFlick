# PowerFlick — State Management Rules (v1.0)

PowerFlick uses **Riverpod 2** (`Notifier` / `AsyncNotifier`) for most flows.  
Bloc/Cubit is optional for highly complex FSM or debounced stream cases and lives in `application/bloc/`.

---

## 1  Directory Layout
```
lib/powerflick/<feature>/application/
  ├── notifiers/
  │   └── energy_notifier.dart
  ├── providers.dart          # exports feature‑scoped providers
  └── bloc/                   # optional
      ├── automation_cubit.dart
      └── automation_state.dart
```

---

## 2  State & Notifier Conventions
| Aspect | Rule |
|--------|------|
| **State class** | Use `freezed`, immutable, private ctor `const _();` |
| **Initial factory** | `factory EnergyState.initial() = _Initial;` or default values |
| **Notifier** | Extends `AsyncNotifier<EnergyState>` or `Notifier<EnergyState>` |
| **Dependencies** | Inject via constructor **or** `ref.read(depProvider)` |
| **Public API** | verbs (`refresh`, `toggleNightMode`) returning `Future<void>` |
| **Helper getters** | `isLoading`, `hasError`, `data` inside state class |

### Sample
```dart
// energy_state.dart
@freezed
class EnergyState with _$EnergyState {
  const EnergyState._();

  const factory EnergyState({
    @Default(AsyncValue.loading()) AsyncValue<List<ReadingModel>> readings,
  }) = _EnergyState;

  bool get isLoading => readings.isLoading;
}

// energy_notifier.dart
class EnergyNotifier extends AsyncNotifier<EnergyState> {
  late final IEnergyService _service = ref.read(energyServiceProvider);

  @override
  EnergyState build() => const EnergyState();

  Future<void> refresh(String deviceId) async {
    state = state.copyWith(readings: const AsyncValue.loading());
    final result = await _service.fetchReadings(deviceId: deviceId);
    result.when(
      success: (list) =>
        state = state.copyWith(readings: AsyncValue.data(list)),
      failure: (e) =>
        state = state.copyWith(readings: AsyncValue.error(e)),
    );
  }
}

// providers.dart
final energyNotifierProvider =
    AsyncNotifierProvider<EnergyNotifier, EnergyState>(EnergyNotifier.new);
```

---

## 3  Cubit/Bloc Fallback (Optional)
* Only if you need *stream transformers* or a *complex FSM*.
* Follows original Cubit rules:
  * File names: `_cubit.dart`, `_state.dart`
  * Inject services via ctor.
  * Use `DataState<T>` union for load/error/success.
* Must import providers in `providers.dart` to keep a unified access point.

---

## 4  Naming Rules
| File | Example |
|------|---------|
| **Notifier** | `energy_notifier.dart` |
| **State** | `energy_state.dart` |
| **Providers hub** | `providers.dart` |
| **Cubit** | `automation_cubit.dart` |
| **Bloc** | `auth_bloc.dart` |

---

## 5  Testing
* Use `ProviderContainer` with overrides for service mocks.
* Test **all state transitions**:
  * initial → loading → data
  * initial → loading → error
* For Cubit, use `bloc_test` to assert sequence.

```dart
test('refresh success', () async {
  final container = ProviderContainer(overrides: [
    energyServiceProvider.overrideWithValue(MockEnergyService.success())
  ]);
  final notifier = container.read(energyNotifierProvider.notifier);
  await notifier.refresh('device1');
  expect(container.read(energyNotifierProvider).readings.isData, true);
});
```

---

## 6  Checklist
- [ ] State class uses `freezed` & has `.initial()`.
- [ ] Notifier returns immutable state copies.
- [ ] No Flutter imports in application layer.
- [ ] Providers aggregated in `providers.dart`.
- [ ] Unit tests cover success + error transitions. 