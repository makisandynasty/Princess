import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preset alarm & alert ringtones.
class AlarmSoundPreset {
  const AlarmSoundPreset({
    required this.id,
    required this.name,
    required this.description,
    required this.url,
  });

  final String id;
  final String name;
  final String description;
  final String url;
}

class SoundService {
  SoundService() {
    _init();
  }

  static const String _volumeKey = 'princess_alarm_volume';
  static const String _soundKey = 'princess_alarm_sound_id';

  final AudioPlayer _player = AudioPlayer();
  Timer? _buzzerTimer;
  Uint8List? _cachedAlarmWavBytes;

  static const List<AlarmSoundPreset> presets = [
    AlarmSoundPreset(
      id: 'digital_pulse',
      name: 'Digital Alarm Pulse (Loud Buzz)',
      description: 'Loud high-pitch digital wake-up buzzer',
      url: 'builtin:buzzer',
    ),
    AlarmSoundPreset(
      id: 'gentle_chime',
      name: 'Gentle Chime',
      description: 'Peaceful harmonic morning chime',
      url: 'https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3',
    ),
    AlarmSoundPreset(
      id: 'morning_melody',
      name: 'Morning Melody',
      description: 'Uplifting acoustic harmony',
      url: 'https://assets.mixkit.co/active_storage/sfx/2874/2874-preview.mp3',
    ),
    AlarmSoundPreset(
      id: 'sweet_harp',
      name: 'Dreamy Harp',
      description: 'Relaxing ambient strings',
      url: 'https://assets.mixkit.co/active_storage/sfx/2872/2872-preview.mp3',
    ),
    AlarmSoundPreset(
      id: 'princess_chimes',
      name: 'Princess Bell Harmony',
      description: 'Sparkling sweet fairy bells',
      url: 'https://assets.mixkit.co/active_storage/sfx/1000/1000-preview.mp3',
    ),
  ];

  double _volume = 0.9;
  String _selectedSoundId = 'digital_pulse';
  bool _isPlaying = false;
  bool _isAlarmRinging = false;

  double get volume => _volume;
  String get selectedSoundId => _selectedSoundId;
  bool get isPlaying => _isPlaying;
  bool get isAlarmRinging => _isAlarmRinging;

