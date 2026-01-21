import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:risetechpreneur/core/enrollment_validation.dart';

void main() {
  test('requires image selection', () {
    expect(validatePaymentProofImage(null), isNotNull);
  });

  test('rejects unsupported extension', () async {
    final f = File('${Directory.systemTemp.path}/proof_test.txt');
    await f.writeAsString('nope');

    final err = validatePaymentProofImage(f);
    expect(err, isNotNull);
    expect(err, contains('Unsupported'));
  });

  test('rejects images over 5MB', () async {
    final f = File('${Directory.systemTemp.path}/proof_test.jpg');
    final bytes = List<int>.filled(kMaxPaymentProofBytes + 1, 0);
    await f.writeAsBytes(bytes);

    final err = validatePaymentProofImage(f);
    expect(err, contains('too large'));
  });

  test('accepts valid png/jpg/jpeg under size limit', () async {
    final png = File('${Directory.systemTemp.path}/proof_test.png');
    await png.writeAsBytes([1, 2, 3]);

    expect(validatePaymentProofImage(png), isNull);

    final jpeg = File('${Directory.systemTemp.path}/proof_test.jpeg');
    await jpeg.writeAsBytes([1, 2, 3]);

    expect(validatePaymentProofImage(jpeg), isNull);
  });
}
