import 'package:shared_preferences/shared_preferences.dart';

class ReminderActiveBreaksPreferencesService {
  static late SharedPreferences _prefs;
  static const int _reminderActiveBreak = 3600;
  static const int _reminderDidYouTakeActivePause = 60;

  // Inicializa SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const String _timerSecondsRemainingNextActiveBreakIsUpKey =
      'timerSecondsRemainingNextActiveBreakIsUpKey';

  static Future<void> setTimerSecondsRemainingNextActiveBreakIsUpBreak(
      bool value) async {
    await _prefs.setBool(_timerSecondsRemainingNextActiveBreakIsUpKey, value);
  }

  static bool getTimerSecondsRemainingNextActiveBreakIsUpBreak() {
    return _prefs.getBool(_timerSecondsRemainingNextActiveBreakIsUpKey) ?? true;
  }

  static const String _timerSecondsRemainingDidYouTakeActivePauseIsUpKey =
      'timerSecondsRemainingDidYouTakeActivePauseIsUpKey';

  static Future<void> setTimerSecondsRemainingDidYouTakeActivePauseIsUp(
      bool value) async {
    await _prefs.setBool(
        _timerSecondsRemainingDidYouTakeActivePauseIsUpKey, value);
  }

  static bool getTimerSecondsRemainingDidYouTakeActivePauseIsUp() {
    return _prefs.getBool(_timerSecondsRemainingDidYouTakeActivePauseIsUpKey) ??
        true;
  }

  //------------ Tiempo en segundos restanta para la pausa activa, default
  static const String _defaultSecondsRemainingNextActiveBreakKey =
      'defaultSecondsRemainingNextActiveBreak';

  static Future<void> setDefaultSecondsRemainingNextActiveBreak(
      int value) async {
    await _prefs.setInt(_defaultSecondsRemainingNextActiveBreakKey, value);
  }

  static int getDefaultSecondsRemainingNextActiveBreak() {
    return _prefs.getInt(_defaultSecondsRemainingNextActiveBreakKey) ??
        ReminderActiveBreaksPreferencesService._reminderActiveBreak;
  }

  static Future<void> removeDefaultSecondsRemainingNextActiveBreak() async {
    await _prefs.remove(_defaultSecondsRemainingNextActiveBreakKey);
  }

//------------ Tiempo en segundos restanta para la pausa activa

  static const String _secondsRemainingNextActiveBreakKey =
      'secondsRemainingNextActiveBreak';

  static Future<void> setSecondsRemainingNextActiveBreak(int value) async {
    await _prefs.setInt(_secondsRemainingNextActiveBreakKey, value);
  }

  static int getSecondsRemainingNextActiveBreak() {
    return _prefs.getInt(_secondsRemainingNextActiveBreakKey) ??
        ReminderActiveBreaksPreferencesService._reminderActiveBreak;
  }

  static Future<void> removeSecondsRemainingNextActiveBreak() async {
    await _prefs.remove(_secondsRemainingNextActiveBreakKey);
  }

//------------ Tiempo en segundos para la validacion de la toma de la pausa activa
  static const String _secondsRemainingDidYouTakeActivePauseKey =
      'secondsRemainingDidYouTakeActivePause';

  static Future<void> setSecondsRemainingDidYouTakeActivePause(
      int value) async {
    await _prefs.setInt(_secondsRemainingDidYouTakeActivePauseKey, value);
  }

  static int getSecondsRemainingDidYouTakeActivePause() {
    return _prefs.getInt(_secondsRemainingDidYouTakeActivePauseKey) ??
        ReminderActiveBreaksPreferencesService._reminderDidYouTakeActivePause;
  }

  static Future<void> removeSecondsRemainingDidYouTakeActivePause() async {
    await _prefs.remove(_secondsRemainingDidYouTakeActivePauseKey);
  }

//------------ Tiempo en segundos para la validacion de la toma de la pausa activa, default
  static const String _defaultSecondsRemainingDidYouTakeActivePauseKey =
      'defaultSecondsRemainingDidYouTakeActivePause';

  static Future<void> setDefaultSecondsRemainingDidYouTakeActivePause(
      int value) async {
    await _prefs.setInt(
        _defaultSecondsRemainingDidYouTakeActivePauseKey, value);
  }

  static int getDefaultSecondsRemainingDidYouTakeActivePause() {
    return _prefs.getInt(_defaultSecondsRemainingDidYouTakeActivePauseKey) ??
        ReminderActiveBreaksPreferencesService._reminderDidYouTakeActivePause;
  }

  static Future<void>
      removeDefaultSecondsRemainingDidYouTakeActivePause() async {
    await _prefs.remove(_defaultSecondsRemainingDidYouTakeActivePauseKey);
  }
}
