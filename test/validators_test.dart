import 'package:flutter_test/flutter_test.dart';
import 'package:hostel_finder_app/core/utils/validators.dart';

void main() {
  group('Validators.price', () {
    test('accepts normal positive prices', () {
      expect(Validators.price('12000'), isNull);
      expect(Validators.price('  8500.50 '), isNull);
    });
    test('rejects empty, zero, negative, non-numeric and absurd values', () {
      expect(Validators.price(''), isNotNull);
      expect(Validators.price('0'), isNotNull);
      expect(Validators.price('-5'), isNotNull);
      expect(Validators.price('abc'), isNotNull);
      expect(Validators.price('NaN'), isNotNull);
      expect(Validators.price('Infinity'), isNotNull);
      expect(Validators.price('99999999999'), isNotNull);
    });
  });

  group('Validators.rooms / beds', () {
    test('accept whole numbers >= 1', () {
      expect(Validators.rooms('1'), isNull);
      expect(Validators.rooms('40'), isNull);
      expect(Validators.beds('120'), isNull);
    });
    test('reject zero, negatives, decimals and empty', () {
      for (final bad in ['0', '-3', '2.5', '', 'x']) {
        expect(Validators.rooms(bad), isNotNull, reason: 'rooms "$bad"');
        expect(Validators.beds(bad), isNotNull, reason: 'beds "$bad"');
      }
    });
  });

  group('Validators.email', () {
    test('accepts long TLDs and plus addressing', () {
      expect(Validators.email('name@company.online'), isNull);
      expect(Validators.email('name@studio.photography'), isNull);
      expect(Validators.email('first.last+tag@mail.example.com'), isNull);
    });
    test('rejects malformed addresses', () {
      expect(Validators.email('no-at-sign'), isNotNull);
      expect(Validators.email('a@b'), isNotNull);
      expect(Validators.email(''), isNotNull);
    });
  });

  group('Validators.phone (Pakistan mobile, 11 digits starting with 0)', () {
    test('accepts 03123456775 and tolerates spaces/dashes', () {
      expect(Validators.phone('03123456775'), isNull);
      expect(Validators.phone('0312 3456775'), isNull);
      expect(Validators.phone('0312-3456775'), isNull);
    });
    test('rejects +92 / 92 forms, wrong length, wrong prefix and empty', () {
      for (final bad in [
        '+923123456775',
        '923123456775',
        '3123456775',
        '0312345677',
        '031234567751',
        '02123456775',
        '03a23456775',
        '',
        '   ',
      ]) {
        expect(Validators.phone(bad), isNotNull, reason: '"$bad"');
      }
    });
    test('the error message no longer asks for +92', () {
      expect(Validators.phone('+923123456775'), isNot(contains('+92')));
    });
  });
}
