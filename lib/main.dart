import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'account.dart';
import 'app_drawer.dart';
import 'constants.dart';
import 'home.dart';
import 'package:flutter_projects/services/Router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'models/models.dart';

late var prefs;
late var storage;
String empno = '';
String user = '';
String designation = '';
String discipline = '';
String grade = '';
String auth_token = '';
late GlobalKey<NavigatorState> navigatorKey;
bool notificationPresent = false;
bool localAuthEnabled = false;
final LocalAuthentication localAuth = LocalAuthentication();

late FirebaseMessaging messaging;
/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;
/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

/// Define a top-level named handler which background/terminated messages will
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //print('Handling a background message ${message.notification!.body}');
  prefs = await SharedPreferences.getInstance();
  final String savedNotificationList = prefs.getString('savedNotification') ?? '';
  if(savedNotificationList != ''){
    final List<AppNotification> notList = AppNotification.decode(savedNotificationList);
    if(notList.isNotEmpty){
      AppNotification newNotification = new AppNotification(
          notificationTitle: message.notification!.title!,
          notificationBody: message.notification!.title!,
          contentType: message.data['contentType'] ?? '',
          contentID: message.data['contentID'] ?? '');
      notList.add(newNotification);
      final String encodedData = AppNotification.encode(notList);
      prefs.setString('savedNotification', encodedData);
    }
    else{
      List<AppNotification> notList = [];
      AppNotification newNotification = new AppNotification(
          notificationTitle: message.notification!.title!,
          notificationBody: message.notification!.title!,
          contentType: message.data['contentType'] ?? '',
          contentID: message.data['contentID'] ?? '');
      notList.add(newNotification);
      final String encodedData = AppNotification.encode(notList);
      prefs.setString('savedNotification', encodedData);
    }
  }
  else{
    List<AppNotification> notList = [];
    AppNotification newNotification = new AppNotification(
        notificationTitle: message.notification!.title!,
        notificationBody: message.notification!.title!,
        contentType: message.data['contentType'] ?? '',
        contentID: message.data['contentID'] ?? '');
    notList.add(newNotification);
    final String encodedData = AppNotification.encode(notList);
    prefs.setString('savedNotification', encodedData);
  }
}

void main() async{
  // handle exceptions caused by making main async
  WidgetsFlutterBinding.ensureInitialized();
  navigatorKey = new GlobalKey<NavigatorState>();

  await Hive.initFlutter();
  Hive.registerAdapter(EmployeeAdapter());

  //Firebase configs start
  await Firebase.initializeApp();
  messaging = FirebaseMessaging.instance;
  messaging.subscribeToTopic('all');
  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.max,
  );
  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance
      .setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  // Firebase configs end


  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  final android = AndroidInitializationSettings('@mipmap/ic_launcher');
  final iOS = IOSInitializationSettings();
  final initSettings = InitializationSettings(android: android, iOS: iOS);
  flutterLocalNotificationsPlugin.initialize(initSettings, onSelectNotification: onSelectNotification);

  prefs = await SharedPreferences.getInstance();
  storage = new FlutterSecureStorage();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  if(isLoggedIn){
    empno = await storage.read(key: 'empno');
    user = await storage.read(key: 'name');
    designation = await storage.read(key: 'desg');
    discipline = await storage.read(key: 'disc');
    grade = await storage.read(key: 'grade');
    auth_token = await storage.read(key: 'auth_token');
    localAuthEnabled = prefs.getBool('localBioAuth') ?? false;



    runApp(MaterialApp(
      title: "Home",
      theme: ThemeData(
          appBarTheme: AppBarTheme(
            backgroundColor: Color.fromRGBO(165, 231, 206, 1.0),
          ),
      ),
      home: Home(),
      onGenerateRoute: NavigationRouter.generateRoute,
      initialRoute: homeRoute,
      navigatorKey: navigatorKey,
    ));
  }
  else{
    prefs.clear();
    storage.deleteAll();
    runApp(MaterialApp(
      theme: ThemeData(
          appBarTheme: AppBarTheme(
            backgroundColor: Color.fromRGBO(165, 231, 206, 1.0),
          ),
          textTheme: const TextTheme(
          headline1: TextStyle(fontSize: 23.0, fontWeight: FontWeight.bold,),
          ),
      ),
      title: "Login",
      home: Login(),
      onGenerateRoute: NavigationRouter.generateRoute,
      initialRoute: loginRoute,
    ));
  }

}


Future<void> showNotification(Map<String, dynamic> notificationMessage) async {
  final android = AndroidNotificationDetails(
    'channel id',
    'channel name',
    'channel description',
    priority: Priority.high,
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );
  final iOS = IOSNotificationDetails();
  final platform = NotificationDetails(android: android, iOS: iOS);
  final json = jsonEncode(notificationMessage);
  final isSuccess = notificationMessage['isSuccess'];

  String notificationTitle = '';
  String notificationBody = '';

  if(notificationMessage['contentType'] == 'FileDownload'){
    if(isSuccess){
      notificationTitle = 'File Download Successful';
      notificationBody = 'Tap to Open File';
    }
    else{
      notificationTitle = 'File Download Failed';
      notificationBody = 'There was an error while downloading the file';
    }
  }
  else{
    notificationTitle = notificationMessage['title'];
    notificationBody = notificationMessage['body'];
  }

  await flutterLocalNotificationsPlugin.show(
      0, // notification id
      notificationTitle,
      notificationBody,
      platform,
      payload: json
  );
}
Future onSelectNotification(String? json) async {
  //  handling clicked notification
  final obj = jsonDecode(json!);

  if(obj['contentType'] == 'FileDownload'){
    if (obj['isSuccess']) {
      OpenFile.open(obj['filePath']);
    }
    else{}
  }
  else if(obj['contentType'] == 'News'){
    if (obj['contentID'] != '') {
      //navigatorKey.currentState!.pushNamed('/NewsDisplay', arguments: obj['contentID'] );
      navigatorKey.currentState!.pushNamed('/NewsDisplay', arguments: NewsWithAttchArguments(
          obj['contentID']),
      );
    }
    else{
      navigatorKey.currentState!.pushNamed('/NotificationView');
    }
  }
  else{
    navigatorKey.currentState!.pushNamed('/NotificationView');
  }
}


