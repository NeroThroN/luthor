import 'package:luthor/luthor.dart';
import 'package:test/test.dart';

void main() {
  test(
    'should return true if the string length is greater than or equal to minLength',
    () {
      final result = l.string().min(3).validate('abc');
      expect(result.isValid, isTrue);

      result.whenOrNull(
        error: (_) => fail('should not be error'),
      );
    },
  );

  test(
    'should return false if the string length is less than minLength',
    () {
      final result = l.string().min(3).validate('ab');

      result.when(
        error: (message) {
          expect(message, 'value must be at least 3 characters long');
        },
        success: (_) => fail('should not be success'),
      );
    },
  );

  test(
    'should return true when the value is null',
    () {
      final result = l.string().min(3).validate(null);
      expect(result.isValid, isTrue);

      result.whenOrNull(
        error: (_) => fail('should not be error'),
      );
    },
  );

  test(
    'should return false if the value is null with required()',
    () {
      final result = l.string().min(3).required().validate(null);

      result.when(
        error: (message) {
          expect(message, 'value is required');
        },
        success: (_) => fail('should not be success'),
      );
    },
  );
}
