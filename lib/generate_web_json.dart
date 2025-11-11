import 'dart:convert';
import 'dart:io';
import 'package:gen_lang/extra_json_file_tool.dart';
import 'package:gen_lang/print_tool.dart';
import 'package:path/path.dart' as path;

/// Converts snake_case to camelCase
String snakeToCamel(String snake) {
  if (snake.isEmpty) return snake;

  List<String> parts = snake.split('_');
  if (parts.length == 1) return snake;

  String result = parts[0];
  for (int i = 1; i < parts.length; i++) {
    if (parts[i].isNotEmpty) {
      result += parts[i][0].toUpperCase() + parts[i].substring(1);
    }
  }

  return result;
}

/// Parses a key with __ separators into a namespace path
/// Example: "web_sharing__app__name" -> ["webSharing", "app", "name"]
List<String> parseKeyToNamespacePath(String key) {
  // Split by double underscore to get namespace segments
  List<String> segments = key.split('__');

  // Convert each segment from snake_case to camelCase
  return segments.map((segment) => snakeToCamel(segment)).toList();
}

/// Builds a nested map structure from a namespace path and value
/// Example: ["webSharing", "app", "name"], "Daily Habits" -> {"webSharing": {"app": {"name": "Daily Habits"}}}
void setNestedValue(Map<String, dynamic> map, List<String> path, String value) {
  if (path.isEmpty) return;

  // Navigate to the deepest level, creating maps as needed
  Map<String, dynamic> current = map;
  for (int i = 0; i < path.length - 1; i++) {
    String key = path[i];
    if (!current.containsKey(key)) {
      current[key] = <String, dynamic>{};
    }
    current = current[key] as Map<String, dynamic>;
  }

  // Set the final value
  current[path.last] = value;
}

/// Generates Web JSON file content with nested structure
String generateWebJsonFile(Map<String, String> strings) {
  Map<String, dynamic> nestedMap = {};

  // Build nested structure from all keys
  for (MapEntry<String, String> entry in strings.entries) {
    List<String> path = parseKeyToNamespacePath(entry.key);
    setNestedValue(nestedMap, path, entry.value);
  }

  // Convert to pretty-printed JSON
  JsonEncoder encoder = JsonEncoder.withIndent('  ');
  return encoder.convert(nestedMap) + '\n';
}

/// Converts locale string (e.g., "en", "zh_TW") to web locale file name
String getWebLocaleFileName(String locale) {
  // Web uses language codes with underscores converted to hyphens
  // e.g., en -> en.json, zh_TW -> zh-TW.json
  String webLocale = locale.replaceAll('_', '-');
  return '$webLocale.json';
}

/// Generates Web JSON strings for all locales
Future<void> generateWebStrings(
  String webDir,
  Map<String, FileSystemEntity> validFilesMap,
  Set<String> webStringKeys,
) async {
  // Check if web directory exists
  Directory webDirEntity = Directory(webDir);

  if (!webDirEntity.existsSync()) {
    printWarning('Web directory not found: $webDir');
    printWarning('Skipping Web strings generation');
    return;
  }

  printInfo('Generating Web JSON files...');
  int generatedCount = 0;

  for (MapEntry<String, FileSystemEntity> entry in validFilesMap.entries) {
    String locale = entry.key;
    FileSystemEntity fileEntity = entry.value;

    // Parse JSON and extract only web_strings keys
    Map<String, Message> jsonKeyMap = await generateJsonKeyMessageMap(File(fileEntity.path));
    Map<String, String> webStrings = {};

    for (String key in webStringKeys) {
      if (jsonKeyMap.containsKey(key)) {
        Message message = jsonKeyMap[key]!;
        // Only simple messages are supported for Web
        if (message.messageKey.type == MessageType.message && message.message != null) {
          webStrings[key] = message.message!;
        }
      }
    }

    if (webStrings.isEmpty) {
      continue;
    }

    // Write JSON file for locale
    String jsonFileName = getWebLocaleFileName(locale);
    String jsonFilePath = path.join(webDir, jsonFileName);
    File jsonFile = File(jsonFilePath);
    jsonFile.writeAsStringSync(generateWebJsonFile(webStrings));

    printInfo('Generated: $jsonFilePath (${webStrings.length} strings)');
    generatedCount++;
  }

  printInfo('Web strings generation completed: $generatedCount file(s)');
}

/// Reads web_strings.json and returns set of keys to generate
Future<Set<String>?> readWebStringsConfig(String sourceDir) async {
  String configPath = path.join(sourceDir, 'web_strings.json');
  File configFile = File(configPath);

  if (!configFile.existsSync()) {
    return null;
  }

  try {
    String content = await configFile.readAsString();
    dynamic config = jsonDecode(content);

    // web_strings.json should contain an array of string keys
    // Example: ["web_sharing__app__name", "web_sharing__loading__text"]
    if (config is List) {
      return Set<String>.from(config);
    } else if (config is Map && config.containsKey('keys')) {
      return Set<String>.from(config['keys']);
    } else {
      printWarning('web_strings.json has invalid format. Expected array of strings or object with "keys" array');
      return null;
    }
  } catch (e) {
    printWarning('Failed to parse web_strings.json: $e');
    return null;
  }
}
