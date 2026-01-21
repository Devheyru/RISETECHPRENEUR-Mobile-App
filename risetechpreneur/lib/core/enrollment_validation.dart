library;

import 'dart:io';

const int kMaxPaymentProofBytes = 5 * 1024 * 1024;
const Set<String> kAllowedPaymentProofExtensions = {'png', 'jpg', 'jpeg'};

/// Returns a user-friendly error message if invalid, otherwise `null`.
String? validatePaymentProofImage(
  File? file, {
  int maxBytes = kMaxPaymentProofBytes,
  Set<String> allowedExtensions = kAllowedPaymentProofExtensions,
}) {
  if (file == null) {
    return 'Please select a payment proof image.';
  }

  final path = file.path;
  final dot = path.lastIndexOf('.');
  final ext = dot == -1 ? '' : path.substring(dot + 1).toLowerCase();
  if (!allowedExtensions.contains(ext)) {
    final exts = (allowedExtensions.toList()..sort())
        .map((e) => e.toUpperCase())
        .join(', ');
    return 'Unsupported file type. Please use $exts.';
  }

  if (!file.existsSync()) {
    return 'Selected file is missing. Please choose another image.';
  }

  final size = file.lengthSync();
  if (size > maxBytes) {
    final maxMb = (maxBytes / (1024 * 1024)).toStringAsFixed(0);
    return 'Image is too large. Please choose an image under ${maxMb}MB.';
  }
  }

  return null;
}
