import 'style_file_data.dart';
import 'utils.dart';

/// reads a list of icons graphs and generates a dart class
/// with all the phosphor icons constants from the generated files
void generateExampleAppConstants(List icons) {
  print('Generating example app all_icons.dart file');

  final stylesMaps = {
    StyleFileData.regular: <String>[],
    StyleFileData.thin: <String>[],
    StyleFileData.light: <String>[],
    StyleFileData.bold: <String>[],
    StyleFileData.fill: <String>[],
    StyleFileData.duotone: <String>[],
  };

  icons.forEach((icon) {
    final properties = icon['properties'] as Map<String, dynamic>;
    final rawName = properties['name'] as String;
    final fullName = rawName.split(",").first;
    for (final style in StyleFileData.values) {
      final name = formatName(fullName, style: 'regular');
      final mapEntryLine =
          "'$fullName': PhosphorIcons.$name(PhosphorIconsStyle.${style.styleName})";
      stylesMaps[style]!.add(mapEntryLine);
    }
  });

  final styleGetters = stylesMaps.entries.map((entry) {
    final style = entry.key;
    final lines = entry.value;
    return _buildIconsMapGetter(
      styleName: style.styleName,
      lines: lines,
    );
  }).join('\n\n');

  final content = """import 'package:phosphor_flutter/phosphor_flutter.dart';

abstract class AllIcons {
  static List<PhosphorIconData> get icons => allFlatIconsAsMap.values.toList();

  static List<String> get names => allFlatIconsAsMap.keys.toList();

  static Map<String, PhosphorIconData> get allFlatIconsAsMap => {
        ...regularIcons,
        ...thinIcons,
        ...lightIcons,
        ...boldIcons,
        ...fillIcons,
        ...duotoneIcons,
      };

$styleGetters
}
""";

  saveContentToFile(
    filePath: '../example/lib/constants/all_icons.dart',
    content: content,
  );
}

String _buildIconsMapGetter({
  required String styleName,
  required List<String> lines,
}) {
  final entries = lines.join(',\n    ');
  return '  static Map<String, PhosphorIconData> get ${styleName}Icons => {\n    $entries\n  };';
}
