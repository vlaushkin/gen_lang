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
- `--android-dir`: Path to Android project directory (default: `android`)
- `--android-flavor`: Android build flavor (default: `main`)
- `--ios-dir`: Path to iOS project directory (default: `ios/Runner`)
- `--web-dir`: Path to Web locales directory (optional, no default - if not specified, Web generation is skipped)

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
├── generate_android_xml.dart  # Generates Android XML strings
├── generate_ios_strings.dart  # Generates iOS .strings files
├── generate_web_json.dart     # Generates Web JSON files with nested structure
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

## Native Platform Strings Generation

In addition to Dart code generation for Flutter, gen_lang can generate native string resources for Android and iOS platforms.

### Android Strings Generation

To generate Android XML strings, create an `android_strings.json` file in your source directory that lists which translation keys should be exported to native Android resources:

**Example `android_strings.json`:**
```json
[
  "app_name",
  "simpleMessage",
  "messageWithParams"
]
```

**Generated Output:**
- Files: `android/app/src/{flavor}/res/values*/generated_strings.xml`
- Format: Android XML resource files
- Location pattern:
  - `values/generated_strings.xml` (default locale: `en`)
  - `values-{lang}/generated_strings.xml` (language-specific)
  - `values-{lang}-r{COUNTRY}/generated_strings.xml` (region-specific, e.g., `values-zh-rTW`)

**Limitations:**
- Only simple message types are supported (no plural/gender messages)
- Messages with parameters (`${param}`) are included but parameters remain in Flutter format

**Implementation Details:**
- **Code**: `lib/generate_android_xml.dart`
- **Entry Point**: `core_18n.dart:253-277` (`_handleGenerateAndroidStrings`)
- **Escaping**: XML special characters (`&<>"'`) and escape sequences (`\n`, `\t`) are properly escaped

**Using in Android Studio:**

The generated files are automatically recognized by Android if placed correctly. No manual import needed!

1. **Verify files are generated** in `android/app/src/{flavor}/res/values*/generated_strings.xml`

2. **Sync Gradle** (if needed):
   - In Android Studio: File → Sync Project with Gradle Files

3. **Use in Kotlin Code**:
   ```kotlin
   // Access localized strings
   val message = getString(R.string.simpleMessage)
   val paramMessage = getString(R.string.messageWithParams)

   // For strings with parameters, use String formatting
   val formatted = String.format(paramMessage, "John")
   ```

4. **Use in Java**:
   ```java
   String message = getString(R.string.simpleMessage);
   String paramMessage = getString(R.string.messageWithParams);

   // For strings with parameters
   String formatted = String.format(paramMessage, "John");
   ```

5. **Use in XML layouts**:
   ```xml
   <TextView
       android:text="@string/simpleMessage"
       android:layout_width="wrap_content"
       android:layout_height="wrap_content" />
   ```

**Note**: The generated `generated_strings.xml` files are automatically merged with other string resources. Multiple `strings.xml` files in the same `values*` directory are combined by Android's build system.

**Re-generation**: Add generated files to `.gitignore` and regenerate as part of your build process, or regenerate manually when translations change.

### iOS Strings Generation

To generate iOS `.strings` files, create an `ios_strings.json` file in your source directory that lists which translation keys should be exported to native iOS resources:

**Example `ios_strings.json`:**
```json
[
  "app_name",
  "simpleMessage",
  "messageWithParams"
]
```

**Generated Output:**
- Files: `{ios-dir}/Resources/{locale}.lproj/Localizable.strings`
- Format: iOS `.strings` files
- Location pattern:
  - `en.lproj/Localizable.strings` (English)
  - `zh-TW.lproj/Localizable.strings` (region-specific)

**Limitations:**
- Only simple message types are supported (no plural/gender messages)
- Messages with parameters (`${param}`) are included but parameters remain in Flutter format

**Implementation Details:**
- **Code**: `lib/generate_ios_strings.dart`
- **Entry Point**: `core_18n.dart:288-310` (`_handleGenerateIosStrings`)
- **Escaping**: Special characters (`\"`, `\\`, `\n`, `\r`, `\t`) are properly escaped for iOS format
- **Locale Conversion**: Underscores in locale names are converted to hyphens (e.g., `zh_TW` → `zh-TW.lproj`)
- **Auto-creation**: The `Resources` directory is automatically created if it doesn't exist (requires the directory specified by `--ios-dir` to exist, default: `ios/Runner`)

**Using in Xcode:**

After generation, you need to add the files to your Xcode project:

1. **Open Xcode Project**:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Add .lproj folders to Xcode**:
   - In Xcode, right-click on the `Runner` folder in Project Navigator
   - Select "Add Files to Runner..."
   - Navigate to `{ios-dir}/Resources/` (default: `ios/Runner/Resources/`)
   - Select all `.lproj` folders (e.g., `en.lproj`, `zh-TW.lproj`)
   - **Important**: Check "Create folder references" (not "Create groups")
   - Click "Add"

