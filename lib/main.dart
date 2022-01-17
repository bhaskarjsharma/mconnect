import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';
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

//String app_theme = 'kindness';
late Color startColor;
late Color endColor;
late Color textColor;
late Color appBarBackgroundColor;
late Color appBarTextColor;
double appBarElevation = 0;
late var statusBarBrightness;

ConnectivityResult connectionStatus = ConnectivityResult.mobile;
bool isLoggedIn = false;
late var prefs;
late var themePrefs;
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

/// FlutterLocalNotificationsPlugin Config Starts ******************************************************
/// Initialize the [FlutterLocalNotificationsPlugin] package.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

/// FlutterLocalNotificationsPlugin Config Ends ******************************************************

/// Define a top-level named handler which background/terminated messages will
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //print('Handling a background message ${message.notification!.body}');
  var appNotificationBox = await Hive.openBox<AppNotification>('appNotifications');
  AppNotification newNotification = new AppNotification(
      notificationTitle: message.notification!.title!,
      notificationBody: message.notification!.body!,
      contentType: message.data['contentType'] ?? '',
      contentID: message.data['contentID'] ?? '');
  appNotificationBox.add(newNotification);

/*  prefs = await SharedPreferences.getInstance();
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
  }*/
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized(); // handle exceptions caused by making main async.
  navigatorKey = new GlobalKey<NavigatorState>();

  await Hive.initFlutter();
  Hive.registerAdapter(EmployeeAdapter());
  Hive.registerAdapter(LeaveQuotaAdapter());
  Hive.registerAdapter(DocumentAdapter());
  Hive.registerAdapter(HolidayListAdapter());
  Hive.registerAdapter(ITACMasterDataAdapter());
  Hive.registerAdapter(NewsContentAdapter());
  Hive.registerAdapter(HospCrLtrMasterDataAdapter());
  Hive.registerAdapter(AppNotificationAdapter());
  Hive.registerAdapter(EmpProfileDataAdapter());
  Hive.registerAdapter(EmpAddressDataAdapter());
  Hive.registerAdapter(EmpTrainingDataAdapter());
  Hive.registerAdapter(EmpDependentDataAdapter());
  Hive.registerAdapter(EmpNomineeDataAdapter());

  await Hive.openBox<NewsContent>('newsContent');
  await Hive.openBox<Employee>('employeeList');
  await Hive.openBox('leaveQuota');
  await Hive.openBox<HolidayList>('holidayList');
  await Hive.openBox<ITACMasterData>('itacMaster');
  await Hive.openBox<HospCrLtrMasterData>('hospCrLtrMaster');
  await Hive.openBox<AppNotification>('appNotifications');
  await Hive.openBox('userProfile');

  //Firebase configs start
  await Firebase.initializeApp();
  messaging = FirebaseMessaging.instance;
  messaging.subscribeToTopic('all');
  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
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

  /// FlutterLocalNotificationsPlugin Config Starts ******************************************************

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings();
  /* final IOSInitializationSettings initializationSettingsIOS =
  IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (
          int id,
          String? title,
          String? body,
          String? payload,
          ) async {
        didReceiveLocalNotificationSubject.add(
          ReceivedNotification(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ),
        );
      });*/

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: onSelectNotification);

  /// FlutterLocalNotificationsPlugin Config Ends ******************************************************

