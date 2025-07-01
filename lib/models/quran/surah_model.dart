// اسم الملف: lib/models/quran/surah_model.dart
// نسخة نهائية مع تصحيح قراءة رقم السورة ونوعها

import 'dart:convert';
import 'package:flutter/foundation.dart';

// دالة مساعدة لتحميل وفك تشفير ملف JSON في الخلفية
// سيتم استدعاؤها بواسطة compute لتجنب تجميد الواجهة
List<Surah> parseSurahs(String jsonString) {
  final List<dynamic> surahListJson = json.decode(jsonString);
  return surahListJson.map((json) => Surah.fromJson(json)).toList();
}

class Surah {
  final int number;
  final String name;
  final String transliteration;
  final String type; // نوع السورة (مكية أو مدنية)
  final int totalVerses;
  final List<Verse> verses;

  Surah({
    required this.number,
    required this.name,
    required this.transliteration,
    required this.type,
    required this.totalVerses,
    required this.verses,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    var versesList = json['verses'] as List? ?? [];
    List<Verse> verses = versesList.map((i) => Verse.fromJson(i)).toList();

    return Surah(
      // --- تم تصحيح هذا الجزء بالكامل ---
      number: json['number'] ?? 0,
      name: json['name'] ?? 'غير معروف',
      transliteration: json['transliteration'] ?? '',
      type: json['type'] ?? 'Makkiyah', // قيمة افتراضية
      totalVerses: json['total_verses'] ?? 0,
      verses: verses,
    );
  }
}

class Verse {
  final int id;
  final String text;

  Verse({
    required this.id,
    required this.text,
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      id: json['id'] ?? 0,
      text: json['text'] ?? '',
    );
  }
}

