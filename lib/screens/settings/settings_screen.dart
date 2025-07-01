// اسم الملف: lib/screens/settings/settings_screen.dart

import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // استخدام الخطوط والألوان من الثيم الرئيسي
    TextStyle defaultTextStyle = TextStyle(
        fontFamily:
            Theme.of(context).textTheme.bodyLarge?.fontFamily ?? 'Cairo');
    TextStyle pageTitleStyle = defaultTextStyle.copyWith(
      color:
          Theme.of(context).appBarTheme.titleTextStyle?.color ?? Colors.white,
      fontWeight: Theme.of(context).appBarTheme.titleTextStyle?.fontWeight ??
          FontWeight.bold,
      fontSize: Theme.of(context).appBarTheme.titleTextStyle?.fontSize ?? 20,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('الإعدادات', style: pageTitleStyle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'شاشة الإعدادات - سيتم بناؤها قريباً إن شاء الله',
            textAlign: TextAlign.center,
            style: defaultTextStyle.copyWith(fontSize: 18, color: Colors.grey[700]),
          ),
        ),
      ),
    );
  }
}

