import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

/// The state for the login feature
@freezed
class LoginState with _$LoginState {
  /// Creates a [LoginState]
  const factory LoginState({
    @Default(AsyncValue.data(null)) AsyncValue<void> status,
  }) = _LoginState;
} 