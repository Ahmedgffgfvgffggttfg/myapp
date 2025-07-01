// اسم الملف: lib/screens/names_of_allah/name_details_screen.dart

import 'package:flutter/material.dart';
import '../../models/name_of_allah_model.dart';

class NameDetailsScreen extends StatelessWidget {
  final NameOfAllah nameOfAllah;

  const NameDetailsScreen({super.key, required this.nameOfAllah});

  @override
  Widget build(BuildContext context) {
    TextStyle pageTitleStyle = TextStyle(
      fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily ?? 'Cairo',
      color: Theme.of(context).appBarTheme.titleTextStyle?.color ?? Colors.white,
      fontWeight: Theme.of(context).appBarTheme.titleTextStyle?.fontWeight ?? FontWeight.bold,
      fontSize: Theme.of(context).appBarTheme.titleTextStyle?.fontSize ?? 20,
    );

    TextStyle detailsNameStyle = TextStyle(
      fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily ?? 'Cairo',
      fontSize: 36,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary,
    );

    TextStyle detailsTextStyle = TextStyle(
      fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily ?? 'Cairo',
      fontSize: 18,
      height: 1.8,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(nameOfAllah.name, style: pageTitleStyle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              nameOfAllah.name,
              textAlign: TextAlign.center,
              style: detailsNameStyle,
            ),
            const SizedBox(height: 20),
            Text(
              nameOfAllah.text,
              textAlign: TextAlign.justify,
              style: detailsTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}