  AlarmSoundPreset get currentPreset => presets.firstWhere(
        (p) => p.id == _selectedSoundId,
        orElse: () => presets.first,
      );

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _volume = prefs.getDouble(_volumeKey) ?? 0.9;
      _selectedSoundId = prefs.getString(_soundKey) ?? 'digital_pulse';
      await _player.setVolume(_volume);
      _cachedAlarmWavBytes = _generateBuzzerWav();
    } catch (e) {
      debugPrint('SoundService init error: $e');
    }
  }

  /// Generates a crisp, loud, self-contained 16-bit PCM WAV buzzer alarm (No CORS, No network delay)
  Uint8List _generateBuzzerWav() {
    const sampleRate = 22050;
    const durationSec = 1.0;
    const numSamples = (sampleRate * durationSec);
    final byteData = ByteData(44 + (numSamples * 2).toInt());

    // RIFF header
    final subChunk2Size = (numSamples * 2).toInt();
    final chunkSize = 36 + subChunk2Size;

    // "RIFF"
    byteData.setUint8(0, 0x52);
    byteData.setUint8(1, 0x49);
    byteData.setUint8(2, 0x46);
    byteData.setUint8(3, 0x46);
    byteData.setUint32(4, chunkSize, Endian.little);
    // "WAVE"
    byteData.setUint8(8, 0x57);
    byteData.setUint8(9, 0x41);
    byteData.setUint8(10, 0x56);
    byteData.setUint8(11, 0x45);
    // "fmt "
    byteData.setUint8(12, 0x66);
    byteData.setUint8(13, 0x6D);
    byteData.setUint8(14, 0x74);
    byteData.setUint8(15, 0x20);
    byteData.setUint32(16, 16, Endian.little); // SubChunk1Size (16 for PCM)
    byteData.setUint16(20, 1, Endian.little); // AudioFormat (1 = PCM)
    byteData.setUint16(22, 1, Endian.little); // NumChannels (1 = Mono)
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, sampleRate * 2, Endian.little); // ByteRate
    byteData.setUint16(32, 2, Endian.little); // BlockAlign
    byteData.setUint16(34, 16, Endian.little); // BitsPerSample
    // "data"
    byteData.setUint8(36, 0x64);
    byteData.setUint8(37, 0x61);
    byteData.setUint8(38, 0x74);
    byteData.setUint8(39, 0x61);
    byteData.setUint32(40, subChunk2Size, Endian.little);

    // Audio signal generation: Alternating rapid loud beeps (900Hz and 1200Hz)
    int offset = 44;
    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final isBeep = (t % 0.25) < 0.18; // 180ms beep, 70ms pause
      final freq = (t % 0.5) < 0.25 ? 950.0 : 1300.0;
      double sample = 0.0;
      if (isBeep) {
        sample = math.sin(2.0 * math.pi * freq * t) * 0.85;
      }
      final sampleInt = (sample * 32767).toInt().clamp(-32768, 32767);
      byteData.setInt16(offset, sampleInt, Endian.little);
      offset += 2;
    }

    return byteData.buffer.asUint8List();
  }

  /// Change volume level (0.0 to 1.0)
  Future<void> setVolume(double newVolume) async {
    _volume = newVolume.clamp(0.0, 1.0);
    await _player.setVolume(_volume);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, _volume);
  }

  /// Change selected alarm sound
  Future<void> setSelectedSound(String soundId) async {
    _selectedSoundId = soundId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_soundKey, soundId);
  }

  /// Start persistent, loud looping alarm (Continuous Ringing & Buzzing)
  Future<void> startAlarmLoop([AlarmSoundPreset? preset]) async {
    try {
      await stop();
      _isAlarmRinging = true;
      _isPlaying = true;
      final target = preset ?? currentPreset;

      await _player.setVolume(_volume);
      await _player.setReleaseMode(ReleaseMode.loop);

      if (target.url.startsWith('builtin:') || _cachedAlarmWavBytes != null) {
        _cachedAlarmWavBytes ??= _generateBuzzerWav();
        await _player.play(BytesSource(_cachedAlarmWavBytes!));
      } else {
        await _player.play(UrlSource(target.url));
      }

      // Haptic and system alert pulsing
      _buzzerTimer?.cancel();
      _buzzerTimer = Timer.periodic(const Duration(milliseconds: 700), (_) {
        if (!_isAlarmRinging) return;
        HapticFeedback.heavyImpact();
        SystemSound.play(SystemSoundType.alert);
      });
    } catch (e) {
      debugPrint('Alarm start error: $e');
      _startFallbackBuzzer();
    }
  }

  void _startFallbackBuzzer() {
    _buzzerTimer?.cancel();
    _buzzerTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      if (!_isAlarmRinging) return;
      HapticFeedback.vibrate();
      SystemSound.play(SystemSoundType.alert);
    });
  }

  /// Play short preview of sound
  Future<void> playPreview([AlarmSoundPreset? preset]) async {
    try {
      await stop();
      final target = preset ?? currentPreset;
      await _player.setVolume(_volume);
      await _player.setReleaseMode(ReleaseMode.stop);

      if (target.url.startsWith('builtin:') || target.id == 'digital_pulse') {
        _cachedAlarmWavBytes ??= _generateBuzzerWav();
        await _player.play(BytesSource(_cachedAlarmWavBytes!));
      } else {
        await _player.play(UrlSource(target.url));
      }
      _isPlaying = true;
    } catch (e) {
      debugPrint('Sound preview play error: $e');
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// Stop all playing alarm audio and buzzing
  Future<void> stop() async {
    try {
      _isAlarmRinging = false;
      _isPlaying = false;
      _buzzerTimer?.cancel();
      _buzzerTimer = null;
      await _player.stop();
    } catch (e) {
      debugPrint('Sound stop error: $e');
    }
  }

  void dispose() {
    _buzzerTimer?.cancel();
    _player.dispose();
  }
}

/// Riverpod provider for SoundService
final soundServiceProvider = Provider<SoundService>((ref) {
  final service = SoundService();
  ref.onDispose(() => service.dispose());
  return service;
});
