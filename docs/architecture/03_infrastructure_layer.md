# PowerFlick — Infrastructure Layer Rules (v1.0)

These guidelines specialise the **infrastructure layer** for PowerFlick, the Supabase‑backed energy‑management app.
The layer's purpose is to convert external/DB payloads ↔ domain models, implement interfaces, and deal with IO & errors.

> **Allowed packages here only**: `supabase_flutter`, `dio` (external REST), `freezed`, `json_annotation`, `result_type`, `logger`.

---

## 1  Directory Structure
```
lib/
  └── powerflick/
      └── <feature>/            # e.g. energy, automation
          └── infrastructure/
              ├── dtos/
              │   └── reading_dto.dart
              ├── constants/
              │   └── energy_endpoints.dart
              ├── supabase/
              │   └── reading_service.dart
              └── external/     # optional REST clients
                  └── tariff_api_client.dart
```

---

## 2  DTO Conventions
| Rule | Note |
|------|------|
| **Immutable** | Use `freezed` + `@JsonSerializable` |
| **Defaults** | Provide safe defaults in ctor |
| **fromJson / toJson** | Generated via `json_annotation` |
| **toDomain()** | Converts to pure domain model (`ReadingModel`) |
| **Null safety** | Prefer `required` params; use `@JsonKey(defaultValue: …)` |
| **Match source** | Field names mirror Supabase columns / API keys |

### Sample `ReadingDto`
```dart
@freezed
class ReadingDto with _$ReadingDto {
  const ReadingDto._(); // adds toDomain() helper

  const factory ReadingDto({
    @Default('') String deviceId,
    @JsonKey(name: 'ts') required DateTime timestamp,
    @JsonKey(name: 'watts') @Default(0) int watts,
  }) = _ReadingDto;

  factory ReadingDto.fromJson(Map<String,dynamic> json) =>
      _$ReadingDtoFromJson(json);

  ReadingModel toDomain() =>
      ReadingModel(deviceId: deviceId, timestamp: timestamp, watts: watts);
}
```

---

## 3  Constants & End‑points
* Keep Supabase table names and RPC paths in `<feature>/infrastructure/constants/`.
* Use `static const` strings inside a `EnergyEndpoints` class.

```dart
abstract class EnergyEndpoints {
  static const tableReadings = 'energy_readings';
  static const rpcInsertReading = 'insert_reading';
}
```

---

## 4  Service Implementation Rules
1. **Implements the domain interface** (`IEnergyService`).
2. Converts DTO ↔ domain.
3. Uses `Result<T,E>` for all outcomes.
4. Error mapping table:
   * `PostgrestException.code == "PGRST116"` → `EnergyError.notFound`
   * Network / timeout → `EnergyError.network`.
5. No business logic—only IO orchestration.

### Sample Supabase Service
```dart
class EnergyService implements IEnergyService {
  final SupabaseClient _client;
  EnergyService(this._client);

  @override
  Future<Result<List<ReadingModel>, EnergyError>> fetchReadings(
      {required String deviceId, required DateTime since}) async {
    try {
      final data = await _client
          .from(EnergyEndpoints.tableReadings)
          .select()
          .eq('device_id', deviceId)
          .gte('ts', since.toIso8601String())
          .order('ts')
          .execute();
      final dtos = (data as List).map((e) => ReadingDto.fromJson(e)).toList();
      return Success(dtos.map((d) => d.toDomain()).toList());
    } on PostgrestException catch (e, s) {
      logger.e(e.message, e, s);
      return Failure(EnergyError.db);
    } on SocketException {
      return Failure(EnergyError.network);
    }
  }
}
```

---

## 5  File Naming
| Type | Rule | Example |
|------|------|---------|
| DTO  | `_dto.dart` | `device_dto.dart` |
| Service | `_service.dart` | `energy_service.dart` |
| Constants | `_endpoints.dart` or `_api_keys.dart` | `energy_endpoints.dart` |

All names are **snake_case**; classes are **PascalCase** ending in `Dto` or `Service`.

---

## 6  Testing
* Mock `SupabaseClient` with `mocktail`.
* Assert DTO ↔ domain conversions.
* Verify error mapping for Postgrest/network exceptions.
* Use `Result.success` & `Result.failure` branches.

Directory:
```
test/powerflick/<feature>/infrastructure/
  ├── dtos/
  ├── energy_service_test.dart
```

---

## 7  Checklist
- [ ] DTOs have `toDomain()` + `fromJson`.
- [ ] Services handle all Postgrest codes.
- [ ] Constants centralised—no inline strings.
- [ ] Infrastructure layer imports no presentation code. 