import 'package:luthor/luthor.dart';
import 'package:test/test.dart';

void main() {
  test('should return true when value is a valid uri', () {
    final result = l.string().uri().validate('https://dart.dev');
    expect(result.isValid, isTrue);

    result.whenOrNull(
      error: (_) => fail('should not be error'),
    );
  });

  test('should return true when value is a valid uri and matches the scheme',
      () {
    final result =
        l.string().uri(allowedSchemes: ['https']).validate('https://dart.dev');
    expect(result.isValid, isTrue);

    result.whenOrNull(
      error: (_) => fail('should not be error'),
    );
  });

  test(
    'should return false when value is a valid uri but does not match the scheme',
    () {
      final result =
          l.string().uri(allowedSchemes: ['https']).validate('http://dart.dev');

      result.when(
        error: (message) {
          expect(message, 'value must be a valid uri. Allowed scheme is https');
        },
        success: (_) => fail('should not be success'),
      );
    },
  );

  test('should return false when value is not a valid uri', () {
    final result = l.string().uri().validate(':hello');

    result.when(
      error: (message) {
        expect(message, 'value must be a valid uri');
      },
      success: (_) => fail('should not be success'),
    );
  });

  test('should return true when value is null', () {
    final result = l.string().uri().validate(null);
    expect(result.isValid, isTrue);

    result.whenOrNull(
      error: (_) => fail('should not be error'),
    );
  });

  test('should return false if the value is null with required()', () {
    final result = l.string().uri().required().validate(null);

    result.when(
      error: (message) {
        expect(message, 'value is required');
      },
      success: (_) => fail('should not be success'),
    );
  });
}
