import 'package:flutter_test/flutter_test.dart';
import 'package:xinlu_grain_valley/core/result.dart';

void main() {
  group('Result<T>', () {
    test('Success.fold', () {
      const result = Success<int>(100);
      expect(result.fold((v) => v * 2, (_) => 0), 200);
    });

    test('Failure.fold', () {
      const result = Failure<int>(AppError(message: 'broken'));
      expect(result.fold((_) => true, (_) => false), isFalse);
    });

    test('isSuccess / isFailure', () {
      expect(Success('ok').isSuccess, isTrue);
      expect(Failure(AppError(message: '')).isFailure, isTrue);
    });

    test('map preserves failure', () {
      final result = Failure<int>(AppError(message: 'err'));
      expect(result.map((v) => v * 2).isFailure, isTrue);
    });

    test('getOrElse', () {
      expect(Success(42).getOrElse((_) => 0), 42);
      expect(Failure<int>(AppError(message: '')).getOrElse((_) => -1), -1);
    });
  });
}
