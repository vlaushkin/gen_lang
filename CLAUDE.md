# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

gen_lang is a Dart code generation library for Flutter internationalization (i18n). It parses JSON translation files and generates Dart code compatible with the Flutter Intl package. The tool reduces i18n to three steps: prepare JSON files, run gen_lang, and use the generated code.

## Commands

### Running the Generator
```bash
# From project root
dart run bin/generate.dart

# From example directory
cd example && dart run gen_lang:generate

# With custom options
dart run bin/generate.dart --source-dir=res/string --output-dir=lib/generated --template-locale=en
```

### Command-Line Arguments
- `--source-dir`: Source folder with JSON files (default: `res/string`)
- `--output-dir`: Output folder for generated files (default: `lib/generated`)
- `--template-locale`: Template locale for default values (default: `en`)

### Development
```bash
# Get dependencies
dart pub get

# Check for issues (no formal linter configured)
dart analyze

# Run example
cd example
flutter run
```

## Architecture

### Code Generation Flow

1. **Entry Point** (`bin/generate.dart`): Parses CLI arguments and delegates to core handler
2. **Core Logic** (`lib/core_18n.dart`): Main orchestration in `handleGenerateI18nFiles()`
   - Validates source directory exists
   - Discovers and validates JSON files (must match `string_{locale}.json` pattern)
   - Determines template locale (defaults to English or first available)
   - Generates two output files: `messages_all.dart` and `i18n.dart`

3. **JSON Processing** (`lib/extra_json_file_tool.dart`):
   - Parses JSON files into `Map<String, Message>` structures
   - Identifies message types by key suffixes:
     - Simple messages: no suffix
     - Plural messages: `Zero`, `One`, `Two`, `Few`, `Many`, `POther` suffixes
     - Gender messages: `Male`, `Female`, `GOther` suffixes
   - Extracts parameter placeholders (e.g., `${paramName}`) from message strings

4. **Code Generation**:
   - **i18n.dart** (`lib/generate_i18n_dart.dart`):
     - Creates `S` class with getter methods for each message key
     - Generates `GeneratedLocalizationsDelegate` with supported locales
     - Locales are auto-expanded (e.g., `en` becomes all `en_*` variants from `locale_info.dart:21-458`)
   - **messages_all.dart** (`lib/generate_message_all.dart`):
     - Creates `MessageLookupByLibrary` subclasses for each locale
     - Maps message keys to Intl function calls (`Intl.message`, `Intl.plural`, `Intl.gender`)

### Message Type System

Messages are classified into three types (see `lib/extra_json_file_tool.dart:46`):

- **Simple**: Single string, optionally with `${param}` placeholders
- **Plural**: Multiple keys with suffixes for plural forms; uses reserved `${howMany}` parameter
- **Gender**: Multiple keys with gender suffixes; uses reserved `${targetGender}` parameter

The `getMessageKey()` function (`lib/extra_json_file_tool.dart:207-254`) parses JSON keys to determine type and extract the base key name.

### Parameter Extraction

`lib/extra_json_message_tool.dart` uses regex (`ARG_REG_EXP = r'\${\w+}'`) to:
- Extract all `${paramName}` placeholders from messages
- Generate function signatures with appropriate parameters
- For plural/gender: automatically includes reserved parameters (`howMany`, `targetGender`)

### Locale Handling

The comprehensive locale list in `lib/locale_info.dart` (458 locale variants) ensures that specifying a language code like `en` in JSON files automatically adds all regional variants (en_US, en_GB, etc.) to the generated `supportedLocales`. This happens in `core_18n.dart:227-230`.

### Special Character Handling

Messages with special characters (quotes, backslashes, newlines) are normalized in `extra_json_message_tool.dart:21-27` to ensure proper escaping in generated Dart code.

## File Structure

```
lib/
├── core_18n.dart              # Main generation orchestration
├── extra_json_file_tool.dart  # JSON parsing and message type detection
├── extra_json_message_tool.dart # Parameter extraction and string utilities
├── generate_i18n_dart.dart    # Generates i18n.dart (S class and delegate)
├── generate_message_all.dart  # Generates messages_all.dart (message lookups)
├── locale_info.dart           # Comprehensive locale database
└── print_tool.dart            # Console output utilities

bin/
└── generate.dart              # CLI entry point

example/
├── res/string/                # Sample JSON files (string_en.json, etc.)
└── lib/generated/             # Generated output (i18n.dart, messages_all.dart)
```

## Input File Format

JSON files must be named `string_{locale}.json` (e.g., `string_en.json`, `string_zh_TW.json`) and placed in the source directory.

Example JSON structure:
```json
{
  "simpleMessage": "Hello World",
  "messageWithParams": "Hi ${userName}, welcome!",
  "pluralMessageOne": "You have one item",
  "pluralMessagePOther": "You have ${howMany} items",
  "genderMessageMale": "He is ${name}",
  "genderMessageFemale": "She is ${name}",
  "genderMessageGOther": "They are ${name}"
}
```

## Generated Code Usage

After generation, integrate in Flutter app:
```dart
import 'package:your_app/generated/i18n.dart';

MaterialApp(
  localizationsDelegates: [
    S.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate
  ],
  supportedLocales: S.delegate.supportedLocales,
  // ... rest of app
)

// Access messages
S.of(context).simpleMessage
S.of(context).messageWithParams('John')
S.of(context).pluralMessage(5, 'arg2')
S.of(context).genderMessage('female', 'Jane')
```

## Key Implementation Notes

- The tool does NOT validate that all locales have matching keys; missing translations in non-template locales will cause runtime errors
- Template locale (default: `en`) defines the canonical set of message keys
- Generated files include auto-generated headers and linter ignore comments
- The library has no formal test suite; validation occurs via the example app
- Null safety is enabled (SDK constraint: `>=2.12.0 <4.0.0`)