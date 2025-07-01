// اسم الملف: lib/screens/audio_quran/audio_surahs_screen.dart
// نسخة نهائية مع إصلاح كامل لمنطق تشغيل الصوت وتحديث الواجهة

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/audio_quran/reciter_model.dart';
import '../../models/surah_names.dart';

class AudioSurahsScreen extends StatefulWidget {
  final Reciter reciter;

  const AudioSurahsScreen({super.key, required this.reciter});

  @override
  State<AudioSurahsScreen> createState() => _AudioSurahsScreenState();
}

class _AudioSurahsScreenState extends State<AudioSurahsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  int? _playingIndex;
  int? _loadingIndex; // لتتبع السورة التي يتم تحميلها
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    // الاستماع لتغيرات حالة المشغل
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
          // إذا توقف التشغيل، قم بإخفاء دائرة التحميل
          if (state == PlayerState.playing || state == PlayerState.paused) {
            _loadingIndex = null;
          }
        });
      }
    });

    // الاستماع لمدة المقطع الصوتي
    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });

    // الاستماع لموضع التشغيل الحالي
    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });

    // عند انتهاء تشغيل السورة
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _playingIndex = null;
          _position = Duration.zero;
          _duration = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // --- دالة التشغيل الجديدة والمحسنة ---
  Future<void> _handlePlay(int index) async {
    // إذا كانت هذه السورة تعمل بالفعل، قم بالإيقاف المؤقت
    if (_playingIndex == index && _playerState == PlayerState.playing) {
      await _audioPlayer.pause();
      return;
    }
    // إذا كانت هذه السورة متوقفة مؤقتاً، قم بالاستئناف
    if (_playingIndex == index && _playerState == PlayerState.paused) {
      await _audioPlayer.resume();
      return;
    }

    // إذا كانت سورة جديدة، قم بالتشغيل
    try {
      setState(() {
        _loadingIndex = index; // إظهار دائرة التحميل
        _playingIndex = index; // تحديد السورة الحالية
        _position = Duration.zero;
        _duration = Duration.zero;
      });

      final surahNumber = (index + 1).toString().padLeft(3, '0');
      // --- استخدام الرابط الآمن https ---
      final url = 'https://download.quranicaudio.com/quran/${widget.reciter.relativePath}/$surahNumber.mp3';
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      // --- طباعة الخطأ في السجل لتشخيصه ---
      debugPrint("Error playing audio: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل تشغيل السورة. يرجى التحقق من اتصال الإنترنت.')),
        );
        setState(() {
          _loadingIndex = null;
          _playingIndex = null;
        });
      }
    }
  }

  String _formatDuration(Duration d) {
    try {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
      return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds".replaceAll("00:", "");
    } catch (e) {
      return "00:00";
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reciter.name.replaceAll('Ad-Dussary', 'الدوسري').replaceAll('Al-Minshawi', 'المنشاوي').replaceAll('AbdulSamad', 'عبد الصمد').replaceAll('Al-Muaiqly', 'المعيقلي'), style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: 114,
              separatorBuilder: (context, index) => Divider(height: 1, color: primaryColor.withOpacity(0.1)),
              itemBuilder: (context, index) {
                final surahName = surahNames[index];
                final isPlaying = _playingIndex == index;
                final isLoading = _loadingIndex == index;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: primaryColor,
                    child: Text((index + 1).toString(), style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                  title: Text(surahName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w600)),
                  trailing: isLoading
                      ? SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
                        )
                      : IconButton(
                          icon: Icon(
                            isPlaying && _playerState == PlayerState.playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
                            color: primaryColor,
                            size: 32,
                          ),
                          onPressed: () => _handlePlay(index),
                        ),
                );
              },
            ),
          ),
          if (_playingIndex != null) _buildMiniPlayer(primaryColor),
        ],
      ),
    );
  }

  Widget _buildMiniPlayer(Color primaryColor) {
    return Material(
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(12),
        color: Theme.of(context).cardTheme.color,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: primaryColor, child: const Icon(Icons.music_note, color: Colors.white, size: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    surahNames[_playingIndex!],
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(_playerState == PlayerState.playing ? Icons.pause : Icons.play_arrow, size: 32, color: primaryColor),
                  onPressed: () {
                     if (_playerState == PlayerState.playing) {
                       _audioPlayer.pause();
                     } else {
                       _audioPlayer.resume();
                     }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.stop, size: 32, color: primaryColor.withOpacity(0.7)),
                  onPressed: () {
                    _audioPlayer.stop();
                    setState(() {
                      _playingIndex = null;
                    });
                  },
                ),
              ],
            ),
            Slider(
              min: 0,
              max: _duration.inSeconds.toDouble() + 1.0,
              value: _position.inSeconds.toDouble().clamp(0.0, _duration.inSeconds.toDouble()),
              onChanged: (value) async {
                final position = Duration(seconds: value.toInt());
                await _audioPlayer.seek(position);
              },
              activeColor: primaryColor,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(_position)),
                  Text(_formatDuration(_duration)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

