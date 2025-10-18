import 'dart:convert';
import 'dart:io';
import 'package:gen_lang/extra_json_file_tool.dart';
import 'package:gen_lang/print_tool.dart';
import 'package:path/path.dart' as path;

/// Generates Android XML strings file content
String generateAndroidStringsXml(Map<String, String> strings) {
  StringBuffer buffer = StringBuffer();
  buffer.writeln('<?xml version="1.0" encoding="utf-8"?>');
  buffer.writeln('<!-- DO NOT EDIT. This is code generated via package:gen_lang/generate.dart -->');
  buffer.writeln('<resources>');

  for (MapEntry<String, String> entry in strings.entries) {
    String escapedValue = escapeXmlString(entry.value);
    buffer.writeln('    <string name="${entry.key}">$escapedValue</string>');
  }

  buffer.writeln('</resources>');
  return buffer.toString();
}

/// Escapes special characters for Android XML strings
String escapeXmlString(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '\\"')
      .replaceAll("'", "\\'")
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}

/// Converts locale string (e.g., "en", "zh_TW") to Android values directory name
String getAndroidValuesDir(String locale) {
  if (locale == 'en') {
    return 'values'; // Default locale
  }

  // Convert underscore to hyphen for Android (e.g., zh_TW -> zh-rTW)
  if (locale.contains('_')) {
    List<String> parts = locale.split('_');
    String lang = parts[0];
    String country = parts[1];
    return 'values-$lang-r$country';
  }

  return 'values-$locale';
}

/// Generates Android strings for all locales
Future<void> generateAndroidStrings(
  String androidDir,
  String androidFlavor,
  Map<String, FileSystemEntity> validFilesMap,
  Set<String> androidStringKeys,
) async {
  // Check if android directory exists
  String resPath = path.join(androidDir, 'app', 'src', androidFlavor, 'res');
  Directory resDir = Directory(resPath);

  if (!resDir.existsSync()) {
    printWarning('Android res directory not found: $resPath');
    printWarning('Skipping Android strings generation');
    return;
  }

  printInfo('Generating Android strings...');
  int generatedCount = 0;

  for (MapEntry<String, FileSystemEntity> entry in validFilesMap.entries) {
    String locale = entry.key;
    FileSystemEntity fileEntity = entry.value;

    // Parse JSON and extract only android_strings keys
    Map<String, Message> jsonKeyMap = await generateJsonKeyMessageMap(File(fileEntity.path));
    Map<String, String> androidStrings = {};

    for (String key in androidStringKeys) {
      if (jsonKeyMap.containsKey(key)) {
        Message message = jsonKeyMap[key]!;
        // Only simple messages are supported for Android
        if (message.messageKey.type == MessageType.message && message.message != null) {
          androidStrings[key] = message.message!;
        }
      }
    }

    if (androidStrings.isEmpty) {
      continue;
    }

    // Create values directory for locale
    String valuesDirName = getAndroidValuesDir(locale);
    String valuesDirPath = path.join(resPath, valuesDirName);
    Directory valuesDir = Directory(valuesDirPath);

    if (!valuesDir.existsSync()) {
      valuesDir.createSync(recursive: true);
      printInfo('Created directory: $valuesDirPath');
    }

    // Write generated_strings.xml
    String xmlFilePath = path.join(valuesDirPath, 'generated_strings.xml');
    File xmlFile = File(xmlFilePath);
    xmlFile.writeAsStringSync(generateAndroidStringsXml(androidStrings));

    printInfo('Generated: $xmlFilePath (${androidStrings.length} strings)');
    generatedCount++;
  }

  printInfo('Android strings generation completed: $generatedCount file(s)');
}

/// Reads android_strings.json and returns set of keys to generate
Future<Set<String>?> readAndroidStringsConfig(String sourceDir) async {
  String configPath = path.join(sourceDir, 'android_strings.json');
  File configFile = File(configPath);

  if (!configFile.existsSync()) {
    return null;
  }

  try {
    String content = await configFile.readAsString();
    dynamic config = jsonDecode(content);

    // android_strings.json should contain an array of string keys
    // Example: ["app_name", "welcome_message", "button_ok"]
    if (config is List) {
      return Set<String>.from(config);
    } else if (config is Map && config.containsKey('keys')) {
      return Set<String>.from(config['keys']);
    } else {
      printWarning('android_strings.json has invalid format. Expected array of strings or object with "keys" array');
      return null;
    }
  } catch (e) {
    printWarning('Failed to parse android_strings.json: $e');
    return null;
  }
}
