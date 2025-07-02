
// File: lib/main.dart
// this is a test
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'home_screen.dart'; 
import 'more_screen.dart';
import 'package:prayer_app/background_service.dart'; // استيراد خدمة الخلفية



class PrayerApp extends StatelessWidget {
  const PrayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color oliveGreenPrimary = Color(0xFF556B2F); 
    const Color beigeColor = Color(0xFFF5F5DC);     
    const Color whiteBackground = Colors.white;       

    return MaterialApp(
      title: 'مواقيت الصلاة',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [ Locale('ar', '') ],
      locale: const Locale('ar', ''),
      theme: ThemeData(
        primaryColor: oliveGreenPrimary,
        scaffoldBackgroundColor: whiteBackground,
        fontFamily: 'Cairo', 
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: MaterialColor( oliveGreenPrimary.value, const <int, Color>{ 50: Color(0xFFE9EBE3), 100: Color(0xFFC8CCC0), 200: Color(0xFFA5AB99), 300: Color(0xFF828A72), 400: Color(0xFF6A7356), 500: oliveGreenPrimary, 600: Color(0xFF4D622A), 700: Color(0xFF435724), 800: Color(0xFF3A4D1F), 900: Color(0xFF2A3B14), }, ),
          accentColor: oliveGreenPrimary.withOpacity(0.7), 
          brightness: Brightness.light,
        ).copyWith( secondary: oliveGreenPrimary.withOpacity(0.7) ),
        appBarTheme: const AppBarTheme(
          backgroundColor: oliveGreenPrimary,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 1,
          titleTextStyle: TextStyle( fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white, ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: oliveGreenPrimary,
          unselectedItemColor: Colors.grey[600],
          backgroundColor: Colors.white, 
          elevation: 2,
          selectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo'),
        ),
        cardTheme: CardThemeData( elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), color: beigeColor, margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0) ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: oliveGreenPrimary, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(10), ),
            textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w600)
          ),
        ),
        textTheme: const TextTheme( 
          bodyLarge: TextStyle(color: Color(0xFF333333), fontFamily: 'Cairo', fontSize: 16), 
          bodyMedium: TextStyle(color: Color(0xFF555555), fontFamily: 'Cairo', fontSize: 14), 
          titleLarge: TextStyle(color: oliveGreenPrimary, fontWeight: FontWeight.bold, fontFamily: 'Cairo'), 
          labelLarge: TextStyle(fontFamily: 'Cairo'), 
        ),
        iconTheme: IconThemeData( color: oliveGreenPrimary.withOpacity(0.8) ),
        listTileTheme: ListTileThemeData( iconColor: oliveGreenPrimary.withOpacity(0.8) )
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}
class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[ HomeScreen(), MoreScreen(), ];
  void _onItemTapped(int index) { setState(() { _selectedIndex = index; }); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center( child: _widgetOptions.elementAt(_selectedIndex), ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem( icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'الرئيسية', ),
          BottomNavigationBarItem( icon: Icon(Icons.more_horiz_outlined), activeIcon: Icon(Icons.more_horiz), label: 'المزيد', ),
        ],
        currentIndex: _selectedIndex, onTap: _onItemTapped, type: BottomNavigationBarType.fixed,
      ),
    );
  }
}