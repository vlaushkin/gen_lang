// DO NOT EDIT. This is code generated via package:gen_lang/generate.dart

import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'messages_all.dart';

class S {
 
  static const GeneratedLocalizationsDelegate delegate = GeneratedLocalizationsDelegate();

  static S of(BuildContext context) {
    final localization = Localizations.of<S>(context, S);
    
    assert(() {
      if (localization == null) {
        throw FlutterError(
            'S requested with a context that does not include S.');
      }
      return true;
    }());
    
    return localization!;
  }
  
  static Future<S> load(Locale locale) {
    final String name = locale.countryCode == null ? locale.languageCode : locale.toString();

    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return new S();
    });
  }
  
  String genderMessage(targetGender, name) {
    return Intl.gender(targetGender,
        male: "Hi ${name}, He is boy.",
        female: "Hi ${name}, She is girl.",
        other: "Hi ${name}, he/she is boy/girl.",
        name: 'genderMessage',
        args: [targetGender, name]);
  }

  String get locale {
    return Intl.message("English", name: 'locale');
  }

  String messageWithParams(yourName) {
    return Intl.message("Hi ${yourName}, Welcome you!", name: 'messageWithParams', args: [yourName]);
  }

  String pluralMessage(howMany, interviewerName) {
    return Intl.plural(howMany,
        zero: null,
        one: "Hi ${interviewerName}, I have one year working experience.",
        two: null,
        few: null,
        many: null,
        other: "Hi ${interviewerName}, I have ${howMany} years of working experience.",
        name: 'pluralMessage',
        args: [howMany, interviewerName]);
  }

  String get simpleMessage {
    return Intl.message("This is a simple Message", name: 'simpleMessage');
  }

  String get specialCharactersMessage {
    return Intl.message("Special Characters Nice Developer's \"Message\"\n Next Line", name: 'specialCharactersMessage');
  }


}

class GeneratedLocalizationsDelegate extends LocalizationsDelegate<S> {
  const GeneratedLocalizationsDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
			Locale("en", ""),
			Locale("ja", ""),
			Locale("zh", "TW"),
			Locale("es", ""),
			Locale("en", "001"),
			Locale("en", "150"),
			Locale("en", "AG"),
			Locale("en", "AI"),
			Locale("en", "AS"),
			Locale("en", "AU"),
			Locale("en", "BB"),
			Locale("en", "BE"),
			Locale("en", "BM"),
			Locale("en", "BS"),
			Locale("en", "BW"),
			Locale("en", "BZ"),
			Locale("en", "CA"),
			Locale("en", "CC"),
			Locale("en", "CK"),
			Locale("en", "CM"),
			Locale("en", "CX"),
			Locale("en", "DG"),
			Locale("en", "DM"),
			Locale("en", "ER"),
			Locale("en", "FJ"),
			Locale("en", "FK"),
			Locale("en", "FM"),
			Locale("en", "GB"),
			Locale("en", "GD"),
			Locale("en", "GG"),
			Locale("en", "GH"),
			Locale("en", "GI"),
			Locale("en", "GM"),
			Locale("en", "GU"),
			Locale("en", "GY"),
			Locale("en", "HK"),
			Locale("en", "IE"),
			Locale("en", "IM"),
			Locale("en", "IN"),
			Locale("en", "IO"),
			Locale("en", "JE"),
			Locale("en", "JM"),
			Locale("en", "KE"),
			Locale("en", "KI"),
			Locale("en", "KN"),
			Locale("en", "KY"),
			Locale("en", "LC"),
			Locale("en", "LR"),
			Locale("en", "LS"),
			Locale("en", "MG"),
			Locale("en", "MH"),
			Locale("en", "MO"),
			Locale("en", "MP"),
			Locale("en", "MS"),
			Locale("en", "MT"),
			Locale("en", "MU"),
			Locale("en", "MW"),
			Locale("en", "NA"),
			Locale("en", "NF"),
			Locale("en", "NG"),
			Locale("en", "NR"),
			Locale("en", "NU"),
			Locale("en", "NZ"),
			Locale("en", "PG"),
			Locale("en", "PH"),
			Locale("en", "PK"),
			Locale("en", "PN"),
			Locale("en", "PR"),
			Locale("en", "PW"),
			Locale("en", "RW"),
			Locale("en", "SB"),
			Locale("en", "SC"),
			Locale("en", "SD"),
			Locale("en", "SG"),
			Locale("en", "SH"),
			Locale("en", "SL"),
			Locale("en", "SS"),
			Locale("en", "SX"),
			Locale("en", "SZ"),
			Locale("en", "TC"),
			Locale("en", "TK"),
			Locale("en", "TO"),
			Locale("en", "TT"),
			Locale("en", "TV"),
			Locale("en", "TZ"),
			Locale("en", "UG"),
			Locale("en", "UM"),
			Locale("en", "US"),
			Locale("en", "VC"),
			Locale("en", "VG"),
			Locale("en", "VI"),
			Locale("en", "VU"),
			Locale("en", "WS"),
			Locale("en", "ZA"),
			Locale("en", "ZM"),
			Locale("en", "ZW"),
			Locale("es", "419"),
			Locale("es", "AR"),
			Locale("es", "BO"),
			Locale("es", "CL"),
			Locale("es", "CO"),
			Locale("es", "CR"),
			Locale("es", "CU"),
			Locale("es", "DO"),
			Locale("es", "EA"),
			Locale("es", "EC"),
			Locale("es", "ES"),
			Locale("es", "GQ"),
			Locale("es", "GT"),
			Locale("es", "HN"),
			Locale("es", "IC"),
			Locale("es", "MX"),
			Locale("es", "NI"),
			Locale("es", "PA"),
			Locale("es", "PE"),
			Locale("es", "PH"),
			Locale("es", "PR"),
			Locale("es", "PY"),
			Locale("es", "SV"),
			Locale("es", "US"),
			Locale("es", "UY"),
			Locale("es", "VE"),
			Locale("ja", "JP"),

    ];
  }

  LocaleListResolutionCallback listResolution({Locale? fallback}) {
    return (List<Locale>? locales, Iterable<Locale> supported) {
      if (locales == null || locales.isEmpty) {
        return fallback ?? supported.first;
      } else {
        return _resolve(locales.first, fallback, supported);
      }
    };
  }

  LocaleResolutionCallback resolution({Locale? fallback}) {
    return (Locale? locale, Iterable<Locale> supported) {
      return _resolve(locale, fallback, supported);
    };
  }

  Locale _resolve(Locale? locale, Locale? fallback, Iterable<Locale> supported) {
    if (locale == null || !isSupported(locale)) {
      return fallback ?? supported.first;
    }

    final Locale languageLocale = Locale(locale.languageCode, "");
    if (supported.contains(locale)) {
      return locale;
    } else if (supported.contains(languageLocale)) {
      return languageLocale;
    } else {
      final Locale fallbackLocale = fallback ?? supported.first;
      return fallbackLocale;
    }
  }

  @override
  Future<S> load(Locale locale) {
    return S.load(locale);
  }

  @override
  bool isSupported(Locale? locale) =>
    locale != null && supportedLocales.contains(locale);

  @override
  bool shouldReload(GeneratedLocalizationsDelegate old) => false;
}

// ignore_for_file: unnecessary_brace_in_string_interps
