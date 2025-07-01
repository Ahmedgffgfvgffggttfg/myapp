// اسم الملف: lib/more_screen.dart
// النسخة النهائية بعد إضافة ميزة المسبحة الإلكترونية

import 'package:flutter/material.dart';
import 'screens/questions_competition/questions_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/azkar/azkar_screen.dart';
import 'screens/qibla/qibla_screen.dart';
import 'screens/quran/quran_screen.dart';
import 'screens/audio_quran/reciters_screen.dart';
import 'screens/tasbih/tasbih_screen.dart';
import 'screens/names_of_allah/names_of_allah_screen.dart';

class MoreGridItem {
  final String title;
  final IconData icon;
  final VoidCallback onTapAction;
  MoreGridItem(
      {required this.title, required this.icon, required this.onTapAction});
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
    Color iconColor = Theme.of(context).colorScheme.secondary;
    Color cardBackgroundColor =
        Theme.of(context).cardTheme.color ?? Colors.white;

    // قائمة العناصر التي تظهر في الشبكة
    final List<MoreGridItem> gridItems = [
      MoreGridItem(
        title: 'القرآن الكريم',
        icon: Icons.menu_book_rounded,
        onTapAction: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QuranScreen()),
          );
        },
      ),
      MoreGridItem(
        title: 'القرآن الصوتي',
        icon: Icons.headset_rounded,
        onTapAction: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RecitersScreen()),
          );
        },
      ),
      MoreGridItem(
        title: 'الأذكار',
        icon: Icons.book_outlined,
        onTapAction: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AzkarScreen()),
          );
        },
      ),
       MoreGridItem(
        title: 'أسماء الله الحسنى',
        icon: Icons.brightness_high,
        onTapAction: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NamesOfAllahScreen()),
          );
        },
      ),
      MoreGridItem(
        title: 'اتجاه القبلة',
        icon: Icons.explore_outlined,
        onTapAction: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QiblaScreen()),
          );
        },
      ),
       MoreGridItem(
        title: 'المسبحة', // <-- تم إضافة العنصر الجديد هنا
        icon: Icons.fingerprint,
        onTapAction: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TasbihScreen()),
          );
        },
      ),
       MoreGridItem(
        title: 'لعبة الأسئلة',
        icon: Icons.lightbulb_outline,
        onTapAction: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QuestionsScreen()),
          );
        },
      ),
      MoreGridItem(
        title: 'الإعدادات',
        icon: Icons.settings_outlined,
        onTapAction: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('المزيد', style: pageTitleStyle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: gridItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            final item = gridItems[index];
            return _buildGridCard(context, item.title, item.icon,
                item.onTapAction, defaultTextStyle, iconColor, cardBackgroundColor);
          },
        ),
      ),
    );
  }

  Widget _buildGridCard(
      BuildContext context,
      String title,
      IconData icon,
      VoidCallback onTapAction,
      TextStyle textStyle,
      Color iconColor,
      Color cardBackgroundColor) {
    return Card(
      color: cardBackgroundColor,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTapAction,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 38, color: iconColor),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: textStyle.copyWith(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