/*  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  final android = AndroidInitializationSettings('@mipmap/ic_launcher');
  final iOS = IOSInitializationSettings();
  final initSettings = InitializationSettings(android: android, iOS: iOS);
  flutterLocalNotificationsPlugin.initialize(initSettings, onSelectNotification: onSelectNotification);*/

  prefs = await SharedPreferences.getInstance();
  themePrefs = await SharedPreferences.getInstance(); //different shared pref for theme data which will not be cleared during logout

  //set theme colour from saved data, else set to kindness theme
  startColor = stringToColor(themePrefs.getString('startColor') ?? 'e9defa');
  endColor = stringToColor(themePrefs.getString('endColor') ?? 'fbfcdb');
  textColor = stringToColor(themePrefs.getString('textColor') ?? '000000');
  appBarBackgroundColor = stringToColor(themePrefs.getString('appBarBackgroundColor') ?? 'transparent');
  appBarTextColor = stringToColor(themePrefs.getString('appBarTextColor') ?? '000000');
  statusBarBrightness = stringToBrightness(themePrefs.getString('statusBarBrightness') ?? 'dark');

  storage = new FlutterSecureStorage();
  isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  if(isLoggedIn){
    auth_token = await storage.read(key: 'auth_token');
    //validate token for expiry time
    bool hasExpired = JwtDecoder.isExpired(auth_token);
    if(!hasExpired){
      empno = await storage.read(key: 'empno');
      user = await storage.read(key: 'name');
      designation = await storage.read(key: 'desg');
      discipline = await storage.read(key: 'disc');
      grade = await storage.read(key: 'grade');
      localAuthEnabled = prefs.getBool('localBioAuth') ?? false;

      runApp(MaterialApp(
        title: "Home",
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.transparent),
            backgroundColor: Colors.transparent,
            elevation: 0,
            //backgroundColor: Color.fromRGBO(165, 231, 206, 1.0),
            //backgroundColor: Color.fromRGBO(255, 239, 186, 1.0),
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

/*class MyAppSplash extends StatelessWidget {
  const MyAppSplash({Key? key}) : super(key: key);

  // This widget is the root. Created for common splash for login and home views
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Init.instance.initialize(),
      builder: (context, AsyncSnapshot snapshot) {
        // Show splash screen while waiting for app resources to load:
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(home: Splash());
        } else {
          // Loading is done, return the app:
          if(isLoggedIn){
            //Home screen
            return MaterialApp(
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
            );
          }
          else{
            //Login screen
            return MaterialApp(
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
            );
          }
        }
      },
    );
  }
}
class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white ,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Lottie.asset('animations/ani_rocket.json',
                width: 200,
                height: 200,)),
        ],
      )

    );
  }
}
class Init {
  Init._();
  static final instance = Init._();

  Future initialize() async {
    // This is where you can initialize the resources needed by your app while
    // the splash screen is displayed.
    await Hive.initFlutter();
    Hive.registerAdapter(EmployeeAdapter());
    Hive.registerAdapter(LeaveQuotaAdapter());
    Hive.registerAdapter(DocumentAdapter());
    Hive.registerAdapter(HolidayListAdapter());
    Hive.registerAdapter(ITACMasterDataAdapter());
    Hive.registerAdapter(NewsContentAdapter());
    Hive.registerAdapter(HospCrLtrMasterDataAdapter());
    Hive.registerAdapter(AppNotificationAdapter());

    await Hive.openBox<NewsContent>('newsContent');
    await Hive.openBox('leaveQuota');
    await Hive.openBox<HolidayList>('holidayList');
    await Hive.openBox<ITACMasterData>('itacMaster');
    await Hive.openBox<HospCrLtrMasterData>('hospCrLtrMaster');
    await Hive.openBox<AppNotification>('appNotifications');

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
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if(isLoggedIn){
      //set variables for logged in user
      empno = await storage.read(key: 'empno');
      user = await storage.read(key: 'name');
      designation = await storage.read(key: 'desg');
      discipline = await storage.read(key: 'disc');
      grade = await storage.read(key: 'grade');
      auth_token = await storage.read(key: 'auth_token');
      localAuthEnabled = prefs.getBool('localBioAuth') ?? false;
    }
    else{
      prefs.clear();
      storage.deleteAll();
    }
  }
}*/

Future<void> showNotification(Map<String, dynamic> notificationMessage) async {
  const AndroidNotificationDetails android =
  AndroidNotificationDetails('channel id','channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      ticker: 'ticker');

/*  final android = AndroidNotificationDetails(
    'channel id',
    'channel name',
    'channel description',
    priority: Priority.high,
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );*/
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
  else if(obj['contentType'] == 'AppUpdate'){
    navigatorKey.currentState!.pushNamed('/AboutApp');
  }
  else{
    navigatorKey.currentState!.pushNamed('/NotificationView');
  }
}


