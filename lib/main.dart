import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'account.dart';
import 'constants.dart';
import 'home.dart';
import 'package:flutter_projects/services/Router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

late var prefs;
late var storage;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
String empno = '';
String user = '';
String designation = '';
String discipline = '';
String grade = '';
String auth_token = '';
late GlobalKey<NavigatorState> navigatorKey;

void main() async{
  // handle exceptions caused by making main async
  WidgetsFlutterBinding.ensureInitialized();

  navigatorKey = new GlobalKey<NavigatorState>();

  flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
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

Future<void> showNotification(Map<String, dynamic> downloadStatus) async {
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
  final json = jsonEncode(downloadStatus);
  final isSuccess = downloadStatus['isSuccess'];

  await flutterLocalNotificationsPlugin.show(
      0, // notification id
      isSuccess ? 'File Download Successful.' : 'File Download Failed',
      isSuccess ? 'Tap to Open File' : 'There was an error while downloading the file.',
      platform,
      payload: json
  );
}

Future onSelectNotification(String? json) async {
  //  handling clicked notification
  final obj = jsonDecode(json!);

  if (obj['isSuccess']) {
    OpenFile.open(obj['filePath']);
  }
  else {
    // showDialog(
    //   context: context,
    //   builder: (_) => AlertDialog(
    //     title: Text('Error'),
    //     content: Text('${obj['error']}'),
    //   ),
    // );
  }
}


