import 'dart:async'; // Para usar Timer
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reminder_active_breaks/preferences/reminder_active_breaks_preferences_service.dart'; // Importa permiso para notificaciones

class ActiveBreakApp extends StatefulWidget {
  @override
  _ActiveBreakAppState createState() => _ActiveBreakAppState();
}

class _ActiveBreakAppState extends State<ActiveBreakApp> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  int defaultSecondsRemainingNextActiveBreak = 3600;

  int secondsRemainingNextActiveBreak = 3600;

  late Timer timerNextActiveBreak;
  bool timerNextActiveBreakIsUp = true;

  int defaultSecondsRemaininDidYouTakeActivePause = 60;

  int secondsRemainingDidYouTakeActivePause = 60;
  static const String actionSubmitDidYouTakeActivePauseId =
      'i_did_take_active_pause';
  static const String actionDeclineDidYouTakeActivePauseId =
      'i_did_not_take_active_pause';
  late Timer timerDidYouTakeActivePause;
  bool timerDidYouTakeActivePauseIsUp = true;

  @override
  void initState() {
    super.initState();
    _loadTimer();
    requestNotificationPermission();
    initializeNotifications();
  }

  void _loadTimer() async {
    setState(() {
      timerNextActiveBreakIsUp = ReminderActiveBreaksPreferencesService
          .getTimerSecondsRemainingNextActiveBreakIsUpBreak();
      timerDidYouTakeActivePauseIsUp = ReminderActiveBreaksPreferencesService
          .getTimerSecondsRemainingDidYouTakeActivePauseIsUp();
      defaultSecondsRemainingNextActiveBreak =
          ReminderActiveBreaksPreferencesService
              .getDefaultSecondsRemainingNextActiveBreak();
      secondsRemainingNextActiveBreak = ReminderActiveBreaksPreferencesService
          .getSecondsRemainingNextActiveBreak();
      defaultSecondsRemaininDidYouTakeActivePause =
          ReminderActiveBreaksPreferencesService
              .getDefaultSecondsRemainingDidYouTakeActivePause();
      secondsRemainingDidYouTakeActivePause =
          ReminderActiveBreaksPreferencesService
              .getSecondsRemainingDidYouTakeActivePause();
    });
  }

  // Solo en iOS: Esta función permite que el servicio siga funcionando en segundo plano
  bool onIosBackground(ServiceInstance service) {
    WidgetsFlutterBinding.ensureInitialized();
    return true;
  }

  void requestNotificationPermission() async {
    // Solicitar permiso para notificaciones en Android 13+
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> initializeNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('azulejo_profile');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        print(notificationResponse.notificationResponseType);
        print(notificationResponse.actionId);
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotificationAction:
            handleAction(notificationResponse.actionId ?? '');
            break;
          case NotificationResponseType.selectedNotification:
            // TODO: Handle this case.
            break;
        }
      },
      //onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  // Función para mostrar la notificación
  void showNotification(
      {required String title,
      required String description,
      List<AndroidNotificationAction>? actions}) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'high_importance_channel', // Asegúrate de que el ID del canal coincide
        title,
        channelDescription: description,
        importance: Importance.max,
        priority: Priority.high,
        actions: actions);

    NotificationDetails generalNotificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
        0, // ID de la notificación
        title,
        description,
        generalNotificationDetails);
  }

  // Función que inicia el temporizador y cuenta hacia atrás
  void startTimerNextActiveBreak() {
    setState(() {
      timerNextActiveBreakIsUp = true;
      ReminderActiveBreaksPreferencesService
          .setTimerSecondsRemainingNextActiveBreakIsUpBreak(
              timerNextActiveBreakIsUp);

      timerDidYouTakeActivePauseIsUp = false;
      ReminderActiveBreaksPreferencesService
          .setTimerSecondsRemainingDidYouTakeActivePauseIsUp(
              timerDidYouTakeActivePauseIsUp);
    });
    timerNextActiveBreak = Timer.periodic(const Duration(seconds: 1),
        (Timer timerOfTimerNextActiveBreak) {
      setState(() {
        if (!timerNextActiveBreakIsUp) {
          timerOfTimerNextActiveBreak.cancel();
        } else if (secondsRemainingNextActiveBreak > 0) {
          secondsRemainingNextActiveBreak--;
          ReminderActiveBreaksPreferencesService
              .setSecondsRemainingNextActiveBreak(
                  secondsRemainingNextActiveBreak);
        } else {
          // Mostrar notificación cuando el tiempo llega a cero
          showNotification(
              title: 'Es hora de una pausa activa',
              description: 'Levántate y estira un poco!');
          timerOfTimerNextActiveBreak.cancel();
          starTimerDidYouTakeActivePause();
        }
      });
    });
  }

  void starTimerDidYouTakeActivePause() {
    setState(() {
      timerDidYouTakeActivePauseIsUp = true;
      ReminderActiveBreaksPreferencesService
          .setTimerSecondsRemainingDidYouTakeActivePauseIsUp(
              timerDidYouTakeActivePauseIsUp);
    });
    timerDidYouTakeActivePause = Timer.periodic(const Duration(seconds: 1),
        (Timer timerOfTimerDidYouTakeActivePause) {
      setState(() {
        if (!timerDidYouTakeActivePauseIsUp) {
          timerOfTimerDidYouTakeActivePause.cancel();
        } else if (secondsRemainingDidYouTakeActivePause > 0) {
          secondsRemainingDidYouTakeActivePause--;
          ReminderActiveBreaksPreferencesService
              .setSecondsRemainingDidYouTakeActivePause(
                  secondsRemainingDidYouTakeActivePause);
        } else {
          // Mostrar notificación cuando el tiempo llega a cero
          showNotification(
              title: 'Ey 🖖🏻!',
              description: '¿Hiciste la pausa activa 😠?',
              actions: <AndroidNotificationAction>[
                const AndroidNotificationAction(
                  actionSubmitDidYouTakeActivePauseId,
                  'Por supuesto 😎!',
                  showsUserInterface: true,
                  // By default, Android plugin will dismiss the notification when the
                  // user tapped on a action (this mimics the behavior on iOS).
                  cancelNotification: true,
                ),
                const AndroidNotificationAction(
                  actionDeclineDidYouTakeActivePauseId,
                  'No 😔',
                  showsUserInterface: true,
                  // By default, Android plugin will dismiss the notification when the
                  // user tapped on a action (this mimics the behavior on iOS).
                  cancelNotification: true,
                ),
              ]);
          secondsRemainingDidYouTakeActivePause =
              defaultSecondsRemaininDidYouTakeActivePause;
          ReminderActiveBreaksPreferencesService
              .setSecondsRemainingDidYouTakeActivePause(
                  secondsRemainingDidYouTakeActivePause);
          //timerOfTimerDidYouTakeActivePause.cancel();
        }
      });
    });
  }

  void restartTimerNextActiveBreak() {
    // Reiniciar el temporizador para la próxima pausa
    setState(() {
      secondsRemainingNextActiveBreak = defaultSecondsRemainingNextActiveBreak;
      ReminderActiveBreaksPreferencesService.setSecondsRemainingNextActiveBreak(
          secondsRemainingNextActiveBreak);

      secondsRemainingDidYouTakeActivePause =
          defaultSecondsRemaininDidYouTakeActivePause;
      ReminderActiveBreaksPreferencesService
          .setSecondsRemainingDidYouTakeActivePause(
              secondsRemainingDidYouTakeActivePause);

      timerNextActiveBreakIsUp = true;
      ReminderActiveBreaksPreferencesService
          .setTimerSecondsRemainingNextActiveBreakIsUpBreak(
              timerNextActiveBreakIsUp);

      timerDidYouTakeActivePauseIsUp = false;
      ReminderActiveBreaksPreferencesService
          .setTimerSecondsRemainingDidYouTakeActivePauseIsUp(
              timerDidYouTakeActivePauseIsUp);
    }); // Actualizar la UI
  }

  void stopTimerDidYouTakeActivePause() {
    setState(() {
      timerDidYouTakeActivePauseIsUp = false;
      ReminderActiveBreaksPreferencesService
          .setTimerSecondsRemainingDidYouTakeActivePauseIsUp(
              timerDidYouTakeActivePauseIsUp);
    });
  }

  void stopTimerNextActiveBreak() {
    setState(() {
      timerNextActiveBreakIsUp = false;
      ReminderActiveBreaksPreferencesService
          .setTimerSecondsRemainingNextActiveBreakIsUpBreak(
              timerNextActiveBreakIsUp);
    });
  }

  void handleAction(String payload) {
    switch (payload) {
      case actionDeclineDidYouTakeActivePauseId:
        //print('Que mal!');
        //starTimerDidYouTakeActivePause();
        //flutterLocalNotificationsPlugin.cancelAll();
        break;
      case actionSubmitDidYouTakeActivePauseId:
        restartTimerNextActiveBreak();
        startTimerNextActiveBreak();
        break;
      default:
        print("Acción desconocida");
        break;
    }
  }

  // Convertir los segundos restantes en formato de minutos:segundos
  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Pausas Activas'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Próxima pausa activa en:',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text(
              formatTime(secondsRemainingNextActiveBreak),
              // Muestra el tiempo restante
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            const Text(
              'Te preguntaremos si tomaste esta pausa activa dentro de:',
              // Muestra el tiempo restante
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            Text(
              formatTime(secondsRemainingDidYouTakeActivePause),
              // Muestra el tiempo restante
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: secondsRemainingNextActiveBreak ==
                      defaultSecondsRemainingNextActiveBreak
                  ? () {
                      startTimerNextActiveBreak();
                    }
                  : () {
                      stopTimerDidYouTakeActivePause();
                      restartTimerNextActiveBreak();
                    },
              child: secondsRemainingNextActiveBreak ==
                      defaultSecondsRemainingNextActiveBreak
                  ? const Icon(
                      size: 60, color: Colors.green, Icons.not_started_sharp)
                  : const Icon(
                      size: 30,
                      color: Colors.deepOrangeAccent,
                      Icons.restart_alt),
            ),
            ElevatedButton(
              onPressed: () {
                startTimerNextActiveBreak();
                starTimerDidYouTakeActivePause();
                stopTimerDidYouTakeActivePause();
                stopTimerNextActiveBreak();
              },
              child: const Icon(size: 30, color: Colors.red, Icons.stop),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: const ButtonStyle(
                  fixedSize: WidgetStatePropertyAll(Size(300, 70))),
              onPressed: secondsRemainingNextActiveBreak == 0
                  ? () {
                      restartTimerNextActiveBreak();
                      startTimerNextActiveBreak();
                    }
                  : null,
              child: const Text(
                'Ya tomé mi pausa activa 🥳',
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Levantate 🙆🏻‍!',
              // Muestra el tiempo restante
              style: TextStyle(
                  fontSize: 30,
                  color: secondsRemainingNextActiveBreak == 0
                      ? Colors.black
                      : Colors.black12,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              'Hidratate 💧!',
              // Muestra el tiempo restante
              style: TextStyle(
                  fontSize: 30,
                  color: secondsRemainingNextActiveBreak == 0
                      ? Colors.black
                      : Colors.black12,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              'Estira 💆🏻‍!',
              // Muestra el tiempo restante
              style: TextStyle(
                  fontSize: 30,
                  color: secondsRemainingNextActiveBreak == 0
                      ? Colors.black
                      : Colors.black12,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    timerNextActiveBreak?.cancel(); // Cancela el temporizador al cerrar la app
    //selectNotificationStream.close();
    super.dispose();
  }
}
