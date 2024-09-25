import 'package:reminder_active_breaks/preferences/preference_utils.dart';

class ReminderActiveBreaksPreferencesService {
  static const int _reminderActiveBreak = 3600;
  static const int _reminderDidYouTakeActivePause = 60;

  static const String _timerSecondsRemainingNextActiveBreakIsUpKey =
      'timerSecondsRemainingNextActiveBreakIsUpKey';

  static Future<void> setTimerSecondsRemainingNextActiveBreakIsUpBreak(
      bool value) async {
    await PreferencesUtils.setBool(
        ReminderActiveBreaksPreferencesService
            ._timerSecondsRemainingNextActiveBreakIsUpKey,
        value);
  }

  static Future<bool> getTimerSecondsRemainingNextActiveBreakIsUpBreak() async {
    bool? output = await PreferencesUtils.getBool(
        ReminderActiveBreaksPreferencesService
            ._timerSecondsRemainingNextActiveBreakIsUpKey);

    return output ?? false;
  }

  static const String _timerSecondsRemainingDidYouTakeActivePauseIsUpKey =
      'timerSecondsRemainingDidYouTakeActivePauseIsUpKey';

  static Future<void> setTimerSecondsRemainingDidYouTakeActivePauseIsUp(
      bool value) async {
    await PreferencesUtils.setBool(
        ReminderActiveBreaksPreferencesService
            ._timerSecondsRemainingDidYouTakeActivePauseIsUpKey,
        value);
  }

  static Future<bool>
      getTimerSecondsRemainingDidYouTakeActivePauseIsUp() async {
    bool? output = await PreferencesUtils.getBool(
        ReminderActiveBreaksPreferencesService
            ._timerSecondsRemainingDidYouTakeActivePauseIsUpKey);

    return output ?? false;
  }

  //------------ Tiempo en segundos restanta para la pausa activa, default
  static const String _defaultSecondsRemainingNextActiveBreakKey =
      'defaultSecondsRemainingNextActiveBreak';

  static Future<void> setDefaultSecondsRemainingNextActiveBreak(
      int value) async {
    await PreferencesUtils.setInt(
        ReminderActiveBreaksPreferencesService
            ._defaultSecondsRemainingNextActiveBreakKey,
        value);
  }

  static Future<int> getDefaultSecondsRemainingNextActiveBreak() async {
    int? output = await PreferencesUtils.getInt(
        ReminderActiveBreaksPreferencesService
            ._defaultSecondsRemainingNextActiveBreakKey);

    return output ??
        ReminderActiveBreaksPreferencesService._reminderActiveBreak;
  }

//------------ Tiempo en segundos restanta para la pausa activa

  static const String _secondsRemainingNextActiveBreakKey =
      'secondsRemainingNextActiveBreak';

  static Future<void> setSecondsRemainingNextActiveBreak(int value) async {
    await PreferencesUtils.setInt(
        ReminderActiveBreaksPreferencesService
            ._secondsRemainingNextActiveBreakKey,
        value);
  }

  static Future<int> getSecondsRemainingNextActiveBreak() async {
    int? output = await PreferencesUtils.getInt(
        ReminderActiveBreaksPreferencesService
            ._secondsRemainingNextActiveBreakKey);

    return output ??
        ReminderActiveBreaksPreferencesService._reminderActiveBreak;
  }

//------------ Tiempo en segundos para la validacion de la toma de la pausa activa
  static const String _secondsRemainingDidYouTakeActivePauseKey =
      'secondsRemainingDidYouTakeActivePause';

  static Future<void> setSecondsRemainingDidYouTakeActivePause(
      int value) async {
    await PreferencesUtils.setInt(
        ReminderActiveBreaksPreferencesService
            ._secondsRemainingDidYouTakeActivePauseKey,
        value);
  }

  static Future<int> getSecondsRemainingDidYouTakeActivePause() async {
    int? output = await PreferencesUtils.getInt(
        ReminderActiveBreaksPreferencesService
            ._secondsRemainingDidYouTakeActivePauseKey);

    return output ??
        ReminderActiveBreaksPreferencesService._reminderDidYouTakeActivePause;
  }

//------------ Tiempo en segundos para la validacion de la toma de la pausa activa, default
  static const String _defaultSecondsRemainingDidYouTakeActivePauseKey =
      'defaultSecondsRemainingDidYouTakeActivePause';

  static Future<void> setDefaultSecondsRemainingDidYouTakeActivePause(
      int value) async {
    await PreferencesUtils.setInt(
        ReminderActiveBreaksPreferencesService
            ._defaultSecondsRemainingDidYouTakeActivePauseKey,
        value);
  }

  static Future<int> getDefaultSecondsRemainingDidYouTakeActivePause() async {
    int? output = await PreferencesUtils.getInt(
        ReminderActiveBreaksPreferencesService
            ._defaultSecondsRemainingDidYouTakeActivePauseKey);

    return output ??
        ReminderActiveBreaksPreferencesService._reminderDidYouTakeActivePause;
  }
}
