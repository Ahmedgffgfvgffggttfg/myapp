// اسم الملف: lib/screens/quran/surah_detail_screen.dart

import 'package:flutter/material.dart';
import '../../models/quran/surah_model.dart'; // <-- المسار الصحيح للملف

class SurahDetailScreen extends StatelessWidget {
  final Surah surah;

  const SurahDetailScreen({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final bool showBismillah = surah.number != 1 && surah.number != 9;

    return Scaffold(
      appBar: AppBar(
        title: Text(surah.name, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: surah.verses.length + (showBismillah ? 1 : 0),
        itemBuilder: (context, index) {
          if (showBismillah && index == 0) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Uthmani',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          final verseIndex = showBismillah ? index - 1 : index;
          final verse = surah.verses[verseIndex];
          
          final backgroundColor = verseIndex.isEven 
              ? primaryColor.withOpacity(0.05) 
              : Colors.transparent;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            color: backgroundColor,
            child: RichText(
              textAlign: TextAlign.right,
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Uthmani',
                  fontSize: 22,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  height: 1.8,
                ),
                children: [
                  TextSpan(text: verse.text),
                  TextSpan(
                    // --- عرض رقم الآية الصحيح ---
                    text: ' \uFD3F${verse.id}\uFD3E ',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