3. **Configure Project Localizations** (if needed):
   - Select the project in Project Navigator
   - Go to the "Info" tab
   - Under "Localizations", click "+" to add languages
   - Add all languages you're supporting (en, zh-Hans, zh-Hant, etc.)

4. **Use in Swift Code**:
   ```swift
   // Access localized strings
   let message = NSLocalizedString("simpleMessage", comment: "")
   let paramMessage = NSLocalizedString("messageWithParams", comment: "")

   // For strings with parameters, use String formatting
   let formatted = String(format: paramMessage, "John")
   ```

5. **Use in Objective-C**:
   ```objc
   NSString *message = NSLocalizedString(@"simpleMessage", @"");
   NSString *paramMessage = NSLocalizedString(@"messageWithParams", @"");

   // For strings with parameters
   NSString *formatted = [NSString stringWithFormat:paramMessage, @"John"];
   ```

**Note**: The generated files use standard iOS `Localizable.strings` format, so they work seamlessly with `NSLocalizedString()` without any additional configuration.

**Re-generation**: Since files are auto-generated, you should add them to `.gitignore` and regenerate them as part of your build process, or regenerate manually when translations change.

### Web Strings Generation

To generate Web JSON files, create a `web_strings.json` file in your source directory that lists which translation keys should be exported to Web resources:

**Example `web_strings.json`:**
```json
[
  "web_sharing__app__name",
  "web_sharing__app__tagline",
  "web_sharing__loading__text",
  "web_sharing__preview__tasks"
]
```

**Key Naming Convention:**

Web keys use a special naming convention with double underscores (`__`) to create nested JSON structure:
- Single underscore (`_`): Converted from snake_case to camelCase within a segment
- Double underscore (`__`): Creates a new nesting level

**Examples:**
- `web_sharing__app__name` → `{"webSharing": {"app": {"name": "..."}}}`
- `web_sharing__loading__text` → `{"webSharing": {"loading": {"text": "..."}}}`
- `web_error__not_found__message` → `{"webError": {"notFound": {"message": "..."}}}`

**Generated Output:**
- Files: `{web-dir}/{locale}.json`
- Format: Nested JSON structure with camelCase keys
- Location pattern:
  - `en.json` (English)
  - `es.json` (Spanish)
  - `zh-TW.json` (region-specific, converted from `zh_TW`)

**Limitations:**
- Only simple message types are supported (no plural/gender messages)
- Messages with parameters (`${param}`) are included as-is

**Implementation Details:**
- **Code**: `lib/generate_web_json.dart`
- **Entry Point**: `core_18n.dart:321-348` (`_handleGenerateWebStrings`)
- **Key Parsing**: Splits by `__` for nesting, converts each segment from snake_case to camelCase
- **Locale Conversion**: Underscores in locale names are converted to hyphens (e.g., `zh_TW` → `zh-TW.json`)
- **Conditional Generation**: Only generates files if `--web-dir` parameter is specified and non-empty

**Using in Web Projects:**

The generated JSON files can be used with any i18n library (react-i18next, vue-i18n, etc.):

1. **React (react-i18next)**:
   ```javascript
   import en from './locales/en.json';
   import es from './locales/es.json';

   i18n.use(initReactI18next).init({
     resources: {
       en: { translation: en },
       es: { translation: es }
     },
     lng: 'en'
   });

   // Usage
   const { t } = useTranslation();
   t('webSharing.app.name'); // "Daily Habits"
   ```

2. **Vue (vue-i18n)**:
   ```javascript
   import en from './locales/en.json';
   import es from './locales/es.json';

   const i18n = createI18n({
     locale: 'en',
     messages: { en, es }
   });

   // Usage in template
   {{ $t('webSharing.app.name') }}
   ```

**Command-Line Usage:**
```bash
# Generate Web JSON files
dart run bin/generate.dart --web-dir=web/locales

# With other parameters
dart run bin/generate.dart \
  --source-dir=res/string \
  --web-dir=public/locales
```

**Note**: If `--web-dir` is not specified, Web generation is automatically skipped. The directory must exist before running the generator.

**Re-generation**: Add generated files to `.gitignore` and regenerate them as part of your build process, or regenerate manually when translations change.

### Configuration Files

All configuration files (`android_strings.json`, `ios_strings.json`, and `web_strings.json`):
- Are placed in the source directory (default: `res/string`)
- Are automatically excluded from locale file processing
- Support two formats:
  - Array of strings: `["key1", "key2"]`
  - Object with keys property: `{"keys": ["key1", "key2"]}`

If these files don't exist or are empty, their respective platform generation is skipped automatically. Additionally, for Web generation, the `--web-dir` parameter must be specified for generation to occur.

## Key Implementation Notes

- The tool does NOT validate that all locales have matching keys; missing translations in non-template locales will cause runtime errors
- Template locale (default: `en`) defines the canonical set of message keys
- Generated files include auto-generated headers and linter ignore comments
- The library has no formal test suite; validation occurs via the example app
- Null safety is enabled (SDK constraint: `>=2.12.0 <4.0.0`)