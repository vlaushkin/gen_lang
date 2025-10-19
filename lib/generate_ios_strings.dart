import 'dart:convert';
import 'dart:io';
import 'package:gen_lang/extra_json_file_tool.dart';
import 'package:gen_lang/print_tool.dart';
import 'package:path/path.dart' as path;

/// Generates iOS .strings file content
String generateIosStringsFile(Map<String, String> strings) {
  StringBuffer buffer = StringBuffer();
  buffer.writeln('/* DO NOT EDIT. This is code generated via package:gen_lang/generate.dart */');
  buffer.writeln();

  for (MapEntry<String, String> entry in strings.entries) {
    String escapedValue = escapeIosString(entry.value);
    buffer.writeln('"${entry.key}" = "$escapedValue";');
  }

  return buffer.toString();
}

/// Escapes special characters for iOS .strings files
String escapeIosString(String value) {
  return value
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\r', '\\r')
      .replaceAll('\t', '\\t');
}

/// Converts locale string (e.g., "en", "zh_TW") to iOS .lproj directory name
String getIosLprojDir(String locale) {
  // iOS uses language codes with underscores converted to hyphens
  // e.g., en -> en.lproj, zh_TW -> zh-TW.lproj
  String iosLocale = locale.replaceAll('_', '-');
  return '$iosLocale.lproj';
}

/// Generates iOS strings for all locales
Future<void> generateIosStrings(
  String iosDir,
  Map<String, FileSystemEntity> validFilesMap,
  Set<String> iosStringKeys,
) async {
  // Check if iOS Runner directory exists
  String runnerPath = path.join(iosDir, 'Runner');
  Directory runnerDir = Directory(runnerPath);

  if (!runnerDir.existsSync()) {
    printWarning('iOS Runner directory not found: $runnerPath');
    printWarning('Skipping iOS strings generation');
    return;
  }

  // Create Resources directory if it doesn't exist
  String resourcesPath = path.join(runnerPath, 'Resources');
  Directory resourcesDir = Directory(resourcesPath);

  if (!resourcesDir.existsSync()) {
    resourcesDir.createSync(recursive: true);
    printInfo('Created iOS Resources directory: $resourcesPath');
  }

  printInfo('Generating iOS strings...');
  int generatedCount = 0;

  for (MapEntry<String, FileSystemEntity> entry in validFilesMap.entries) {
    String locale = entry.key;
    FileSystemEntity fileEntity = entry.value;

    // Parse JSON and extract only ios_strings keys
    Map<String, Message> jsonKeyMap = await generateJsonKeyMessageMap(File(fileEntity.path));
    Map<String, String> iosStrings = {};

    for (String key in iosStringKeys) {
      if (jsonKeyMap.containsKey(key)) {
        Message message = jsonKeyMap[key]!;
        // Only simple messages are supported for iOS
        if (message.messageKey.type == MessageType.message && message.message != null) {
          iosStrings[key] = message.message!;
        }
      }
    }

    if (iosStrings.isEmpty) {
      continue;
    }

    // Create .lproj directory for locale
    String lprojDirName = getIosLprojDir(locale);
    String lprojDirPath = path.join(resourcesPath, lprojDirName);
    Directory lprojDir = Directory(lprojDirPath);

    if (!lprojDir.existsSync()) {
      lprojDir.createSync(recursive: true);
      printInfo('Created directory: $lprojDirPath');
    }

    // Write Localizable.strings
    String stringsFilePath = path.join(lprojDirPath, 'Localizable.strings');
    File stringsFile = File(stringsFilePath);
    stringsFile.writeAsStringSync(generateIosStringsFile(iosStrings));

    printInfo('Generated: $stringsFilePath (${iosStrings.length} strings)');
    generatedCount++;
  }

  printInfo('iOS strings generation completed: $generatedCount file(s)');
}

/// Reads ios_strings.json and returns set of keys to generate
Future<Set<String>?> readIosStringsConfig(String sourceDir) async {
  String configPath = path.join(sourceDir, 'ios_strings.json');
  File configFile = File(configPath);

  if (!configFile.existsSync()) {
    return null;
  }

  try {
    String content = await configFile.readAsString();
    dynamic config = jsonDecode(content);

    // ios_strings.json should contain an array of string keys
    // Example: ["app_name", "welcome_message", "button_ok"]
    if (config is List) {
      return Set<String>.from(config);
    } else if (config is Map && config.containsKey('keys')) {
      return Set<String>.from(config['keys']);
    } else {
      printWarning('ios_strings.json has invalid format. Expected array of strings or object with "keys" array');
      return null;
    }
  } catch (e) {
    printWarning('Failed to parse ios_strings.json: $e');
    return null;
  }
}
