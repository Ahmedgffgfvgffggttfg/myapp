// اسم الملف: lib/home_screen.dart
// النسخة النهائية المصححة لتتوافق مع تحديثات الحزم

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<String, String> _currentDayPrayerTimes = {
    "Fajr": "--:--", "Sunrise": "--:--", "Dhuhr": "--:--",
    "Asr": "--:--", "Maghrib": "--:--", "Isha": "--:--",
  };
  String _currentHijriDateForDisplay = "";
  bool _isLoading = true;
  String _errorMessage = "";
  bool _needsNetworkToFetch = false;
  
  String _nextPrayerName = "";
  DateTime? _nextPrayerDateTime;
  Timer? _timer;
  String _countdownString = "--:--:--";

  Map<String, Map<String, String>> _savedMonthTimings = {};
  Map<String, String> _savedMonthHijriDates = {};
  String _savedDataForMonthYear = ""; 

  // --- تم تعديل هذا الجزء ---
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isCurrentlyConnected = true; 

  final Map<String, String> _prayerNamesArabic = {
    "Fajr": "الفجر", "Sunrise": "الشروق", "Dhuhr": "الظهر",
    "Asr": "العصر", "Maghrib": "المغرب", "Isha": "العشاء",
  };
  final Map<String, IconData> _prayerIcons = {
    "Fajr": Icons.brightness_4_outlined, "Sunrise": Icons.wb_sunny_outlined,
    "Dhuhr": Icons.wb_sunny, "Asr": Icons.cloud_outlined,
    "Maghrib": Icons.brightness_6_outlined, "Isha": Icons.nights_stay_outlined,
  };
  final List<String> _prayerKeysRow = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];

  static const String _prefKeySavedMonthTimings = 'month_timings_data_v3';
  static const String _prefKeySavedMonthHijri = 'month_hijri_data_v3';
  static const String _prefKeySavedForMonthYear = 'saved_for_month_year_v3';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ar', null).then((_) {
      _initializeConnectivityListener(); 
      _initializeAndLoadData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _connectivitySubscription?.cancel(); 
    super.dispose();
  }

  // --- تم تعديل هذه الدالة بالكامل ---
  void _initializeConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      bool wasConnected = _isCurrentlyConnected;
      if (results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi)) {
        _isCurrentlyConnected = true;
      } else {
        _isCurrentlyConnected = false;
      }
      // إذا عاد الاتصال وكانت هناك حاجة لجلب البيانات، قم بالمحاولة
      if (_isCurrentlyConnected && !wasConnected && _needsNetworkToFetch) {
        _fetchCurrentMonthDataFromServer(showErrorIfNotAvailable: true);
      }
    });
  }

  Future<void> _initializeAndLoadData() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _errorMessage = ""; _needsNetworkToFetch = false; });
    
    bool dataLoadedForToday = await _loadMonthDataAndDisplayToday();

    if (!dataLoadedForToday) {
      await _fetchCurrentMonthDataFromServer(showErrorIfNotAvailable: true);
    }
  }
  
  String _cleanTime(String timeWithExtra) { return timeWithExtra.split(' ')[0]; }

  String _formatTimeForDisplay(String time24) {
    try {
      final cleanTime = _cleanTime(time24);
      final parts = cleanTime.split(':');
      if (parts.length != 2) return cleanTime;
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) return cleanTime;
      final timeOfDay = TimeOfDay(hour: hour, minute: minute);
      return DateFormat.jm('ar').format(DateTime(2000, 1, 1, timeOfDay.hour, timeOfDay.minute));
    } catch (e) { return time24; }
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled; LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) { if (mounted) setState(() { _errorMessage = 'خدمات الموقع غير مفعلة.'; _isLoading = false; _needsNetworkToFetch = true; }); return null; }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) { if (mounted) setState(() { _errorMessage = 'تم رفض إذن الموقع.'; _isLoading = false; _needsNetworkToFetch = true; }); return null; }
    }
    if (permission == LocationPermission.deniedForever) { if (mounted) setState(() { _errorMessage = 'تم رفض إذن الموقع بشكل دائم.'; _isLoading = false; _needsNetworkToFetch = true; }); return null; }
    return await Geolocator.getCurrentPosition();
  }

  // --- تم تعديل هذه الدالة ---
  Future<void> _fetchCurrentMonthDataFromServer({bool showErrorIfNotAvailable = false}) async {
    if (!mounted) return;
    // التحقق من الاتصال
    var connectivityResult = await Connectivity().checkConnectivity();
    if (!connectivityResult.contains(ConnectivityResult.mobile) && !connectivityResult.contains(ConnectivityResult.wifi)) {
        if (mounted) {
            setState(() {
                _isLoading = false;
                if (_savedMonthTimings.isEmpty) {
                     _errorMessage = 'لا توجد بيانات محفوظة. يرجى الاتصال بالإنترنت.';
                } else {
                     _errorMessage = 'لا يوجد اتصال بالإنترنت لتحديث البيانات.';
                }
                _needsNetworkToFetch = true; 
            });
        }
        return;
    }

    setState(() { _isLoading = true; _errorMessage = ""; _needsNetworkToFetch = false; });
    try {
      Position? position = await _determinePosition();
      if (position == null) { return; }

      DateTime now = DateTime.now();
      final url = Uri.parse('https://api.aladhan.com/v1/calendar?latitude=${position.latitude}&longitude=${position.longitude}&method=4&month=${now.month}&year=${now.year}');
      final response = await http.get(url).timeout(const Duration(seconds: 20));

      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200 && data['data'] is List) {
          Map<String, Map<String, String>> tempMonthTimings = {};
          Map<String, String> tempMonthHijriDates = {};
          List<dynamic> monthDataList = data['data'];
          for (var dayData in monthDataList) {
            if (dayData is Map && dayData.containsKey('timings') && dayData.containsKey('date')) {
              Map<String, dynamic> timings = dayData['timings'];
              Map<String, dynamic> dateInfo = dayData['date'];
              String gregorianDateStr = "${dateInfo['gregorian']['year']}-${dateInfo['gregorian']['month']['number'].toString().padLeft(2, '0')}-${dateInfo['gregorian']['day'].toString().padLeft(2, '0')}";
              Map<String, String> dayTimingsCleaned = {};
              timings.forEach((key, value) { if (value is String) dayTimingsCleaned[key] = _cleanTime(value); });
              tempMonthTimings[gregorianDateStr] = dayTimingsCleaned;
              if (dateInfo.containsKey('hijri')) {
                Map<String, dynamic> hijriInfo = dateInfo['hijri'];
                tempMonthHijriDates[gregorianDateStr] = "${hijriInfo['day']} ${hijriInfo['month']['ar']} ${hijriInfo['year']}";
              }
            }
          }
          _savedMonthTimings = tempMonthTimings;
          _savedMonthHijriDates = tempMonthHijriDates;
          _savedDataForMonthYear = DateFormat('yyyy-MM').format(now);
          await _saveMonthDataToPrefs();
          _updateUIDayTimings(DateTime.now());
          if (mounted) setState(() { _isLoading = false; _errorMessage = ""; _needsNetworkToFetch = false;});
        } else { throw Exception('API error: ${data['status']}'); }
      } else { throw Exception('Failed to load for month ${now.month}. Status: ${response.statusCode}'); }
    } on TimeoutException catch (_) {
        if (mounted) setState(() { _isLoading = false; _errorMessage = 'انتهت مهلة الاتصال بالخادم.'; _needsNetworkToFetch = true;});
    } catch (e) {
      if (mounted) {
        String errorMsg = 'خطأ: ${e.toString().split(':').first.trim()}';
        if (e.toString().toLowerCase().contains('failed host lookup') || e.toString().toLowerCase().contains('socketexception')) {
            errorMsg = 'لا يوجد اتصال بالإنترنت لجلب بيانات الشهر الحالي.';
        }
        setState(() { _isLoading = false; _errorMessage = errorMsg; _needsNetworkToFetch = true;});
      }
    }
  }
  
  void _updateUIDayTimings(DateTime date) {
    if (!mounted) return;
    String dateKey = DateFormat('yyyy-MM-dd').format(date);
    if (_savedMonthTimings.containsKey(dateKey) && _savedMonthHijriDates.containsKey(dateKey)) {
      Map<String, String> todayRawTimings = _savedMonthTimings[dateKey]!;
      setState(() {
        _currentDayPrayerTimes["Fajr"] = _formatTimeForDisplay(todayRawTimings['Fajr'] ?? "--:--");
        _currentDayPrayerTimes["Sunrise"] = _formatTimeForDisplay(todayRawTimings['Sunrise'] ?? "--:--");
        _currentDayPrayerTimes["Dhuhr"] = _formatTimeForDisplay(todayRawTimings['Dhuhr'] ?? "--:--");
        _currentDayPrayerTimes["Asr"] = _formatTimeForDisplay(todayRawTimings['Asr'] ?? "--:--");
        _currentDayPrayerTimes["Maghrib"] = _formatTimeForDisplay(todayRawTimings['Maghrib'] ?? "--:--");
        _currentDayPrayerTimes["Isha"] = _formatTimeForDisplay(todayRawTimings['Isha'] ?? "--:--");
        _currentHijriDateForDisplay = _savedMonthHijriDates[dateKey]!;
        _determineNextPrayer(todayRawTimings);
        _isLoading = false; 
        _errorMessage = ""; 
        _needsNetworkToFetch = false; 
      });
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false; 
          if (_savedMonthTimings.isEmpty) {
             _errorMessage = 'لا توجد بيانات محفوظة. يرجى الاتصال بالإنترنت.';
          } else { 
             _errorMessage = 'لا توجد بيانات محفوظة للشهر الحالي. يرجى الاتصال بالإنترنت.';
          }
          _needsNetworkToFetch = true;
        });
      }
    }
  }

  Future<void> _saveMonthDataToPrefs() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeySavedForMonthYear, _savedDataForMonthYear);
    await prefs.setString(_prefKeySavedMonthTimings, json.encode(_savedMonthTimings));
    await prefs.setString(_prefKeySavedMonthHijri, json.encode(_savedMonthHijriDates));
  }

  Future<bool> _loadMonthDataAndDisplayToday() async {
    if (!mounted) return false;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String currentMonthYearKey = DateFormat('yyyy-MM').format(DateTime.now());

      final String? savedMonthYear = prefs.getString(_prefKeySavedForMonthYear);
      if (savedMonthYear != currentMonthYearKey) {
        if (mounted) setState(() => _needsNetworkToFetch = true);
        return false;
      }

      final String? timingsJson = prefs.getString(_prefKeySavedMonthTimings);
      final String? hijriJson = prefs.getString(_prefKeySavedMonthHijri);
      if (timingsJson == null || hijriJson == null) {
        if (mounted) setState(() => _needsNetworkToFetch = true);
        return false;
      }

      Map<String, dynamic> decodedTimingsDynamic = json.decode(timingsJson);
      _savedMonthTimings = decodedTimingsDynamic.map((key, value) => MapEntry(key, Map<String, String>.from(value)));
      Map<String, dynamic> decodedHijriDynamic = json.decode(hijriJson);
      _savedMonthHijriDates = decodedHijriDynamic.map((key, value) => MapEntry(key, value.toString()));
      
      _updateUIDayTimings(DateTime.now());
      return true;

    } catch (e) {
      if (mounted) setState(() => _needsNetworkToFetch = true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefKeySavedMonthTimings);
      await prefs.remove(_prefKeySavedMonthHijri);
      await prefs.remove(_prefKeySavedForMonthYear);
      return false;
    }
  }

  void _determineNextPrayer(Map<String, String> todayRawTimings) {
     _timer?.cancel(); 
    final now = DateTime.now();
    DateTime nextPrayerDT = DateTime(now.year + 10);
    String currentNextPrayerNameKey = "";

    for (String prayerKey in ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"]) {
      if (todayRawTimings.containsKey(prayerKey) && todayRawTimings[prayerKey] is String) { 
        String timeString = _cleanTime(todayRawTimings[prayerKey]!); 
        try {
          int hour = int.parse(timeString.split(':')[0]);
          int minute = int.parse(timeString.split(':')[1]);
          DateTime prayerTimeToday = DateTime(now.year, now.month, now.day, hour, minute);
          if (prayerTimeToday.isAfter(now) && prayerTimeToday.isBefore(nextPrayerDT)) {
            nextPrayerDT = prayerTimeToday;
            currentNextPrayerNameKey = prayerKey;
          }
        } catch (e) { /* ignore */ }
      }
    }

    if (currentNextPrayerNameKey.isEmpty && todayRawTimings.containsKey("Fajr") && todayRawTimings["Fajr"] is String) {
      String fajrTimeString = _cleanTime(todayRawTimings["Fajr"]!);
       try {
        int fajrHour = int.parse(fajrTimeString.split(':')[0]);
        int fajrMinute = int.parse(fajrTimeString.split(':')[1]);
        nextPrayerDT = DateTime(now.year, now.month, now.day + 1, fajrHour, fajrMinute);
        currentNextPrayerNameKey = "Fajr";
      } catch (e) { /* ignore */ }
    }

    if (currentNextPrayerNameKey.isNotEmpty) {
      if (mounted) {
        setState(() {
          _nextPrayerName = _prayerNamesArabic[currentNextPrayerNameKey] ?? currentNextPrayerNameKey;
          _nextPrayerDateTime = nextPrayerDT;
        });
      }
      _startCountdown();
    } else {
      if (mounted) {
        setState(() { _nextPrayerName = ""; _nextPrayerDateTime = null; _countdownString = "--:--:--"; });
      }
    }
  }

  void _startCountdown() {
      _timer?.cancel(); 
    if (_nextPrayerDateTime == null || !mounted) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_nextPrayerDateTime == null || !mounted) { timer.cancel(); return; }
      final now = DateTime.now();
      final difference = _nextPrayerDateTime!.difference(now);
      if (difference.isNegative || difference.inSeconds <= 0) {
        if (mounted) setState(() { _countdownString = "00:00:00"; });
        timer.cancel();
        _initializeAndLoadData();
      } else {
        if (mounted) {
          setState(() {
            _countdownString = 
                "${difference.inHours.toString().padLeft(2, '0')}:"
                "${(difference.inMinutes % 60).toString().padLeft(2, '0')}:"
                "${(difference.inSeconds % 60).toString().padLeft(2, '0')}";
          });
        }
      }
    });
  }

  Future<void> _handleRefresh() async {
    await _fetchCurrentMonthDataFromServer(showErrorIfNotAvailable: true); 
  }

 @override
  Widget build(BuildContext context) {
    Color beigeCardColor = Theme.of(context).cardTheme.color ?? const Color(0xFFF5F5DC);
    Color primaryTextColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
    Color accentColor = Theme.of(context).colorScheme.secondary; 

    TextStyle defaultTextStyle = TextStyle(fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily ?? 'Cairo');


    return Scaffold(
      appBar: AppBar( title: Text("مواقيت الصلاة", style: defaultTextStyle.copyWith(color: Colors.white, fontWeight: FontWeight.bold)) ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: Theme.of(context).primaryColor,
          child: _isLoading
              ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)))
              : _errorMessage.isNotEmpty
                  ? _buildErrorView()
                  : ListView(
                      children: [
                        _buildTopPrayerInfoCard(beigeCardColor, primaryTextColor, accentColor, defaultTextStyle),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    TextStyle errorTextStyle = TextStyle(fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily ?? 'Cairo', fontSize: 17, color: Colors.red[700], fontWeight: FontWeight.w500);
    return Center( 
       child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Theme.of(context).primaryColor, size: 50),
            const SizedBox(height: 10),
            Text(
              _errorMessage, 
              textAlign: TextAlign.center, 
              style: errorTextStyle
            ),
            const SizedBox(height: 20),
            if (_errorMessage.isNotEmpty) 
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: Text("إعادة المحاولة", style: TextStyle(fontFamily: Theme.of(context).elevatedButtonTheme.style?.textStyle?.resolve({})?.fontFamily ?? 'Cairo')),
                onPressed: _handleRefresh, 
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPrayerInfoCard(Color cardBackgroundColor, Color primaryTextColor, Color accentColor, TextStyle defaultTextStyle) {
    String nextPrayerTimeFormatted = _nextPrayerDateTime != null 
                                    ? DateFormat.jm('ar').format(_nextPrayerDateTime!) 
                                    : "--:--";
    
    return Card(
      margin: const EdgeInsets.all(12.0),
      color: cardBackgroundColor, 
      elevation: 4.0, 
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            if (_nextPrayerName.isNotEmpty) ...[
              Text(_nextPrayerName, style: defaultTextStyle.copyWith(fontSize: 28, fontWeight: FontWeight.bold, color: accentColor)),
              Text(nextPrayerTimeFormatted, style: defaultTextStyle.copyWith(fontSize: 48, fontWeight: FontWeight.w300, color: primaryTextColor)),
            ],
            const SizedBox(height: 8),

            Text(
              _countdownString, 
              style: defaultTextStyle.copyWith(fontSize: 24, color: primaryTextColor, letterSpacing: 2.0, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Text(_currentHijriDateForDisplay, style: defaultTextStyle.copyWith(fontSize: 16, color: primaryTextColor.withOpacity(0.85), fontWeight: FontWeight.w600)),
            const SizedBox(height: 25),

            _buildPrayerTimesRow(primaryTextColor, accentColor, defaultTextStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimesRow(Color textColor, Color highlightColor, TextStyle defaultTextStyle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _prayerKeysRow.map((key) {
        bool isNext = (_prayerNamesArabic[key] == _nextPrayerName);
        return _buildSinglePrayerTimeItem(
          _prayerNamesArabic[key]!,
          _currentDayPrayerTimes[key]!, 
          _prayerIcons[key]!,
          isNext,
          textColor,
          highlightColor,
          defaultTextStyle
        );
      }).toList(),
    );
  }

  Widget _buildSinglePrayerTimeItem(String name, String time, IconData icon, bool isNext, Color textColor, Color highlightColor, TextStyle defaultTextStyle) {
    Color colorToUse = isNext ? highlightColor : textColor.withOpacity(0.7);
    FontWeight weightToUse = isNext ? FontWeight.bold : FontWeight.normal;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(name, style: defaultTextStyle.copyWith(fontSize: 13, color: colorToUse, fontWeight: weightToUse)),
        const SizedBox(height: 5),
        Icon(icon, color: colorToUse, size: 20),
        const SizedBox(height: 3),
        Text(time, style: defaultTextStyle.copyWith(fontSize: 13, color: colorToUse, fontWeight: weightToUse)),
      ],
    );
  }
}
