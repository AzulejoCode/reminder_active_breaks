import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reminder_active_breaks/preferences/reminder_active_breaks_preferences_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class TimeFormat {
  String minutes;
  String seconds;

  TimeFormat(this.minutes, this.seconds);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recordatorio de Pausas Activas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: ActiveBreakApp(),
    );
  }
}

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

  DateTime activePauseCounterStartTime = DateTime.now();
  DateTime activePauseCounterLastTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTimer();
    requestNotificationPermission();
    initializeNotifications();
    _requestOverlayPermission();
  }

  // Función para solicitar permiso de ventana flotante
  Future<void> _requestOverlayPermission() async {
    debugPrint('🧐 Revisando permisos');
    final bool status = await FlutterOverlayWindow.isPermissionGranted();
    if (status) {
      debugPrint('✅ Tenemos los permisos');
    }
    if (!status) {
      debugPrint('🙏 Solicitando permisos');
      bool? granted = await FlutterOverlayWindow.requestPermission();
      if (!granted!) {
        // Manejar la falta de permiso
        debugPrint('🚨 PERMISO DENEGADO');
      }
    }
  }

  // Mostrar la ventana flotante
  Future<void> _showOverlay() async {
    debugPrint('🙆🏻‍ Mostrando widget flotante!');
    FlutterOverlayWindow.showOverlay(
      height: 150,
      // Altura de la ventana flotante
      width: 150,
      // Anchura de la ventana flotante
      alignment: OverlayAlignment.center,
      // Alineación en la pantalla
      enableDrag: true,
      // Habilitar arrastrar
      flag: OverlayFlag.defaultFlag, // Ajustes predeterminados
    );

    bool overlayIsActive = await FlutterOverlayWindow.isActive();
    if (overlayIsActive) {
      debugPrint('🔺 El Widget flotante está activo!');
      // await FlutterOverlayWindow.updateFlag(OverlayFlag.defaultFlag);
    }
  }

  Future<void> _loadTimer() async {
    timerNextActiveBreakIsUp = await ReminderActiveBreaksPreferencesService
        .getTimerSecondsRemainingNextActiveBreakIsUpBreak();

    timerDidYouTakeActivePauseIsUp =
        await ReminderActiveBreaksPreferencesService
            .getTimerSecondsRemainingDidYouTakeActivePauseIsUp();

    defaultSecondsRemainingNextActiveBreak =
        await ReminderActiveBreaksPreferencesService
            .getDefaultSecondsRemainingNextActiveBreak();
    secondsRemainingNextActiveBreak =
        await ReminderActiveBreaksPreferencesService
            .getSecondsRemainingNextActiveBreak();

    defaultSecondsRemaininDidYouTakeActivePause =
        await ReminderActiveBreaksPreferencesService
            .getDefaultSecondsRemainingDidYouTakeActivePause();

    secondsRemainingDidYouTakeActivePause =
        await ReminderActiveBreaksPreferencesService
            .getSecondsRemainingDidYouTakeActivePause();
    setState(() {});
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
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotificationAction:
            handleAction(notificationResponse.actionId ?? '');
            break;
          case NotificationResponseType.selectedNotification:
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
    timerNextActiveBreakIsUp = true;
    ReminderActiveBreaksPreferencesService
        .setTimerSecondsRemainingNextActiveBreakIsUpBreak(
            timerNextActiveBreakIsUp);
    activePauseCounterStartTime = DateTime.now();
    stopTimerDidYouTakeActivePause();
    setState(() {});

    timerNextActiveBreak = Timer.periodic(const Duration(seconds: 1),
        (Timer timerOfTimerNextActiveBreak) {
      if (!timerNextActiveBreakIsUp) {
        timerOfTimerNextActiveBreak.cancel();
      } else if (secondsRemainingNextActiveBreak > 0) {
        secondsRemainingNextActiveBreak--;
        activePauseCounterLastTime = DateTime.now();
        ReminderActiveBreaksPreferencesService
            .setSecondsRemainingNextActiveBreak(
                secondsRemainingNextActiveBreak);
      } else {
        // Mostrar notificación cuando el tiempo llega a cero
        showNotification(
            title: '⏰ Es hora de una pausa activa 💪🏻',
            description: '🥱 Levántate y estira un poco 🙆🏻‍!');
        timerOfTimerNextActiveBreak.cancel();
        starTimerDidYouTakeActivePause();
      }
      setState(() {});
    });
  }

  void starTimerDidYouTakeActivePause() {
    timerDidYouTakeActivePauseIsUp = true;
    ReminderActiveBreaksPreferencesService
        .setTimerSecondsRemainingDidYouTakeActivePauseIsUp(
            timerDidYouTakeActivePauseIsUp);
    setState(() {});

    timerDidYouTakeActivePause = Timer.periodic(const Duration(seconds: 1),
        (Timer timerOfTimerDidYouTakeActivePause) {
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
            description: '¿Hiciste la pausa activa 🤨?',
            actions: <AndroidNotificationAction>[
              const AndroidNotificationAction(
                actionSubmitDidYouTakeActivePauseId,
                '¡Por supuesto 😎!',
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
      setState(() {});
    });
  }

  void stopTimerNextActiveBreak() {
    // Reiniciar el temporizador para la próxima pausa
    secondsRemainingNextActiveBreak = defaultSecondsRemainingNextActiveBreak;
    ReminderActiveBreaksPreferencesService.setSecondsRemainingNextActiveBreak(
        secondsRemainingNextActiveBreak);

    timerNextActiveBreakIsUp = false;
    ReminderActiveBreaksPreferencesService
        .setTimerSecondsRemainingNextActiveBreakIsUpBreak(
            timerNextActiveBreakIsUp);
    setState(() {}); // Actualizar la UI
  }

  void stopTimerDidYouTakeActivePause() {
    secondsRemainingDidYouTakeActivePause =
        defaultSecondsRemaininDidYouTakeActivePause;
    ReminderActiveBreaksPreferencesService
        .setSecondsRemainingDidYouTakeActivePause(
            secondsRemainingDidYouTakeActivePause);

    timerDidYouTakeActivePauseIsUp = false;
    ReminderActiveBreaksPreferencesService
        .setTimerSecondsRemainingDidYouTakeActivePauseIsUp(
            timerDidYouTakeActivePauseIsUp);
    setState(() {});
  }

  void pauseTimerNextActiveBreak() {
    timerNextActiveBreakIsUp = false;
    ReminderActiveBreaksPreferencesService
        .setTimerSecondsRemainingNextActiveBreakIsUpBreak(
            timerNextActiveBreakIsUp);
    setState(() {});
  }

  void handleAction(String payload) {
    switch (payload) {
      case actionDeclineDidYouTakeActivePauseId:
        break;
      case actionSubmitDidYouTakeActivePauseId:
        stopTimerNextActiveBreak();
        startTimerNextActiveBreak();
        break;
      default:
        debugPrint("Acción desconocida");
        break;
    }
  }

  void _showEditOptions(BuildContext context) {
    DatePicker.showTimePicker(context,
        currentTime: DateTime.fromMillisecondsSinceEpoch(
            secondsRemainingNextActiveBreak * 1000,
            isUtc: true),
        locale: LocaleType.es, onConfirm: (dateTime) {
      double secondsParsed = dateTime.millisecondsSinceEpoch / 1000;
      secondsRemainingNextActiveBreak = secondsParsed.toInt();
      defaultSecondsRemainingNextActiveBreak = secondsRemainingNextActiveBreak;
      ReminderActiveBreaksPreferencesService.setSecondsRemainingNextActiveBreak(
          secondsRemainingNextActiveBreak);
      ReminderActiveBreaksPreferencesService
          .setDefaultSecondsRemainingNextActiveBreak(
              defaultSecondsRemainingNextActiveBreak);
      setState(() {});
    });
    /*    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('Edición'),
              content: const Row(
                children: [
                  Text('¿Cada cuánto quieres tomar las pausas activas?'),
                ],
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      label: const Text(''),
                      onPressed: () {},
                      icon:
                          const Icon(size: 40, color: Colors.red, Icons.cancel),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      label: const Text(''),
                      onPressed: () {},
                      icon:
                          const Icon(size: 40, color: Colors.green, Icons.save),
                    )
                  ],
                ),
              ]);
        });*/
  }

  // Convertir los segundos restantes en formato de minutos:segundos
  String formatTime(int secondstoParse) {
    TimeFormat time = secondsToTime(secondstoParse);
    String minutes = time.minutes;
    String seconds = time.seconds;
    return '${minutes.toString()}:${seconds.toString()}';
  }

  TimeFormat secondsToTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return TimeFormat(minutes.toString().padLeft(2, '0'),
        remainingSeconds.toString().padLeft(2, '0'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordatorio de Pausas Activas'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Próxima pausa activa en:',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 10),
              Text(
                'Hora inicio contador: ${activePauseCounterStartTime.toLocal().hour}:${activePauseCounterStartTime.minute}:${activePauseCounterStartTime.second}',
                style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
              ),
              const SizedBox(height: 5),
              Text(
                'Hora ultimo conteo: ${activePauseCounterLastTime.toLocal().hour}:${activePauseCounterLastTime.minute}:${activePauseCounterLastTime.second}',
                style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
              ),
              const SizedBox(height: 10),
              // Tiempo restante para la proxima pausa activa
              Text(
                formatTime(secondsRemainingNextActiveBreak),
                style:
                    const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              // Sección para preguntar si ya tomó la pausa activa
              ...(timerDidYouTakeActivePauseIsUp
                  ? [
                      const Text(
                        'Te preguntaremos si tomaste esta pausa activa dentro de:',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        formatTime(secondsRemainingDidYouTakeActivePause),
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 40),
                    ]
                  : [const SizedBox(height: 0)]),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  !timerNextActiveBreakIsUp
                      ? ElevatedButton(
                          onPressed: () {
                            startTimerNextActiveBreak();
                          },
                          child: const Icon(
                              size: 40,
                              color: Colors.green,
                              Icons.not_started_sharp),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            pauseTimerNextActiveBreak();
                          },
                          child: const Icon(
                              size: 40, color: Colors.green, Icons.pause),
                        ),
                  ElevatedButton(
                    onPressed: () {
                      stopTimerDidYouTakeActivePause();
                      stopTimerNextActiveBreak();
                    },
                    child: const Icon(size: 40, color: Colors.red, Icons.stop),
                  ),
                ],
              ),
              ...(timerDidYouTakeActivePauseIsUp
                  ? [
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: const ButtonStyle(
                            fixedSize: WidgetStatePropertyAll(Size(300, 70))),
                        onPressed: () {
                          stopTimerNextActiveBreak();
                          startTimerNextActiveBreak();
                        },
                        child: const Text(
                          'Ya tomé mi pausa activa 🥳',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Levantate 🙆🏻‍!',
                        // Muestra el tiempo restante
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Hidratate 💧!',
                        // Muestra el tiempo restante
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Estira 💆🏻‍!',
                        // Muestra el tiempo restante
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      )
                    ]
                  : [const SizedBox(height: 0)]),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _showEditOptions(context);
          //_showOverlay();
        },
        tooltip: 'Editar',
        child: const Icon(
          Icons.edit,
          size: 40,
        ),
      ),
/*      persistentFooterButtons: [
        FloatingActionButton(
          onPressed: () async {
            _showOverlay();
            //_showOverlay();
          },
          tooltip: 'Mostrar Widget Flotante',
          child: const Icon(
            Icons.opacity,
            size: 40,
          ),
        ),
      ],*/
    );
  }

  @override
  void dispose() {
    timerNextActiveBreak.cancel(); // Cancela el temporizador al cerrar la app
    //selectNotificationStream.close();
    super.dispose();
  }
}
