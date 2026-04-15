import 'extensions.dart';
import 'style_file_data.dart';
import 'utils.dart';

/// Generates the main class of the package that exposes all the style classes
void generateMainClass(List<StyleFileData> styles) {
  print('Generating style abstract class phosphor_icons.dart file');

  final exports = styles
      .map((style) =>
          "export 'package:phosphor_flutter/src/${style.classFileName}';")
      .join('\n');

  final content =
      "$exports\nexport 'package:phosphor_flutter/src/phosphor_icons_base.dart';\n";

  saveContentToFile(
    filePath: '../lib/src/phosphor_icons.dart',
    content: content,
  );
}

/// Generates an abstract class that exposes all the icons that every style extends
void generateBaseClass(List icons) {
  print('Generating phosphor_icons_base.dart file');
  final styles = StyleFileData.values;

  final styleImports = styles
      .map((style) =>
          "import 'package:phosphor_flutter/src/${style.classFileName}';")
      .join('\n');

  final stylesEnumValues = styles
      .map((style) => '  ${style.docsLine}\n  ${style.styleName},')
      .join('\n\n');

  final classDocLines = [
    '/// This class helps to access the icons of all the styles. Use the specific style class to access the icons of that style:',
    ...styles.map((style) => '/// - [${style.className}]'),
  ].join('\n');

  final methods = icons.map((icon) => buildBaseMethodIcon(icon)).join('\n\n');

  final content = """import 'package:phosphor_flutter/src/phosphor_icon_data.dart';
$styleImports

$classDocLines
class PhosphorIcons {
$methods
}

enum PhosphorIconsStyle {
$stylesEnumValues
}
""";

  saveContentToFile(
    filePath: '../lib/src/phosphor_icons_base.dart',
    content: content,
  );
}

String buildBaseMethodIcon(dynamic icon) {
  final properties = icon['properties'] as Map<String, dynamic>;
  final rawName = properties['name'] as String;
  final fullName = rawName.split(",").first;
  final name = formatName(fullName, style: 'regular');
  final styles = StyleFileData.values;

  final docLines = styles
      .map((style) =>
          '  /// ${style.styleName}: ![$fullName](https://raw.githubusercontent.com/phosphor-icons/core/main/assets/${style.styleName}/$fullName.svg)')
      .join('\n');

  final switchCases = styles
      .map((style) => '''      case PhosphorIconsStyle.${style.styleName}:
        return ${style.className}.$name;''')
      .join('\n');

  return '''$docLines
  static PhosphorIconData $name(
      [PhosphorIconsStyle style = PhosphorIconsStyle.regular]) {
    switch (style) {
$switchCases
    }
  }''';
}

/// reads the phosphor json of one style and generates a dart class
/// with all the phosphor icons constants for that style
void generateStyleClass(List icons, {required StyleFileData style}) {
  print('Generating style abstract class ${style.classFileName} file');

  final fields = icons
      // filter only valid icons by idx of the style
      .where((icon) => icon['setIdx'] as int == style.idx)
      // Generate the field for the icon
      .map((icon) => buildFieldIconByStyle(icon, style: style))
      .toList()
    // sort the element alphabetically
    ..sort((a, b) => a.$1.compareTo(b.$1));

  final fieldsContent = fields.map((f) => f.$2).join('\n\n');

  final content = """import 'package:phosphor_flutter/src/phosphor_icon_data.dart';
import 'package:flutter/widgets.dart';

@staticIconProvider
class ${style.className} {
  const ${style.className}();

$fieldsContent
}
""";

  saveContentToFile(
    filePath: '../lib/src/${style.classFileName}',
    content: content,
  );
}

/// Returns (name, fieldSource) tuple for sorting
(String, String) buildFieldIconByStyle(dynamic icon,
    {required StyleFileData style}) {
  final properties = icon['properties'] as Map<String, dynamic>;
  final fullName = properties['name'] as String;
  final firstName = fullName.split(",").first;
  final name = formatName(firstName, style: style.styleName);

  final iconDoc =
      '  /// ![$firstName](https://raw.githubusercontent.com/phosphor-icons/core/main/assets/${style.styleName}/$firstName.svg)';

  String fieldValue;

  if (style == StyleFileData.duotone && properties['codes'] != null) {
    final graphCodes = (properties['codes'] as List).cast<int>();
    final backgroundHexCode = '0x' + graphCodes.first.toRadixString(16);
    final foregroundHexCode = '0x' + graphCodes.last.toRadixString(16);
    fieldValue =
        "PhosphorDuotoneIconData($foregroundHexCode, PhosphorIconData($backgroundHexCode, 'Duotone'),)";
  } else {
    final graphCode = properties['code'] as int;
    final hexCode = '0x' + graphCode.toRadixString(16);
    fieldValue = "PhosphorFlatIconData($hexCode, '${style.styleName.capitalize()}')";
  }

  final fieldSource = '$iconDoc\n  static const $name = $fieldValue;';
  return (name, fieldSource);
}
