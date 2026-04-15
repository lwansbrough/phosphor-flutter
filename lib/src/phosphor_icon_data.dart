library phosphor_flutter;

import 'package:flutter/widgets.dart';

/// Base class for Phosphor icon data.
/// Uses composition instead of extending [IconData] since [IconData] is final.
class PhosphorIconData {
  final int codePoint;
  final String style;

  const PhosphorIconData(this.codePoint, this.style);

  IconData get iconData => IconData(
    codePoint,
    fontFamily: 'Phosphor$style',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
}

class PhosphorFlatIconData extends PhosphorIconData {
  const PhosphorFlatIconData(int codePoint, String style)
    : super(codePoint, style);
}

class PhosphorDuotoneIconData extends PhosphorIconData {
  const PhosphorDuotoneIconData(int codePoint, this.secondary)
    : super(codePoint, 'Duotone');

  final PhosphorIconData secondary;
}
