
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mat_month_picker_dialog/mat_month_picker_dialog.dart';
import 'app_drawer.dart';
import 'fonts_icons/connect_app_icon_icons.dart';
import 'package:flutter_projects/services/webservice.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'main.dart';
import 'models/models.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:local_auth/local_auth.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home>  {
  //Local biometric authentication

  List<BiometricType>? _availableBiometrics;
  bool _isAuthenticating = false;
  bool _isAuthenticated = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  //late FirebaseMessaging messaging;
  bool isConnected = false;
  // ConnectivityResult _connectionStatus = ConnectivityResult.mobile; // moved to main
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  late DioClient _dio;
  late var _endpointProvider;
  late Future<APIResponseData> _apiResponseData;

  String notTitle = '';
  String notBody = '';

  late  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final _peopleFormKey = GlobalKey<FormState>();
  final _documentFormKey = GlobalKey<FormState>();
  final _paySlipFormKey = GlobalKey<FormState>();
  final _attendanceFormKey = GlobalKey<FormState>();
  final _shiftRosterFormKey = GlobalKey<FormState>();
  final _claimsFormKey = GlobalKey<FormState>();
  final _attRegulFormKey = GlobalKey<FormState>();
  final _itacFormKey = GlobalKey<FormState>();

  final empNameContrl = TextEditingController();
  String _empUnit = '';
  String _empDisc = '';
  String _empBldGrp = '';

  final docNameContrl = TextEditingController();
  String _documentCategory = '';

  final monthContrl = TextEditingController();
  final yearContrl = TextEditingController();
  late DateTime payslipSelectedDate;

  final attendanceFromDateContrl = TextEditingController();
  final attendanceToDateContrl = TextEditingController();
  DateTime attendanceSelectedFromDate = DateTime.now();
  DateTime attendanceSelectedToDate = DateTime.now();

  final shiftFromDateContrl = TextEditingController();
  final shiftToDateContrl = TextEditingController();
  DateTime shiftSelectedFromDate = DateTime.now();
  DateTime shiftSelectedToDate = DateTime.now();

  final claimsFromDateContrl = TextEditingController();
  final claimsToDateContrl = TextEditingController();
  DateTime claimsSelectedFromDate = DateTime.now();
  DateTime claimsSelectedToDate = DateTime.now();

  final attRegInTimeContrl = TextEditingController();
  final attRegOutTimeContrl = TextEditingController();
  final attRegReasonContrl = TextEditingController();
  DateTime attRegIntime = DateTime.now();
  DateTime attRegOutTime = DateTime.now();

  bool isLoading = false;

  late List<Employee> peopleData;
  late List<Document> documentList;
  late List<ClaimData> claimsData;
  late List<PayrollData> payrollData;
  late List<AttendanceData> attendanceData;
  late List<ShiftRoster> shiftRosterData;

  late List<String> empUnitList;
  late List<String> empDiscList;
  late List<String> empBldGrpList;

  String _claimsType = '';
  ClaimType? _claimsTypeObj;
  static String claimTypeData = '''
  [
    {"claimType":"Z6C1", "claimDesc":"(6.10.C.i) Light Refreshment"},
    {"claimType":"Z6C2", "claimDesc":"(6.10.C.ii) Working Meal"},
    {"claimType":"Z6C3", "claimDesc":"(6.10.C.iii) Entertainment & Others"},
    {"claimType":"ZBAG", "claimDesc":"Briefcase/Handbag Reimbursement"},
    {"claimType":"COFF", "claimDesc":"Coff Encashment"},
    {"claimType":"LEEN", "claimDesc":"Leave Encashment"},
    {"claimType":"ZHO1", "claimDesc":"Medical Reimbursement"},
    {"claimType":"ZMOI", "claimDesc":"Mobile Handset Reimbursement"},
    {"claimType":"ZOPE", "claimDesc":"Out of Pocket Expense"},
    {"claimType":"ZOTM", "claimDesc":"Overtime Allowance"},
    {"claimType":"ZSPE", "claimDesc":"Spectacle Reimbursement"},
    {"claimType":"ZMOB", "claimDesc":"Tel/Cell Call Charges Reimbursement"}
    ]
  ''';

  List<ClaimType> claimTypes = List<ClaimType>.from(json.decode(claimTypeData).map((x) => ClaimType.fromJson(x)));

  @override
  void initState(){
    //OpenHiveBox();
    super.initState();
    _dio = new DioClient();
    _endpointProvider = new EndPointProvider(_dio.init());
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

/*    startColor = stringToColor(prefs.getString('startColor') ?? 'white');
    endColor = stringToColor(prefs.getString('endColor') ?? 'white');
    textColor = stringToColor(prefs.getString('textColor') ?? 'black');
    appBarBackgroundColor = stringToColor(prefs.getString('appBarBackgroundColor') ?? 'blue');
    appBarTextColor = stringToColor(prefs.getString('appBarTextColor') ?? 'white');
    statusBarBrightness = stringToBrightness(prefs.getString('statusBarBrightness') ?? 'light');*/

    empUnitList = ['','BUSINESS DEVELOPMENT','Business Information System','C&P','Civil','Company Secretary','COO Office',
      'CPP','DF Cell','Duliajan','ECU','Electrical','Environment','Finance & Accounts','Fire & Safety','GM Office','GSU',
      'Human Resource','Instrumentation','Internal Audit','IOP','IT','Laboratory','Lakwa','Law','LLDPE/HDPE','Marketing',
      'MD Office','Mechanical Maint.','Noida Office','Offsite','Operation & Maintenance','Pipeline','PPU','PRCC','Product Transfer & Dispatch',
      'Project','Security','Sourcing & Logistics','Technical Services','Telecom','Vigilance'];
    empDiscList = ['','BIS','C&P','Chemical','Civil','Corporate','CS','Electrical','Environment','Finance','Finance&Account',
      'Fire & Safety','Hindi','Human Resource','Instrumentation','IT','Laboratory','Law','Marketing','Mechanical','O&M',
      'PE','PRCC','S&P','Security','Steno','Telecom'];
    empBldGrpList = ['','A-','A+','AB-','AB+','B-','B+','O-','O+'];

    if(localAuthEnabled){
      _authenticateLocal();
    }
    else{
      setState((){
        _isAuthenticated = true;
      });
    }

    //Firebase configs starts
    registerNotification();
    checkForInitialMessage();
    //Instantiate Firebase Messaging //moved to main
    //messaging = FirebaseMessaging.instance; //moved to main
    //messaging.subscribeToTopic('all');  //moved to main

    // For handling notification when the app is in background but not terminated
    // For handling the notification tap/open function
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleMessage(message);
    });
    //Firebase configs ends
  }

/*  void OpenHiveBox() async{
    await Hive.openBox<NewsContent>('newsContent');
    await Hive.openBox('leaveQuota');
    await Hive.openBox<HolidayList>('holidayList');
    await Hive.openBox<ITACMasterData>('itacMaster');
    await Hive.openBox<HospCrLtrMasterData>('hospCrLtrMaster');
    await Hive.openBox<AppNotification>('appNotifications');
  }*/

  void registerNotification() async {

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      //print('User granted permission');

      // for foreground message
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        setState((){
          notificationPresent = true;
        });

        final appNotificationBox = Hive.box<AppNotification>('appNotifications');
        AppNotification newNotification = new AppNotification(
            notificationTitle: message.notification!.title!,
            notificationBody: message.notification!.body!,
            contentType: message.data['contentType'] ?? '',
            contentID: message.data['contentID'] ?? '');
        appNotificationBox.add(newNotification);

        // call local notification to display notification
        Map<String, dynamic> result = {
          'contentType': 'PushNotification',
          'title': message.notification!.title!,
          'body': message.notification!.body!,
          'contentID': '',
        };

        if(message.data['contentType'] == 'News'){
          result['contentType'] = 'News';
        }
        if(message.data['contentID'] != null){
          result['contentID'] = message.data['contentID'];
        }
        showNotification(result);

      });
    } else {
      print('User declined or has not accepted permission');
    }
  }

  // For handling notification when the app is in terminated state
  checkForInitialMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      setState((){
        notificationPresent = true;
      });

      final appNotificationBox = Hive.box<AppNotification>('appNotifications');
      AppNotification newNotification = new AppNotification(
          notificationTitle: initialMessage.notification!.title!,
          notificationBody: initialMessage.notification!.body!,
          contentType: initialMessage.data['contentType'] ?? '',
          contentID: initialMessage.data['contentID'] ?? '');
      appNotificationBox.add(newNotification);
    }
  }

  void _handleMessage(RemoteMessage message) {
    //handle notification click function
    //open notification view page
    Navigator.pushNamed(context, notificationRoute);
  }

  Future<void> _authenticateLocal() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
      });
      authenticated = await localAuth.authenticate(
          localizedReason: 'Please complete the authentication to proceed',
          useErrorDialogs: true,
          stickyAuth: true);
      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _isAuthenticating = false;
        _isAuthenticated = authenticated;
      });
    }
    setState(() => _isAuthenticated = authenticated);
  }

  Future<void> _authenticateLocalWithBiometrics() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
      });
      authenticated = await localAuth.authenticate(
          localizedReason:
          'Please complete the biometric authentication to proceed',
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true
      );
      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _isAuthenticating = false;
      });
    }
    setState(() {
      _isAuthenticated = authenticated;
    });
  }
  void _cancelAuthentication() async {
    await localAuth.stopAuthentication();
    setState(() => _isAuthenticating = false);
  }
  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
    //Hive.close();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              //colors: [Color.fromRGBO(255, 239, 186, 1), Color.fromRGBO(255, 255, 255, 1)]
              colors: [startColor, endColor]
          )
      ),
      child: getScaffold(),
    );
  }

  Scaffold getScaffold(){
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: appBarTextColor
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: appBarBackgroundColor,
            statusBarIconBrightness: statusBarBrightness,),
        backgroundColor: appBarBackgroundColor,
        bottomOpacity: 0.0,
        elevation: appBarElevation,  // removes appbar shadow
        leading: Container(
          width: 40,
          child: Image.asset('images/bcpl_logo.png'),
        ),
        title: Row(
          children:[
            Text('Connect',style: TextStyle(
              color:appBarTextColor,
            ),),
            Spacer(),
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                setState((){
                  notificationPresent = false;
                });
                Navigator.pushNamed(context, notificationRoute);
              },
              color: notificationPresent ? Colors.red : appBarTextColor,
            )
          ],
        ),
      ),
      endDrawer: AppDrawer(),
      body: _isAuthenticated ? Container(
        //padding:EdgeInsets.only(top: 10),
        child: Column(
          children: [
            connectionStatus != ConnectivityResult.none ? SizedBox(height:0) : noConnectivityError(),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                padding: EdgeInsets.all(10.0), // 3px padding all around

                children: <Widget>[
                  makeDashboardItem("News & Events",const Icon(ConnectAppIcon.newspaper,size:30, color:Colors.blue),Colors.blue,newsRoute),
                  makeDashboardItem("People",const Icon(ConnectAppIcon.users,size:30, color:Colors.pink),Colors.pink,peopleRoute),
                  makeDashboardItem("Documents",const Icon(ConnectAppIcon.article_alt,size:30, color:Colors.green),Colors.green,documentsRoute),
                  makeDashboardItem("Leave Quota",const Icon(Icons.info,size:30, color:Colors.cyan),Colors.orange,leaveQuotaRoute),
                  makeDashboardItem("Holiday List",const Icon(ConnectAppIcon.calendar,size:30, color:Colors.brown),Colors.brown,holidayListRoute),
                  makeDashboardItem("Payslips", const Icon(ConnectAppIcon.rupee_sign,size:30, color:Colors.orange),Colors.cyan,payslipRoute),
                  makeDashboardItem("Punch Time",const Icon(Icons.fingerprint,size:30, color:Colors.red),Colors.deepPurple,attendanceRoute),
                  makeDashboardItem("Shift Roster",const Icon(ConnectAppIcon.calendar_alt,size:30, color:Colors.teal),Colors.teal,shiftRosterRoute),
                  makeDashboardItem("Claims",const Icon(Icons.receipt,size:30, color:Colors.deepPurple),Colors.red,homeRoute),
                  makeDashboardItem("Regularise Attendance",const Icon(Icons.schedule,size:30, color:Colors.deepPurple),Colors.red,homeRoute),
                  makeDashboardItem("ITAC",const Icon(Icons.computer,size:30, color:Colors.blue),Colors.red,itacRoute),
                  makeDashboardItem("ECOFF & Overtime",const Icon(Icons.payments,size:30, color:Colors.lime),Colors.red,ecofOTRoute),
                  makeDashboardItem("Hosp. Credit Letter",const Icon(Icons.medical_services,size:30, color:Colors.red),Colors.red,hosCrLtrRoute),
                  makeDashboardItem("Quiz",const Icon(Icons.quiz,size:30, color:Colors.orange),Colors.orange,quizRoute),
                ],
              ),
            ),

          ],
        ),
      ): Center(child:Text('Authentication not complete'),),
    );
  }

  Widget makeDashboardItem(String title, Widget icon, MaterialColor colour, String routeName){
    return Container(
      decoration: BoxDecoration(
        //color:Colors.white10,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: Colors.transparent,
          width: 1,
        ),
        color: Colors.transparent,
      ),
      child: InkWell(
        onTap: (){
          if(title == "People"){
            showDialog(
              context: context,
              builder: (context){
                return StatefulBuilder(
                  builder: (context, setState){
                    return AlertDialog (
                      insetPadding: EdgeInsets.all(0),
                      content: Builder(
                        builder: (context) {
                          // Get available height and width of the build area of this widget. Make a choice depending on the size.
                          var height = MediaQuery.of(context).size.height;
                          var width = MediaQuery.of(context).size.width;

                          return Container(
                            height: height - (height/2.3),
                            width: width - (width/4),
                            child: isLoading ? waiting(context) :

                            Form(
                              key: _peopleFormKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,

                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(top:10,bottom:10),
                                    child: Center(child: Text('Find Employees',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 20,
                                          color: Colors.blue[500],
                                        ))) ,
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(top:10,bottom:10),
                                    child: TextFormField(
                                      controller: empNameContrl,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Employee Name (Optional)',
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(top:10,bottom:10),
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Unit (Optional)',
                                        contentPadding: const EdgeInsets.only(left: 10.0),
                                        border: const OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(

                                          isExpanded: true,
                                          icon: Icon(Icons.keyboard_arrow_down),
                                          value: _empUnit,
                                          style: TextStyle(color: Colors.black),
                                          items: empUnitList.map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),

                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _empUnit = newValue!;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(top:10,bottom:10),
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Discipline (Optional)',
                                        contentPadding: const EdgeInsets.only(left: 10.0),
                                        border: const OutlineInputBorder(),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _empDisc,
                                          style: TextStyle(color: Colors.black),
                                          items: empDiscList.map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _empDisc = newValue!;
                                            });
                                          },
                                        ),
                                      ),
                                    ),

                                  ),
                                  Container(
                                    padding: EdgeInsets.only(top:10,bottom:10),
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Blood Group (Optional)',
                                        //labelStyle: Theme.of(context).primaryTextTheme.caption!.copyWith(color: Colors.black),
                                        contentPadding: const EdgeInsets.only(left: 10.0),
                                        border: const OutlineInputBorder(),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _empBldGrp,
                                          style: TextStyle(color: Colors.black),
                                          items: empBldGrpList.map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _empBldGrp = newValue!;
                                            });
                                          },
                                        ),
                                      ),
                                    ),

                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async{
                                            setState(() {
                                              isLoading = true;
                                            });

                                            final employeeBox = await Hive.openBox<Employee>('employeeList');
                                            //final employeeBox = Hive.box<Employee>('employeeList');
                                            if(employeeBox.values.isEmpty){
                                              if(connectionStatus != ConnectivityResult.none){
                                                _apiResponseData = _endpointProvider.fetchEmployees(empNameContrl.text,_empUnit,_empDisc,_empBldGrp);
                                                _apiResponseData.then((result) {
                                                  if(result.isAuthenticated && result.status){
                                                    final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
                                                    setState(() {
                                                      empNameContrl.text = '';
                                                      _empUnit = '';
                                                      _empDisc = '';
                                                      _empBldGrp = '';
                                                      peopleData =  parsed.map<Employee>((json) => Employee.fromJson(json)).toList();
                                                      isLoading = false;
                                                    });
                                                    employeeBox.addAll(peopleData);
                                                    Navigator.pop(context);
                                                    Navigator.pushNamed(context, peopleRoute, arguments: peopleData,);
                                                  }
                                                  else{
                                                    setState(() {
                                                      empNameContrl.text = '';
                                                      _empUnit = '';
                                                      _empDisc = '';
                                                      _empBldGrp = '';
                                                      isLoading = false;
                                                    });
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text("Error in data fetching")),
                                                    );
                                                  }
                                                }).catchError( (error) {
                                                  setState(() {
                                                    empNameContrl.text = '';
                                                    _empUnit = '';
                                                    _empDisc = '';
                                                    _empBldGrp = '';
                                                    isLoading = false;
                                                  });
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text("Error in data fetching")),
                                                  );
                                                });
                                              }
                                              else{
                                                setState(() {
                                                  empNameContrl.text = '';
                                                  _empUnit = '';
                                                  _empDisc = '';
                                                  _empBldGrp = '';
                                                  isLoading = false;
                                                });
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text("No internet connection. Please check your settings")),
                                                );
                                              }
                                            }
                                            else{
                                              setState(() {
                                                peopleData = employeeBox.values.toList();
                                              });
                                              if(empNameContrl.text.isNotEmpty){
                                                peopleData = peopleData.where((element) => element.emp_name!.toUpperCase().contains(empNameContrl.text.toUpperCase())).toList();
                                              }
                                              if(_empUnit != ''){
                                                peopleData = peopleData.where((element) => element.emp_unit!.toUpperCase() == _empUnit.toUpperCase()).toList();
                                              }
                                              if(_empUnit != ''){
                                                peopleData = peopleData.where((element) => element.emp_unit!.toUpperCase() == _empUnit.toUpperCase()).toList();
                                              }
                                              if(_empDisc != ''){
                                                peopleData = peopleData.where((element) => element.emp_discipline!.toUpperCase() == _empDisc.toUpperCase()).toList();
                                              }
                                              if(_empBldGrp != ''){
                                                peopleData = peopleData.where((element) => element.emp_bloodgroup!.toUpperCase() == _empBldGrp.toUpperCase()).toList();
                                              }
                                              setState(() {
                                                empNameContrl.text = '';
                                                _empUnit = '';
                                                _empDisc = '';
                                                _empBldGrp = '';
                                                isLoading = false;
                                                //peopleData = employeeBox.values.toList();
                                              });
                                              Navigator.pop(context);
                                              Navigator.pushNamed(context, peopleRoute, arguments: peopleData,);
                                            }

                                          },
                                          child: const Text('Submit'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              empNameContrl.text = '';
                                              _empUnit = '';
                                              _empDisc = '';
                                              _empBldGrp = '';
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Cancel'),
                                          style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all(Colors.red),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          }
          else if(title == "Documents"){
            showDialog(
              context: context,
              builder: (context){
                return StatefulBuilder(
                  builder: (context, setState){
                    return AlertDialog (
                      insetPadding: EdgeInsets.all(0),
                      content: Builder(
                        builder: (context) {
                          // Get available height and width of the build area of this widget. Make a choice depending on the size.
                          var height = MediaQuery.of(context).size.height;
                          var width = MediaQuery.of(context).size.width;

                          return Container(
                            height: height - (height/1.8),
                            width: width - (width/4),
                            child: isLoading ? waiting(context) : Form(
                              key: _documentFormKey,
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 20),
                                child:Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.only(top:10,bottom:10),
                                      child: Center(child: Text('Search for Documents',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 20,
                                            color: Colors.blue[500],
                                          ))) ,
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(top:10,bottom:10),
                                      child: TextFormField(
                                        controller: docNameContrl,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Document Name (Optional)',
                                        ),
                                      ),
                                    ),
                                    /*Container(
                                      padding: EdgeInsets.only(top:10,bottom:10),
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: 'Document Category (Optional)',
                                          contentPadding: const EdgeInsets.only(left: 10.0),
                                          border: const OutlineInputBorder(),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: _documentCategory,
                                            style: TextStyle(color: Colors.black),
                                            items: <String>[
                                              '',
                                              'A-',
                                            ].map<DropdownMenuItem<String>>((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                _documentCategory = newValue!;
                                              });
                                            },
                                          ),
                                        ),
                                      ),

                                    ),*/
                                    Container(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () async{
                                              setState(() {
                                                isLoading = true;
                                              });

                                              var documentsBox = await Hive.openBox<Document>('documentList');
                                              if(documentsBox.values.isEmpty){
                                                if(connectionStatus != ConnectivityResult.none){
                                                  _apiResponseData = _endpointProvider.fetchDocuments(docNameContrl.text,'');
                                                  _apiResponseData.then((result) {
                                                    if(result.isAuthenticated && result.status){
                                                      final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
                                                      setState(() {
                                                        docNameContrl.text = '';
                                                        _documentCategory = '';
                                                        documentList =  parsed.map<Document>((json) => Document.fromJson(json)).toList();
                                                        isLoading = false;
                                                      });
                                                      documentsBox.addAll(documentList);
                                                      Navigator.pop(context);
                                                      Navigator.pushNamed(context, documentsRoute, arguments: documentList,);
                                                    }
                                                    else{
                                                      setState(() {
                                                        docNameContrl.text = '';
                                                        _documentCategory = '';
                                                        isLoading = false;
                                                      });
                                                      Navigator.pop(context);
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text("Error in data fetching")),
                                                      );
                                                    }
                                                  }).catchError( (error) {
                                                    setState(() {
                                                      docNameContrl.text = '';
                                                      _documentCategory = '';
                                                      isLoading = false;
                                                    });
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text("Error in data fetching")),
                                                    );
                                                  });
                                                }
                                                else{
                                                  setState(() {
                                                    docNameContrl.text = '';
                                                    _documentCategory = '';
                                                    isLoading = false;
                                                  });
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text("No internet connection. Please check your settings")),
                                                  );
                                                }
                                              }
                                              else{
                                                setState((){
                                                  documentList = documentsBox.values.toList();
                                                  isLoading = false;
                                                });
                                                if(docNameContrl.text.isNotEmpty){
                                                  setState((){
                                                    documentList = documentList.where((element) => element.docDisplayName!.toUpperCase().contains(docNameContrl.text.toUpperCase())).toList();
                                                    docNameContrl.text = '';
                                                  });
                                                }
                                                Navigator.pop(context);
                                                Navigator.pushNamed(context, documentsRoute, arguments: documentList,);
                                              }

                                            },
                                            child: const Text('Submit'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                docNameContrl.text = '';
                                                _documentCategory = '';
                                              });
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Cancel'),
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all(Colors.red),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          }
          else if(title == "Payslips"){
            if(connectionStatus != ConnectivityResult.none){
              showDialog(
                context: context,
                builder: (context){
                  return StatefulBuilder(
                    builder: (context, setState){
                      return AlertDialog (
                        insetPadding: EdgeInsets.all(0),
                        content: Builder(
                          builder: (context) {
                            // Get available height and width of the build area of this widget. Make a choice depending on the size.
                            var height = MediaQuery.of(context).size.height;
                            var width = MediaQuery.of(context).size.width;

                            return Container(
                              height: height - (height/2.3),
                              width: width - (width/4),
                              child: isLoading ? waiting(context) : Form(
                                key: _paySlipFormKey,
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 20),
                                  child:Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,

                                    children: <Widget>[
                                      Container(

                                        padding: EdgeInsets.all(10),
                                        child: Center(child: Text('View Payslip',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 20,
                                              color: Colors.blue[500],
                                            ))) ,
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        child: TextFormField(
                                          controller: monthContrl,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'Payroll Period',
                                          ),
                                          onTap: (){
                                            // Below line stops keyboard from appearing
                                            FocusScope.of(context).requestFocus(new FocusNode());
                                            _selectMonth(context,monthContrl);
                                          },
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                // Validate returns true if the form is valid, or false otherwise.
                                                if (_paySlipFormKey.currentState!.validate()) {

                                                  setState(() {
                                                    isLoading = true;
                                                  });

                                                  _apiResponseData = _endpointProvider.fetchPayrollData(DateFormat('MM').format(payslipSelectedDate),DateFormat('yyyy').format(payslipSelectedDate));
                                                  _apiResponseData.then((result) {
                                                    if(result.isAuthenticated && result.status){
                                                      final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
                                                      setState(() {
                                                        monthContrl.text = '';
                                                        payrollData =  parsed.map<PayrollData>((json) => PayrollData.fromJson(json)).toList();
                                                        isLoading = false;
                                                        Navigator.pop(context);
                                                        Navigator.pushNamed(context, payslipRoute, arguments: payrollData,);
                                                      });
                                                    }
                                                    else{
                                                      setState(() {
                                                        monthContrl.text = '';
                                                        isLoading = false;
                                                      });
                                                      Navigator.pop(context);
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text("Error in data fetching")),
                                                      );
                                                    }
                                                  }).catchError( (error) {
                                                    setState(() {
                                                      monthContrl.text = '';
                                                      isLoading = false;
                                                    });
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text("Error in data fetching")),
                                                    );
                                                  });
                                                }
                                              },
                                              child: const Text('Show my payslip'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  monthContrl.text = '';
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Cancel'),
                                              style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty.all(Colors.red),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              );
            }
            else{
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("No internet connection. Please check your settings")),
              );
            }

          }
          else if(title == "Punch Time"){
            if(connectionStatus != ConnectivityResult.none){
              showDialog(
                context: context,
                builder: (context){
                  return StatefulBuilder(
                    builder: (context, setState){
                      return AlertDialog (
                        insetPadding: EdgeInsets.all(0),
                        content: Builder(
                          builder: (context) {
                            // Get available height and width of the build area of this widget. Make a choice depending on the size.
                            var height = MediaQuery.of(context).size.height;
                            var width = MediaQuery.of(context).size.width;

                            return Container(
                              height: height - (height/2.3),
                              width: width - (width/4),
                              child: isLoading ? waiting(context) : Column(
                                children:[
                                  Container(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Center(child: Text('View Biometric Punch Data',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 20,
                                          color: Colors.blue[500],
                                        ))) ,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children:[
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 0),
                                          primary: Colors.deepOrange,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(50)),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          DateTime valDate = DateTime.now();
                                          _apiResponseData = _endpointProvider.fetchAttendanceData(DateFormat('yyyy-MM-dd').format(valDate),DateFormat('yyyy-MM-dd').format(valDate));
                                          _apiResponseData.then((result) {
                                            if(result.isAuthenticated && result.status){
                                              final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
                                              setState(() {
                                                attendanceFromDateContrl.text = '';
                                                attendanceToDateContrl.text = '';
                                                attendanceData =  parsed.map<AttendanceData>((json) => AttendanceData.fromJson(json)).toList();
                                                isLoading = false;
                                                Navigator.pop(context);
                                                Navigator.pushNamed(context, attendanceRoute, arguments: attendanceData,);
                                              });
                                            }
                                            else{
                                              setState(() {
                                                attendanceFromDateContrl.text = '';
                                                attendanceToDateContrl.text = '';
                                                isLoading = false;
                                              });
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text("Error in data fetching")),
                                              );
                                            }
                                          }).catchError( (error) {
                                            setState(() {
                                              attendanceFromDateContrl.text = '';
                                              attendanceToDateContrl.text = '';
                                              isLoading = false;
                                            });
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Error in data fetching")),
                                            );
                                          });
                                        },
                                        child: const Text('Today'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          primary: Colors.blueGrey,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(50)),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          DateTime fromDate = DateTime.now().subtract(Duration(days: 7));
                                          DateTime toDate = DateTime.now();
                                          _apiResponseData = _endpointProvider.fetchAttendanceData(DateFormat('yyyy-MM-dd').format(fromDate),DateFormat('yyyy-MM-dd').format(toDate));
                                          _apiResponseData.then((result) {
                                            if(result.isAuthenticated && result.status){
                                              final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
                                              setState(() {
                                                attendanceFromDateContrl.text = '';
                                                attendanceToDateContrl.text = '';
                                                attendanceData =  parsed.map<AttendanceData>((json) => AttendanceData.fromJson(json)).toList();
                                                isLoading = false;
                                                Navigator.pop(context);
                                                Navigator.pushNamed(context, attendanceRoute, arguments: attendanceData,);
                                              });
                                            }
                                            else{
                                              setState(() {
                                                attendanceFromDateContrl.text = '';
                                                attendanceToDateContrl.text = '';
                                                isLoading = false;
                                              });
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text("Error in data fetching")),
                                              );
                                            }
                                          }).catchError( (error) {
                                            setState(() {
                                              attendanceFromDateContrl.text = '';
                                              attendanceToDateContrl.text = '';
                                              isLoading = false;
                                            });
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Error in data fetching")),
                                            );
                                          });
                                        },
                                        child: const Text('Last 7 days'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          primary: Colors.teal,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(50)),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          DateTime fromDate = new DateTime(DateTime.now().year,DateTime.now().month,1);
                                          DateTime toDate = DateTime.now();
                                          _apiResponseData = _endpointProvider.fetchAttendanceData(DateFormat('yyyy-MM-dd').format(fromDate),DateFormat('yyyy-MM-dd').format(toDate));
                                          _apiResponseData.then((result) {
                                            if(result.isAuthenticated && result.status){
                                              final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
                                              setState(() {
                                                attendanceFromDateContrl.text = '';
                                                attendanceToDateContrl.text = '';
                                                attendanceData =  parsed.map<AttendanceData>((json) => AttendanceData.fromJson(json)).toList();
                                                isLoading = false;
                                                Navigator.pop(context);
                                                Navigator.pushNamed(context, attendanceRoute, arguments: attendanceData,);
                                              });
                                            }
                                            else{
                                              setState(() {
                                                attendanceFromDateContrl.text = '';
                                                attendanceToDateContrl.text = '';
                                                isLoading = false;
                                              });
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text("Error in data fetching")),
                                              );
                                            }
                                          }).catchError( (error) {
                                            setState(() {
                                              attendanceFromDateContrl.text = '';
                                              attendanceToDateContrl.text = '';
                                              isLoading = false;
                                            });
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Error in data fetching")),
                                            );
                                          });
                                        },
                                        child: const Text('Current Month'),
                                      ),
                                    ],
                                  ),
                                  divider(),
                                  Form(
                                    key: _attendanceFormKey,
                                    child: Container(
                                      margin: EdgeInsets.symmetric(vertical: 20),
                                      child:Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,

                                        children: <Widget>[
                                          Container(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Text('Check for other period'),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(10.0),
                                            child: TextFormField(
                                              controller: attendanceFromDateContrl,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'From Date',
                                              ),
                                              onTap: (){
                                                // Below line stops keyboard from appearing
                                                FocusScope.of(context).requestFocus(new FocusNode());
                                                _selectDate(context,attendanceSelectedFromDate,attendanceFromDateContrl);
                                              },
                                              // The validator receives the text that the user has entered.
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Please enter From Date';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(10.0),
                                            child: TextFormField(
                                              controller: attendanceToDateContrl,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'To Date',
                                              ),
                                              onTap: (){
                                                // Below line stops keyboard from appearing
                                                FocusScope.of(context).requestFocus(new FocusNode());
                                                _selectDate(context,attendanceSelectedToDate,attendanceToDateContrl);
                                              },
                                              // The validator receives the text that the user has entered.
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Please enter To Date';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    // Validate returns true if the form is valid, or false otherwise.
                                                    if (_attendanceFormKey.currentState!.validate()) {
                                                      setState(() {
                                                        isLoading = true;
                                                      });

                                                      _apiResponseData = _endpointProvider.fetchAttendanceData(attendanceFromDateContrl.text,attendanceToDateContrl.text);
                                                      _apiResponseData.then((result) {
                                                        if(result.isAuthenticated && result.status){
                                                          final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
                                                          setState(() {
                                                            attendanceFromDateContrl.text = '';
                                                            attendanceToDateContrl.text = '';
                                                            attendanceData =  parsed.map<AttendanceData>((json) => AttendanceData.fromJson(json)).toList();
                                                            isLoading = false;
                                                            Navigator.pop(context);
                                                            Navigator.pushNamed(context, attendanceRoute, arguments: attendanceData,);
                                                          });
                                                        }
                                                        else{
                                                          setState(() {
                                                            attendanceFromDateContrl.text = '';
                                                            attendanceToDateContrl.text = '';
                                                            isLoading = false;
                                                          });
                                                          Navigator.pop(context);
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text("Error in data fetching")),
                                                          );
                                                        }
                                                      }).catchError( (error) {
                                                        setState(() {
                                                          attendanceFromDateContrl.text = '';
                                                          attendanceToDateContrl.text = '';
                                                          isLoading = false;
                                                        });
                                                        Navigator.pop(context);
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text("Error in data fetching")),
                                                        );
                                                      });
                                                    }
                                                  },
                                                  child: const Text('Show biometric data'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      attendanceFromDateContrl.text = '';
                                                      attendanceToDateContrl.text = '';
                                                    });
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Cancel'),
                                                  style: ButtonStyle(
                                                    backgroundColor: MaterialStateProperty.all(Colors.red),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              );
            }
            else{
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("No internet connection. Please check your settings")),
              );
            }

          }
          else if(title == "Shift Roster"){
            if(connectionStatus != ConnectivityResult.none){
              showDialog(
                context: context,
                builder: (context){
                  return StatefulBuilder(
                    builder: (context, setState){
                      return AlertDialog (
                        insetPadding: EdgeInsets.all(0),
                        content: Builder(
                          builder: (context) {
                            // Get available height and width of the build area of this widget. Make a choice depending on the size.
                            var height = MediaQuery.of(context).size.height;
                            var width = MediaQuery.of(context).size.width;

                            return Container(
                              height: height - (height/2.3),
                              width: width - (width/4),
                              child: isLoading ? waiting(context) : Column(
                                children:[
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    child: Center(child: Text('View Shift Roster',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 20,
                                          color: Colors.blue[500],
                                        ))) ,
                                  ),
                                  Wrap(
                                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children:[
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 5),
                                          primary: Colors.deepOrange,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(50)),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          DateTime fromDate = DateTime.now();
                                          DateTime toDate = DateTime.now().add(Duration(days: 8));
                                          _apiResponseData = _endpointProvider.fetchShiftRosterData(DateFormat('yyyy-MM-dd').format(fromDate),DateFormat('yyyy-MM-dd').format(toDate));
                                          _apiResponseData.then((result) {
                                            if(result.isAuthenticated && result.status){
                                              final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
                                              setState(() {
                                                shiftFromDateContrl.text = '';
                                                shiftToDateContrl.text = '';
                                                shiftRosterData =  parsed.map<ShiftRoster>((json) => ShiftRoster.fromJson(json)).toList();
                                                isLoading = false;
                                                Navigator.pop(context);
                                                Navigator.pushNamed(context, shiftRosterRoute, arguments: shiftRosterData,);
                                              });
                                            }
                                            else{
                                              setState(() {
                                                shiftFromDateContrl.text = '';
                                                shiftToDateContrl.text = '';
                                                isLoading = false;
                                              });
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text("Data not available")),
                                              );
                                            }
                                          }).catchError( (error) {
                                            setState(() {
                                              shiftFromDateContrl.text = '';
                                              shiftToDateContrl.text = '';
                                              isLoading = false;
                                            });
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Error in data fetching")),
                                            );
                                          });
                                        },
                                        child: const Text('Next 8 days'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 5),
                                          primary: Colors.blueGrey,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(50)),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          DateTime fromDate = new DateTime(DateTime.now().year,DateTime.now().month,1);
                                          DateTime toDate = (DateTime.now().month < 12) ? new DateTime(DateTime.now().year, DateTime.now().month + 1, 0) : new DateTime(DateTime.now().year + 1, 1, 0);
                                          _apiResponseData = _endpointProvider.fetchShiftRosterData(DateFormat('yyyy-MM-dd').format(fromDate),DateFormat('yyyy-MM-dd').format(toDate));
                                          _apiResponseData.then((result) {
                                            if(result.isAuthenticated && result.status){
                                              final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
                                              setState(() {
                                                shiftFromDateContrl.text = '';
                                                shiftToDateContrl.text = '';
                                                shiftRosterData =  parsed.map<ShiftRoster>((json) => ShiftRoster.fromJson(json)).toList();
                                                isLoading = false;
                                                Navigator.pop(context);
                                                Navigator.pushNamed(context, shiftRosterRoute, arguments: shiftRosterData,);
                                              });
                                            }
                                            else{
                                              setState(() {
                                                shiftFromDateContrl.text = '';
                                                shiftToDateContrl.text = '';
                                                isLoading = false;
                                              });
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text("Data not available")),
                                              );
                                            }
                                          }).catchError( (error) {
                                            setState(() {
                                              shiftFromDateContrl.text = '';
                                              shiftToDateContrl.text = '';
                                              isLoading = false;
                                            });
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Error in data fetching")),
                                            );
                                          });
                                        },
                                        child: const Text('Current Month'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 5),
                                          primary: Colors.teal,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(50)),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          DateTime fromDate = (DateTime.now().month < 12) ? new DateTime(DateTime.now().year, DateTime.now().month + 1, 1) : new DateTime(DateTime.now().year + 1, 1, 1);
                                          DateTime toDate = (fromDate.month < 12) ? new DateTime(fromDate.year, fromDate.month + 1, 0) : new DateTime(fromDate.year + 1, 1, 0);
                                          _apiResponseData = _endpointProvider.fetchShiftRosterData(DateFormat('yyyy-MM-dd').format(fromDate),DateFormat('yyyy-MM-dd').format(toDate));
                                          _apiResponseData.then((result) {
                                            if(result.isAuthenticated && result.status){
                                              final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
                                              setState(() {
                                                shiftFromDateContrl.text = '';
                                                shiftToDateContrl.text = '';
                                                shiftRosterData =  parsed.map<ShiftRoster>((json) => ShiftRoster.fromJson(json)).toList();
                                                isLoading = false;
                                                Navigator.pop(context);
                                                Navigator.pushNamed(context, shiftRosterRoute, arguments: shiftRosterData,);
                                              });
                                            }
                                            else{
                                              setState(() {
                                                shiftFromDateContrl.text = '';
                                                shiftToDateContrl.text = '';
                                                isLoading = false;
                                              });
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text("Data not available")),
                                              );
                                            }
                                          }).catchError( (error) {
                                            setState(() {
                                              shiftFromDateContrl.text = '';
                                              shiftToDateContrl.text = '';
                                              isLoading = false;
                                            });
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Error in data fetching")),
                                            );
                                          });
                                        },
                                        child: const Text('Next Month'),
                                      ),
                                    ],
                                  ),
                                  divider(),
                                  Form(
                                    key: _shiftRosterFormKey,
                                    child: Container(
                                      margin: EdgeInsets.symmetric(vertical: 20),
                                      child:Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,

                                        children: <Widget>[
                                          Container(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Text('Check for other period'),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(10),
                                            child: TextFormField(
                                              controller: shiftFromDateContrl,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'From Date',
                                              ),
                                              onTap: (){
                                                // Below line stops keyboard from appearing
                                                FocusScope.of(context).requestFocus(new FocusNode());
                                                _selectDate(context,shiftSelectedFromDate,shiftFromDateContrl);
                                              },
                                              // The validator receives the text that the user has entered.
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Please enter From Date';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(10),
                                            child: TextFormField(
                                              controller: shiftToDateContrl,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'To Date',
                                              ),
                                              onTap: (){
                                                // Below line stops keyboard from appearing
                                                FocusScope.of(context).requestFocus(new FocusNode());
                                                _selectDate(context,shiftSelectedToDate,shiftToDateContrl);
                                              },
                                              // The validator receives the text that the user has entered.
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Please enter To Date';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    // Validate returns true if the form is valid, or false otherwise.
                                                    if (_shiftRosterFormKey.currentState!.validate()) {
                                                      setState(() {
                                                        isLoading = true;
                                                      });

                                                      _apiResponseData = _endpointProvider.fetchShiftRosterData(shiftFromDateContrl.text,shiftToDateContrl.text);
                                                      _apiResponseData.then((result) {
                                                        if(result.isAuthenticated && result.status){
                                                          final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
                                                          setState(() {
                                                            shiftFromDateContrl.text = '';
                                                            shiftToDateContrl.text = '';
                                                            shiftRosterData =  parsed.map<ShiftRoster>((json) => ShiftRoster.fromJson(json)).toList();
                                                            isLoading = false;
                                                            Navigator.pop(context);
                                                            Navigator.pushNamed(context, shiftRosterRoute, arguments: shiftRosterData,);
                                                          });
                                                        }
                                                        else{
                                                          setState(() {
                                                            shiftFromDateContrl.text = '';
                                                            shiftToDateContrl.text = '';
                                                            isLoading = false;
                                                          });
                                                          Navigator.pop(context);
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text("Data not available")),
                                                          );
                                                        }
                                                      }).catchError( (error) {
                                                        setState(() {
                                                          shiftFromDateContrl.text = '';
                                                          shiftToDateContrl.text = '';
                                                          isLoading = false;
                                                        });
                                                        Navigator.pop(context);
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text("Error in data fetching")),
                                                        );
                                                      });
                                                    }
                                                  },
                                                  child: const Text('Show Shift Roster'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      shiftFromDateContrl.text = '';
                                                      shiftToDateContrl.text = '';
                                                    });
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Cancel'),
                                                  style: ButtonStyle(
                                                    backgroundColor: MaterialStateProperty.all(Colors.red),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  ),
                                ],
                              ),



                            );
                          },
                        ),
                      );
                    },
                  );
                },
              );
            }
            else{
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("No internet connection. Please check your settings")),
              );
            }

          }
          else if(title == "Claims"){
            if(connectionStatus != ConnectivityResult.none){
              showDialog(
                context: context,
                builder: (context){
                  return StatefulBuilder(
                    builder: (context, setState){
                      return AlertDialog (
                        insetPadding: EdgeInsets.all(0),
                        content: Builder(
                          builder: (context) {
                            // Get available height and width of the build area of this widget. Make a choice depending on the size.
                            var height = MediaQuery.of(context).size.height;
                            var width = MediaQuery.of(context).size.width;

                            return Container(
                              height: height - (height/2.3),
                              width: width - (width/4),
                              child: isLoading ? waiting(context) : Form(
                                key: _claimsFormKey,
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 20),
                                  child:Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,

                                    children: <Widget>[
                                      Container(

                                        padding: EdgeInsets.all(10),
                                        child: Center(child: Text('View Claims',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 20,
                                              color: Colors.blue[500],
                                            ))) ,
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(top:10,bottom:10),
                                        child: TextFormField(
                                          controller: claimsFromDateContrl,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'From Date',
                                          ),
                                          onTap: (){
                                            // Below line stops keyboard from appearing
                                            FocusScope.of(context).requestFocus(new FocusNode());
                                            _selectDate(context,claimsSelectedFromDate,claimsFromDateContrl);
                                          },
                                          // The validator receives the text that the user has entered.
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter From Date';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(top:10,bottom:10),
                                        child: TextFormField(
                                          controller: claimsToDateContrl,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'To Date',
                                          ),
                                          onTap: (){
                                            // Below line stops keyboard from appearing
                                            FocusScope.of(context).requestFocus(new FocusNode());
                                            _selectDate(context,claimsSelectedToDate,claimsToDateContrl);
                                          },
                                          // The validator receives the text that the user has entered.
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter To Date';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(top:10,bottom:10),
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            labelText: 'Claim Type',
                                            contentPadding: const EdgeInsets.only(left: 10.0),
                                            border: const OutlineInputBorder(),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButtonFormField<ClaimType>(
                                              value: _claimsTypeObj,
                                              //hint: Text('Mandatory'),
                                              style: TextStyle(color: Colors.black),
                                              items: claimTypes.map<DropdownMenuItem<ClaimType>>((ClaimType value) {
                                                return DropdownMenuItem<ClaimType>(
                                                  value: value,
                                                  child: Text(value.claimDesc),
                                                );
                                              }).toList(),
                                              onChanged: (ClaimType? newValue) {
                                                setState(() {
                                                  _claimsTypeObj = newValue!;
                                                  _claimsType = newValue.claimType;
                                                });
                                              },
                                              validator: (value) {
                                                if (value == null) {
                                                  return 'Please select claim type';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ),

                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                // Validate returns true if the form is valid, or false otherwise.
                                                if (_claimsFormKey.currentState!.validate()) {
                                                  setState(() {
                                                    isLoading = true;
                                                  });

                                                  _apiResponseData = _endpointProvider.fetchClaimsData(_claimsType,claimsFromDateContrl.text,claimsToDateContrl.text);
                                                  _apiResponseData.then((result) {
                                                    if(result.isAuthenticated && result.status){
                                                      final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
                                                      setState(() {
                                                        claimsFromDateContrl.text = '';
                                                        claimsToDateContrl.text = '';
                                                        _claimsType = '';
                                                        _claimsTypeObj = null;
                                                        claimsData =  parsed.map<ClaimData>((json) => ClaimData.fromJson(json)).toList();
                                                        isLoading = false;
                                                        Navigator.pop(context);
                                                        Navigator.pushNamed(context, claimsRoute, arguments: claimsData,);
                                                      });
                                                    }
                                                    else{
                                                      setState(() {
                                                        claimsFromDateContrl.text = '';
                                                        claimsToDateContrl.text = '';
                                                        _claimsTypeObj = null;
                                                        _claimsType = '';
                                                        isLoading = false;
                                                      });
                                                      Navigator.pop(context);
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text("Error in data fetching")),
                                                      );
                                                    }
                                                  }).catchError( (error) {
                                                    setState(() {
                                                      claimsFromDateContrl.text = '';
                                                      claimsToDateContrl.text = '';
                                                      _claimsTypeObj = null;
                                                      _claimsType = '';
                                                      isLoading = false;
                                                    });
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text("Error in data fetching")),
                                                    );
                                                  });
                                                }
                                              },
                                              child: const Text('Show my claims'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  claimsFromDateContrl.text = '';
                                                  claimsToDateContrl.text = '';
                                                  _claimsType = '';
                                                  _claimsTypeObj = null;
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Cancel'),
                                              style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty.all(Colors.red),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              );
            }
            else{
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("No internet connection. Please check your settings")),
              );
            }

          }
          else if(title == "Regularise Attendance"){
            if(connectionStatus != ConnectivityResult.none){
              showDialog(
                context: context,
                builder: (context){
                  return StatefulBuilder(
                    builder: (context, setState){
                      return AlertDialog (
                        insetPadding: EdgeInsets.all(0),
                        content: Builder(
                          builder: (context) {
                            // Get available height and width of the build area of this widget. Make a choice depending on the size.
                            var height = MediaQuery.of(context).size.height;
                            var width = MediaQuery.of(context).size.width;

                            return Container(
                              height: height - (height/3),
                              width: width - (width/4),
                              child: isLoading ? waiting(context) : Form(
                                key: _attRegulFormKey,
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 20),
                                  child:Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,

                                    children: <Widget>[
                                      Container(

                                        padding: EdgeInsets.all(10),
                                        child: Center(child: Text('Attendance Regularisation Request',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 20,
                                              color: Colors.blue[500],
                                            ))) ,
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        child: TextFormField(
                                          controller: attRegInTimeContrl,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'In Date & Time',
                                          ),
                                          onTap: (){
                                            // Below line stops keyboard from appearing
                                            FocusScope.of(context).requestFocus(new FocusNode());
                                            _selectDateTimeInTime(context,attRegInTimeContrl);
                                          },
                                          // The validator receives the text that the user has entered.
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter In Date & Time';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        child: TextFormField(
                                          controller: attRegOutTimeContrl,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'Out Date & Time',
                                          ),
                                          onTap: (){
                                            // Below line stops keyboard from appearing
                                            FocusScope.of(context).requestFocus(new FocusNode());
                                            _selectDateTimeOutTime(context,attRegOutTimeContrl);
                                          },
                                          // The validator receives the text that the user has entered.
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter Out Date & Time';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        child: TextFormField(
                                          controller: attRegReasonContrl,
                                          maxLines: 3,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'Reason for regularisation',
                                          ),
                                          // The validator receives the text that the user has entered.
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter your reason for fegularisation';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                // Validate returns true if the form is valid, or false otherwise.
                                                if (_attRegulFormKey.currentState!.validate()) {
                                                  setState(() {
                                                    isLoading = true;
                                                  });

                                                  _apiResponseData = _endpointProvider.postAttendRegulRequest(attRegIntime.toString(),attRegOutTime.toString(),
                                                      attRegReasonContrl.text);

                                                  _apiResponseData.then((result) {
                                                    if(result.isAuthenticated && result.status){
                                                      setState(() {
                                                        attRegInTimeContrl.text = '';
                                                        attRegOutTimeContrl.text = '';
                                                        isLoading = false;
                                                      });
                                                      Navigator.pop(context);
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text("Request successfully submitted")),
                                                      );
                                                    }
                                                    else{
                                                      setState(() {
                                                        attRegInTimeContrl.text = '';
                                                        attRegOutTimeContrl.text = '';
                                                        isLoading = false;
                                                      });
                                                      Navigator.pop(context);
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text("Error in submitting request")),
                                                      );
                                                    }
                                                  }).catchError( (error) {
                                                    setState(() {
                                                      attRegInTimeContrl.text = '';
                                                      attRegOutTimeContrl.text = '';
                                                      isLoading = false;
                                                    });
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text("Error in submitting request")),
                                                    );
                                                  });
                                                }
                                              },
                                              child: const Text('Submit Request'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  attRegInTimeContrl.text = '';
                                                  attRegOutTimeContrl.text = '';
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Cancel'),
                                              style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty.all(Colors.red),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),

                                    ],
                                  ),
                                ),

                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              );
            }
            else{
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("No internet connection. Please check your settings")),
              );
            }
          }
          else if(title == "ITAC" || title == "ECOFF & Overtime" || title == "Hosp. Credit Letter" || title == "Quiz"){
            if(connectionStatus != ConnectivityResult.none){
              Navigator.pushNamed(context, routeName);
            }
            else{
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("No internet connection. Please check your settings")),
              );
            }
          }
          else{
            //Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => News()));
            Navigator.pushNamed(context, routeName);
          }
        },
        child:Column(
          children:
          [
            SizedBox(height:20),
            icon,
            Text(title,
                style: TextStyle(fontSize: 15, color: textColor ),
                textAlign: TextAlign.center)
          ],
        ),
      ),
    );
/*    return Card(
      //elevation: 1.0,
      //margin: EdgeInsets.all(10.0),

      child: Container(
        decoration: BoxDecoration(
          //color:Colors.white10,
          borderRadius: BorderRadius.circular(100),
          color: Colors.transparent,
        ),

        height:30,
        child:
      ),
    );*/
  }

  Future<Null> _selectMonth(BuildContext context, var textController) async {
    final selected = await showMonthPicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2018),
        lastDate: DateTime.now()
    );
    if (selected != null)
      setState(() {
        payslipSelectedDate = selected;
        textController.text = DateFormat('MMM-yyyy').format(payslipSelectedDate);
      });
  }
  Future<Null> _selectDate(BuildContext context,DateTime date, var textController) async {
    final selected = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2018),
        lastDate: DateTime(2101));
    if (selected != null)
      setState(() {
        date = selected;
        textController.text = "${selected.toLocal()}".split(' ')[0];
      });
  }

  Future<Null> _selectDateTimeInTime(BuildContext context,var textController) async {
    final datePicked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2021),
        lastDate: DateTime(2101));
    if (datePicked != null){
      final timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: 00, minute: 00),
      );
      if(timePicked != null){
        setState(() {
          attRegIntime = DateTime(datePicked.year, datePicked.month, datePicked.day, timePicked.hour,timePicked.minute);
          textController.text = DateFormat('dd-MM-yyyy hh:mm aaa').format(attRegIntime);
        });
      }
    }
  }

  Future<Null> _selectDateTimeOutTime(BuildContext context,var textController) async {
    final datePicked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2021),
        lastDate: DateTime(2101));
    if (datePicked != null){
      final timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: 00, minute: 00),
      );
      if(timePicked != null){
        setState(() {
          attRegOutTime = DateTime(datePicked.year, datePicked.month, datePicked.day, timePicked.hour,timePicked.minute);
          textController.text = DateFormat('dd-MM-yyyy hh:mm aaa').format(attRegOutTime);
        });
      }
    }
  }
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }
    return _updateConnectionStatus(result);
  }
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {

     if(result != ConnectivityResult.none){
       // connectivity detected
       if (Platform.isAndroid) {
         // Android- check if there is actual internet connection
         bool isDeviceConnected = false;
         try {
           final result = await InternetAddress.lookup('google.com');
           if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
             isDeviceConnected = true;
           } else {
             isDeviceConnected = false;
           }
         } on SocketException catch(_) {
           isDeviceConnected = false;
         }
         //isDeviceConnected = await DataConnectionChecker().hasConnection;
         if(isDeviceConnected){
           setState(() {
             connectionStatus = result;
           });
         }
       } else if (Platform.isIOS) {
         // result from default connectivity check can be updated
         setState(() {
           connectionStatus = result;
         });
       }
     }
     else{
       // No connectivity
       setState(() {
         connectionStatus = result;
       });
     }
  }

}

class ScreenArguments {
  final String fromDate;
  final String toDate;
  final String claimType;

  ScreenArguments(this.fromDate, this.toDate, this.claimType);
}

class LeaveQuotas extends StatefulWidget {
  @override
  State<LeaveQuotas> createState() => _LeaveQuotaState();
}
class _LeaveQuotaState extends State<LeaveQuotas>{
  late LeaveQuota _leaveQuotaData;
  late Future<APIResponseData> _apiResponseData;
  late var _endpointProvider;
  bool isLoading = true;

  @override
  void initState(){
    super.initState();
    DioClient _dio = new DioClient();
    _endpointProvider = new EndPointProvider(_dio.init());
    final leaveQuotaBox = Hive.box('leaveQuota');
    if(leaveQuotaBox.values.isEmpty){
      if(connectionStatus != ConnectivityResult.none){
        _apiResponseData = _endpointProvider.fetchLeaveQuota();
        _apiResponseData.then((result) {
          if(result.isAuthenticated && result.status){
            setState(() {
              _leaveQuotaData = LeaveQuota.fromJson(jsonDecode(result.data ?? ''));
              isLoading = false;
            });
            leaveQuotaBox.add(_leaveQuotaData);
          }
        });
      }
      else{
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No internet connection. Please check your settings")),
        );
      }
    }
    else{
      setState((){
        _leaveQuotaData = leaveQuotaBox.getAt(0) as LeaveQuota;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              //colors: [Color.fromRGBO(255, 239, 186, 1), Color.fromRGBO(255, 255, 255, 1)]
              colors: [startColor, endColor]
          )
      ),
      child: getScaffold(),
    );

  }
  Scaffold getScaffold(){
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: appBarTextColor
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: appBarBackgroundColor,
          statusBarIconBrightness: statusBarBrightness,),
        backgroundColor: appBarBackgroundColor,
        bottomOpacity: 0.0,
        elevation: appBarElevation,
        leading: Container(
          width: 40,
          child: Image.asset('images/bcpl_logo.png'),
        ),
        title: Row(
          children:[
            Text('Leave Quota',style: TextStyle(
              color:appBarTextColor,
            ),),
            Spacer(),
            IconButton(
              icon: Icon(Icons.sync),
              onPressed: () {
                if(connectionStatus != ConnectivityResult.none){
                  setState(() {
                    isLoading = true;
                  });
                  _apiResponseData = _endpointProvider.fetchLeaveQuota();
                  _apiResponseData.then((result) {
                    if(result.isAuthenticated && result.status){
                      setState(() {
                        _leaveQuotaData = LeaveQuota.fromJson(jsonDecode(result.data ?? ''));
                        isLoading = false;
                      });
                      final leaveQuotaBox = Hive.box('leaveQuota');
                      leaveQuotaBox.deleteAt(0);
                      leaveQuotaBox.add(_leaveQuotaData);
                    }
                  });
                }
                else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("No internet connection. Please check your settings")),
                  );
                }
              },
              color: appBarTextColor,
            )
          ],
        ),
      ),
      endDrawer: AppDrawer(),
      body: isLoading? waiting(context) :
      Column(
        children: [
          connectionStatus != ConnectivityResult.none ? SizedBox(height:0) : noConnectivityError(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(10.0),
              children: [
                descSection("Casual Leave (CL)",_leaveQuotaData.QuotaCL,Icons.star),
                descSection("Earned Leave (EL)",_leaveQuotaData.QuotaEL,Icons.star),
                descSection("Half Pay Leave (HPL)",_leaveQuotaData.QuotaHPL,Icons.star),
                descSection("Restricted Holiday Leave (RH)",_leaveQuotaData.QuotaRH,Icons.star),
                descSection("Compensatory Off Leave (COFF)",_leaveQuotaData.QuotaCOFF,Icons.star),
              ],
            ),
          ),
        ],
      ),

    );
  }
  // FutureBuilder getQuota(){
  //   return FutureBuilder<LeaveQuota>(
  //     future: _leaveQuotaData,
  //     builder: (BuildContext context, snapshot){
  //       if (snapshot.hasData) {
  //         LeaveQuota? data = snapshot.data;
  //          return ListView(
  //            padding: EdgeInsets.all(10.0),
  //            children: [
  //              descSection("Casual Leave (CL)",snapshot.data!.QuotaCL,Icons.star),
  //              descSection("Earned Leave (EL)",snapshot.data!.QuotaEL,Icons.star),
  //              descSection("Half Pay Leave (HPL)",snapshot.data!.QuotaHPL,Icons.star),
  //              descSection("Restricted Holiday Leave (RH)",snapshot.data!.QuotaRH,Icons.star),
  //              descSection("Compensatory Off Leave (COFF)",snapshot.data!.QuotaCOFF,Icons.star),
  //
  //            ],
  //          );
  //
  //       } else if (snapshot.hasError) {
  //         return Text("${snapshot.error}");
  //       }
  //       return SizedBox(
  //         height: MediaQuery.of(context).size.height / 1.3,
  //         child: Center(
  //           child: CircularProgressIndicator(),
  //         ),
  //       );
  //     },
  //   );
  // }
  Widget descSection(String title, String subtitle, IconData icon){
    return Card(
      elevation:2,
      child: ListTile(
        isThreeLine: true,
        title: Text(title,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
            )),
        subtitle:  Text(subtitle,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 20,
              color: Colors.blue[500],
            )),

         leading: Icon(
           icon,
           color: Colors.blue[500],
         ),
      ),
    );
  }
}

class Holidays extends StatefulWidget {
  @override
  State<Holidays> createState() => _HolidaysState();
}
class _HolidaysState extends State<Holidays> with SingleTickerProviderStateMixin{
  late List<HolidayList> _holidayListData;
  late List<HolidayList> _ghList;
  late List<HolidayList> _rhList;
  late Future<APIResponseData> _apiResponseData;
  late var _endpointProvider;
  bool isLoading = true;
  TabController? _tabController;
  final List<Tab> myTabs = <Tab>[
    Tab(
      child: Container(
        child: Align(
          alignment: Alignment.center,
          child: Text("General Holiday",style: TextStyle(fontSize: 14, color: appBarTextColor ),),
        ),
      ),
    ),
    Tab(
      child: Container(
        child: Align(
          alignment: Alignment.center,
          child: Text("Restricted Holiday",style: TextStyle(fontSize: 14, color: appBarTextColor ),),
        ),
      ),
    ),
  ];

  @override
  void initState(){
    //_tabController = TabController(length: 2, vsync: this);
    _tabController = TabController(vsync: this, length: myTabs.length);
    super.initState();
    DioClient _dio = new DioClient();
    _endpointProvider = new EndPointProvider(_dio.init());
    final holidayListBox = Hive.box<HolidayList>('holidayList');
    if(holidayListBox.values.isEmpty){
      if(connectionStatus != ConnectivityResult.none){
        _apiResponseData = _endpointProvider.fetchHolidayList();
        _apiResponseData.then((result) {
          if(result.isAuthenticated && result.status){
            final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
            setState(() {
              _holidayListData =  parsed.map<HolidayList>((json) => HolidayList.fromJson(json)).toList();
              _ghList = _holidayListData.where((element) => element.holidayType == "GH").toList();
              _rhList = _holidayListData.where((element) => element.holidayType == "RH").toList();
              isLoading = false;
            });
            holidayListBox.addAll(_holidayListData);
          }
        });
      }
      else{
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No internet connection. Please check your settings")),
        );
      }
    }
    else{
      setState(() {
        _holidayListData =  holidayListBox.values.toList();
        _ghList = _holidayListData.where((element) => element.holidayType == "GH").toList();
        _rhList = _holidayListData.where((element) => element.holidayType == "RH").toList();
        isLoading = false;
      });
    }

  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              //colors: [Color.fromRGBO(255, 239, 186, 1), Color.fromRGBO(255, 255, 255, 1)]
              colors: [startColor, endColor]
          )
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          iconTheme: IconThemeData(
              color: appBarTextColor
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: appBarBackgroundColor,
            statusBarIconBrightness: statusBarBrightness,),
          backgroundColor: appBarBackgroundColor,
          //bottomOpacity: 0.0,
          elevation: appBarElevation,
          leading: Container(
            width: 40,
            child: Image.asset('images/bcpl_logo.png'),
          ),
          title: Row(
            children:[
              Text('Holiday List',style: TextStyle(
                color:appBarTextColor,
              ),),
              Spacer(),
              IconButton(
                icon: Icon(Icons.sync),
                onPressed: () {
                  if(connectionStatus != ConnectivityResult.none){
                    setState(() {
                      isLoading = true;
                    });
                    _apiResponseData = _endpointProvider.fetchHolidayList();
                    _apiResponseData.then((result) {
                      if(result.isAuthenticated && result.status){
                        final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
                        setState(() {
                          _holidayListData =  parsed.map<HolidayList>((json) => HolidayList.fromJson(json)).toList();
                          _ghList = _holidayListData.where((element) => element.holidayType == "GH").toList();
                          _rhList = _holidayListData.where((element) => element.holidayType == "RH").toList();
                          isLoading = false;
                        });
                        final holidayListBox = Hive.box<HolidayList>('holidayList');
                        holidayListBox.clear();
                        holidayListBox.addAll(_holidayListData);
                      }
                    });
                  }
                  else{
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("No internet connection. Please check your settings")),
                    );
                  }
                },
                color: appBarTextColor ,
              )
            ],
          ),
          bottom:TabBar(
            controller: _tabController,
            tabs: myTabs,
          ),
        ),
        endDrawer: AppDrawer(),
        body: isLoading? waiting(context) : TabBarView(
            controller: _tabController,
            children: [
              createHolidayList(_ghList),
              createHolidayList(_rhList),
            ]
        ),
      ),
    );
  }
  // FutureBuilder getHolidayList(){
  //   return FutureBuilder<List<HolidayList>>(
  //     future: _holidayListData,
  //     builder: (BuildContext context, snapshot){
  //       if (snapshot.hasData) {
  //         List<HolidayList>? data = snapshot.data;
  //         List<HolidayList>? ghList = data!.where((element) =>
  //         element.holidayType == "GH").toList();
  //
  //         List<HolidayList>? rhList = data!.where((element) =>
  //         element.holidayType == "RH").toList();
  //
  //         return TabBarView(
  //           controller: _tabController,
  //           children: [
  //             createHolidayList(ghList),
  //             createHolidayList(rhList),
  //           ]
  //         );
  //       } else if (snapshot.hasError) {
  //         return Text("${snapshot.error}");
  //       }
  //       return SizedBox(
  //         height: MediaQuery.of(context).size.height / 1.3,
  //         child: Center(
  //           child: CircularProgressIndicator(),
  //         ),
  //       );
  //     },
  //   );
  // }
  ListView createHolidayList(data) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          var dateTime = DateFormat('dd-MM-yyyy').parse(data[index].holidayDate);
          var weekDay = '';
          if(dateTime.weekday == 1){
            weekDay = 'Monday';
          }
          else if(dateTime.weekday == 2){
            weekDay = 'Tuesday';
          }
          else if(dateTime.weekday == 3){
            weekDay = 'Wednesday';
          }
          else if(dateTime.weekday == 4){
            weekDay = 'Thursday';
          }
          else if(dateTime.weekday == 5){
            weekDay = 'Friday';
          }
          else if(dateTime.weekday == 6){
            weekDay = 'Saturday';
          }
          else if(dateTime.weekday == 7){
            weekDay = 'Sunday';
          }
          return Card(
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    border: Border.all(
                      color: Colors.black12,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(data[index].holidayDate,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),),
                ),

                title: Text(data[index].holidayName,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                    ),),
                subtitle: Text(weekDay,
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 14,
                  ),),
              ),
          );
        }
    );
  }
}

class ITAC extends StatefulWidget{
  @override
  State<ITAC> createState() => _ITACState();
}
class _ITACState extends State<ITAC>{
  final _itacFormKey = GlobalKey<FormBuilderState>();
  bool isLoading = false;
  late Future<APIResponseData> _apiResponseData;
  late var _endpointProvider;
  late DioClient _dio;
  ITACMasterData? itacMasterData;
  List<String> ITACSRType = [];
  List<String> ITACSRLocation = [];

  @override
  void initState(){
    super.initState();
    _dio = new DioClient();
    _endpointProvider = new EndPointProvider(_dio.init());
    final itacMasterBox = Hive.box<ITACMasterData>('itacMaster');
    if(itacMasterBox.values.isEmpty){
      if(connectionStatus != ConnectivityResult.none){
        _apiResponseData = _endpointProvider.fetchITACMasterData();
        _apiResponseData.then((result) {
          if(result.isAuthenticated && result.status){
            setState(() {
              itacMasterData =  ITACMasterData.fromJson(jsonDecode(result.data ?? ''));
              ITACSRType = itacMasterData!.data1;
              ITACSRLocation = itacMasterData!.data2;
            });
            itacMasterBox.add(itacMasterData!);
          }
        });
      }
      else{
        //Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No internet connection. Please check your settings")),
        );
      }
    }
    else{
      setState(() {
        itacMasterData =  itacMasterBox.getAt(0) as ITACMasterData;
        ITACSRType = itacMasterData!.data1;
        ITACSRLocation = itacMasterData!.data2;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              //colors: [Color.fromRGBO(255, 239, 186, 1), Color.fromRGBO(255, 255, 255, 1)]
              colors: [startColor, endColor]
          )
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          iconTheme: IconThemeData(
              color: appBarTextColor
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: appBarBackgroundColor,
            statusBarIconBrightness: statusBarBrightness,),
          backgroundColor: appBarBackgroundColor,
          bottomOpacity: 0.0,
          elevation: appBarElevation,
          leading: Container(
            width: 40,
            child: Image.asset('images/bcpl_logo.png'),
          ),
          title: Row(
            children:[
              Text('ITAC',style: TextStyle(
                color:appBarTextColor,
              ),),
              Spacer(),
              IconButton(
                icon: Icon(Icons.sync),
                onPressed: () {
                  if(connectionStatus != ConnectivityResult.none){
                    setState(() {
                      isLoading = true;
                    });
                    _apiResponseData = _endpointProvider.fetchITACMasterData();
                    _apiResponseData.then((result) {
                      if(result.isAuthenticated && result.status){
                        setState(() {
                          itacMasterData =  ITACMasterData.fromJson(jsonDecode(result.data ?? ''));
                          ITACSRType = itacMasterData!.data1;
                          ITACSRLocation = itacMasterData!.data2;
                          isLoading = false;
                        });
                        final itacMasterBox = Hive.box<ITACMasterData>('itacMaster');
                        itacMasterBox.clear();
                        itacMasterBox.add(itacMasterData!);
                      }
                    });
                  }
                  else{
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("No internet connection. Please check your settings")),
                    );
                  }
                },
                color: appBarTextColor ,
              )
            ],
          ),
        ),
        endDrawer: AppDrawer(),
        body: isLoading ? waiting(context) : itacForm(),
      ),
    );
  }

  Widget itacForm(){
    return SingleChildScrollView(
      child: Column(
        children: [
          connectionStatus != ConnectivityResult.none ? SizedBox(height:0) : noConnectivityError(),
          SizedBox(height:10),
          Container(
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(10),
            child: Text('ITAC Request',style: TextStyle(
              fontWeight: FontWeight.w500,fontSize: 18,),),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white30,
            ),
            padding: EdgeInsets.all(15),
            child: FormBuilder(
              key: _itacFormKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  FormBuilderDropdown(
                    name: 'SRType',
                    decoration: InputDecoration(
                      labelText: 'Request Type',
                    ),
                    // initialValue: 'Male',
                    allowClear: true,
                    hint: Text('Select Request'),
                    validator: FormBuilderValidators.compose(
                        [FormBuilderValidators.required(context)]),
                    items: ITACSRType
                        .map((SRType) => DropdownMenuItem(
                      value: SRType,
                      child: Text('$SRType'),
                    ))
                        .toList(),
                  ),
                  FormBuilderDropdown(
                    name: 'location',
                    decoration: InputDecoration(
                      labelText: 'Location',
                    ),
                    // initialValue: 'Male',
                    allowClear: true,
                    hint: Text('Select Location'),
                    validator: FormBuilderValidators.compose(
                        [FormBuilderValidators.required(context)]),
                    items: ITACSRLocation
                        .map((location) => DropdownMenuItem(
                      value: location,
                      child: Text('$location'),
                    ))
                        .toList(),
                  ),
                  FormBuilderTextField(
                    name: 'title',
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText:
                      'Title',
                    ),
                    //onChanged: _onChanged,
                    // valueTransformer: (text) => num.tryParse(text),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context),
                    ]),
                  ),
                  FormBuilderTextField(
                    name: 'description',
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText:
                      'Description',
                    ),
                    //onChanged: _onChanged,
                    // valueTransformer: (text) => num.tryParse(text),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context),
                    ]),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: MaterialButton(
                          color: Theme.of(context).accentColor,
                          child: Text(
                            "Submit",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            if(connectionStatus != ConnectivityResult.none){
                              _itacFormKey.currentState!.save();
                              var formDataMap = _itacFormKey.currentState!.value;

                              if (_itacFormKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                });
                                _apiResponseData = _endpointProvider.postITACRequest(formDataMap);

                                _apiResponseData.then((result) {
                                  if(result.isAuthenticated && result.status){
                                    //_crLtrFormKey.currentState!.reset();
                                    setState(() {
                                      isLoading = false;
                                    });
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Request successfully submitted")),
                                    );
                                  }
                                  else{
                                    //_crLtrFormKey.currentState!.reset();
                                    setState(() {
                                      isLoading = false;
                                    });
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Error: ${result.error_details}")),
                                    );
                                  }
                                }).catchError( (error) {
                                  //_crLtrFormKey.currentState!.reset();
                                  setState(() {
                                    isLoading = false;
                                  });
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error in submitting request")),
                                  );
                                });
                              } else {
                                print("validation failed");
                              }
                            }
                            else{
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("No internet connection. Please check your settings")),
                              );
                            }

                          },
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: MaterialButton(
                          color: Colors.red,
                          child: Text(
                            "Reset",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            _itacFormKey.currentState!.reset();
                          },
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: MaterialButton(
                          color: Colors.red,
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            _itacFormKey.currentState!.reset();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class ECOFF_OT extends StatefulWidget{
  @override
  State<ECOFF_OT> createState() => _ECOFF_OTState();
}
class _ECOFF_OTState extends State<ECOFF_OT>{
  final _ecofOtFormKey = GlobalKey<FormBuilderState>();
  final _dateFieldKey = GlobalKey<FormBuilderFieldState>();
  bool isLoading = false;
  late Future<APIResponseData> _apiResponseData;
  late var _endpointProvider;
  late DioClient _dio;
  bool isECOFFReq = false;
  bool isOTReq = false;
  bool isOffDay = false;
  bool isNationalHoliday = false;
  DateTime lastDateforClaim = DateTime.now();
  String? _dateError;

  @override
  void initState(){
    super.initState();
    _dio = new DioClient();
    _endpointProvider = new EndPointProvider(_dio.init());
    lastDateforClaim = new DateTime(DateTime.now().year,DateTime.now().month - 1, 20);

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              //colors: [Color.fromRGBO(255, 239, 186, 1), Color.fromRGBO(255, 255, 255, 1)]
              colors: [startColor, endColor]
          )
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          iconTheme: IconThemeData(
              color: appBarTextColor
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: appBarBackgroundColor,
            statusBarIconBrightness: statusBarBrightness,),
          backgroundColor: appBarBackgroundColor,
          bottomOpacity: 0.0,
          elevation: appBarElevation,
          leading: Container(
            width: 40,
            child: Image.asset('images/bcpl_logo.png'),
          ),
          title: Text('ECOFF & OT',style: TextStyle(
            color:appBarTextColor,
          ),),
        ),
        endDrawer: AppDrawer(),
        body: isLoading ? waiting(context) : ecoffOTForm(),
      ),
    );
  }

  Widget ecoffOTForm(){
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height:10),
          Container(
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(10),
            child: Text('COFF Encashment / Overtime Allowance',style: TextStyle(
              fontWeight: FontWeight.w500,fontSize: 18,),),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(10),
            child: Text('Biometric in/out times are required. Please regularise attendance first if in/out times are not avaialble',style: TextStyle(
              fontWeight: FontWeight.w400,fontSize: 14,),),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white30,
            ),
            padding: EdgeInsets.all(15),
            child: FormBuilder(
              key: _ecofOtFormKey,
              autovalidateMode: AutovalidateMode.always,
              child: Column(
                children: [
                  FormBuilderChoiceChip(
                    name: 'request_type',
                    decoration: InputDecoration(
                      labelText: 'Request Type',
                      helperText: 'Overtime allowance is for Non-Executive cadre employees only',
                    ),
                    options: [
                      FormBuilderFieldOption(
                          value: 'ECOF', child: Text('COFF Encashment')),
                      FormBuilderFieldOption(
                          value: 'OT', child: Text('Overtime Allowance')),
                    ],
                    validator: FormBuilderValidators.compose(
                        [FormBuilderValidators.required(context)]),
                    onChanged: (String? newValue) {
                      if(newValue == 'ECOF'){
                        setState(() {
                          isECOFFReq = true;
                          isOTReq = false;
                        });
                      }
                      else if(newValue == 'OT'){
                        setState(() {
                          isECOFFReq = false;
                          isOTReq = true;
                        });
                      }
                      else{
                        setState(() {
                          isECOFFReq = false;
                          isOTReq = false;
                        });
                      }
                    },
                  ),
                  FormBuilderDateTimePicker(
                    name: 'claim_date',
                    // onChanged: _onChanged,
                    inputType: InputType.date,
                    decoration: InputDecoration(
                      labelText: 'Claim Date',
                      helperText: 'Date of Coff/Overtime',
                    ),
                    validator: FormBuilderValidators.compose(
                        [FormBuilderValidators.required(context)]),
                    lastDate: lastDateforClaim,
                    firstDate: DateTime(2019,3,1),
                    //initialTime: TimeOfDay(hour: 8, minute: 0),
                    initialValue: lastDateforClaim,
                    onChanged: (DateTime? newValue) {
                      if ((newValue!.day == 26 && newValue!.month == 1) ||  //26th January
                          (newValue!.day == 15 && newValue!.month == 8) ||  // 15th August
                          (newValue!.day == 2 && newValue!.month == 10))    // 2nd October
                          {
                        //National Holiday. Get option whether only ecoff or ecoff+coff
                        setState(() {
                          isNationalHoliday = true;
                        });
                      }
                      else{
                        setState(() {
                          isNationalHoliday = false;
                        });
                      }
                    },
                    // enabled: true,
                  ),

                  isECOFFReq ?
                  Column(
                    children: [
                      FormBuilderChoiceChip(
                        name: 'shift_type',
                        decoration: InputDecoration(
                          labelText: 'Shift Type',
                        ),
                        options: [
                          FormBuilderFieldOption(
                              value: 'GEN', child: Text('General Shift')),
                          FormBuilderFieldOption(
                              value: 'ROT', child: Text('Rotational Shift')),
                        ],
                        validator: FormBuilderValidators.compose(
                            [FormBuilderValidators.required(context)]),
                      ),
                      FormBuilderChoiceChip(
                        name: 'coff_type',
                        decoration: InputDecoration(
                          labelText: 'ECOFF Type',
                        ),
                        options: [
                          FormBuilderFieldOption(
                              value: 'SAT', child: Text('1st/3rd/5th Saturday')),
                          FormBuilderFieldOption(
                              value: 'OTR', child: Text('GH/NH/Off Day/Double Shift')),
                        ],
                        validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(context)
                            ]),
                      ),
                      FormBuilderChoiceChip(
                        name: 'off_day',
                        decoration: InputDecoration(
                          labelText: 'Shift done against off day',
                        ),
                        options: [
                          FormBuilderFieldOption(
                              value: 'yes', child: Text('Yes')),
                          FormBuilderFieldOption(
                              value: 'no', child: Text('No')),
                        ],
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context)
                        ]),
                        onChanged: (String? newValue) {
                          if(newValue == 'yes'){
                            setState(() {
                              isOffDay = true;
                            });
                          }
                          else if(newValue == 'no'){
                            setState(() {
                              isOffDay = false;
                            });
                          }
                          else{
                            setState(() {
                              isOffDay = false;
                            });
                          }
                        },
                      ),
                      isNationalHoliday? FormBuilderChoiceChip(
                        name: 'NHOption',
                        decoration: InputDecoration(
                          labelText: 'ECO Count for National Holiday',
                        ),
                        options: [
                          FormBuilderFieldOption(
                              value: 'ECO', child: Text('Only ECOFF')),
                          FormBuilderFieldOption(
                              value: 'ECO_CO', child: Text('Equal ECOFF and COFF')),
                        ],
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context)
                        ]),
                      ) : SizedBox(height:1),
                      isOffDay? FormBuilderChoiceChip(
                        name: 'performed_shift',
                        decoration: InputDecoration(
                          labelText: 'Shift done',
                        ),
                        options: [
                          FormBuilderFieldOption(
                              value: 'A', child: Text('A')),
                          FormBuilderFieldOption(
                              value: 'B', child: Text('B')),
                          FormBuilderFieldOption(
                              value: 'C', child: Text('C')),
                          FormBuilderFieldOption(
                              value: 'AB', child: Text('AB')),
                          FormBuilderFieldOption(
                              value: 'BC', child: Text('BC')),
                          FormBuilderFieldOption(
                              value: 'AC', child: Text('AC')),
                          FormBuilderFieldOption(
                              value: 'GC', child: Text('GC')),
                          FormBuilderFieldOption(
                              value: 'ABC', child: Text('ABC')),
                        ],
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context)
                        ]),
                      ) : SizedBox(height:1),
                      FormBuilderTextField(
                        name: 'remarks',
                        decoration: InputDecoration(
                          labelText:
                          'Remarks',
                        ),
                        //onChanged: _onChanged,
                        // valueTransformer: (text) => num.tryParse(text),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context),
                        ]),
                      ),
                    ],
                  ) : SizedBox(height:1),

                  isOTReq ?
                  Column(
                    children: [
                      FormBuilderTextField(
                        name: 'ot_hours',
                        decoration: InputDecoration(
                          labelText:
                          'Overtime Hours',
                        ),
                        //onChanged: _onChanged,
                        // valueTransformer: (text) => num.tryParse(text),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context),
                          FormBuilderValidators.numeric(context),
                          FormBuilderValidators.max(context, 24),
                        ]),
                        keyboardType: TextInputType.number,
                      ),
                      FormBuilderTextField(
                        name: 'remarks',
                        decoration: InputDecoration(
                          labelText:
                          'Reason for Overtime',
                        ),
                        //onChanged: _onChanged,
                        // valueTransformer: (text) => num.tryParse(text),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context),
                        ]),
                      ),
                    ],
                  )
                  : SizedBox(height:1),

                  Row(
                    children: <Widget>[
                      Expanded(
                        child: MaterialButton(
                          color: Theme.of(context).accentColor,
                          child: Text(
                            "Submit",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            if(connectionStatus != ConnectivityResult.none){
                              _ecofOtFormKey.currentState!.save();
                              var formDataMap = _ecofOtFormKey.currentState!.value;

                              //Custom validations for ECOFF Request
                              if(formDataMap['request_type'] == 'ECOF'){
                                DateTime dataDate = formDataMap['claim_date'] as DateTime;
                                if(formDataMap['coff_type'] == 'SAT'){
                                  if(dataDate.weekday != 6){
                                    _ecofOtFormKey.currentState!.invalidateField(name: 'request_type', errorText: 'Date is not Saturday');
                                  }
                                  if(formDataMap['shift_type'] != 'GEN'){
                                    _ecofOtFormKey.currentState!.invalidateField(name: 'shift_type', errorText: '1st/3rd/5th Saturday ECO is for General Shift Employee only');
                                  }
                                  if (dataDate.day >= 8 && dataDate.day <= 14)
                                  {
                                    _ecofOtFormKey.currentState!.invalidateField(name: 'claim_date', errorText: 'ECO can not be submitted for Second Saturday');
                                  }
                                  if (dataDate.day >= 22 && dataDate.day <= 28)
                                  {
                                    _ecofOtFormKey.currentState!.invalidateField(name: 'claim_date', errorText: 'ECO can not be submitted for Fourth Saturday');
                                  }
                                }
                                else if(formDataMap['coff_type'] == 'OTR'){
                                  if ((dataDate.day == 26 && dataDate.month == 1) ||  //26th January
                                      (dataDate.day == 15 && dataDate.month == 8) ||  // 15th August
                                      (dataDate.day == 2 && dataDate.month == 10))    // 2nd October
                                      {
                                    //National Holiday. Not eligible for Non-Ex for ECO
                                    if(grade.startsWith('S')){
                                      _ecofOtFormKey.currentState!.invalidateField(name: 'claim_date', errorText: 'ECO for national holiday can not be claimed');
                                    }
                                  }
                                }
                              }

                              if (_ecofOtFormKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                  isECOFFReq = false;
                                  isOTReq = false;
                                });
                                _apiResponseData = _endpointProvider.postECOFFOTRequest(formDataMap);

                                _apiResponseData.then((result) {
                                  if(result.isAuthenticated && result.status){
                                    //_crLtrFormKey.currentState!.reset();
                                    setState(() {
                                      isLoading = false;
                                      isECOFFReq = false;
                                      isOTReq = false;
                                    });
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Request successfully submitted")),
                                    );
                                  }
                                  else{
                                    //_ecofOtFormKey.currentState!.reset();
                                    setState(() {
                                      isLoading = false;
                                      isECOFFReq = false;
                                      isOTReq = false;
                                    });

                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Error: ${result.error_details}")),
                                    );
                                  }
                                }).catchError( (error) {
                                  //_ecofOtFormKey.currentState!.reset();
                                  setState(() {
                                    isLoading = false;
                                    isECOFFReq = false;
                                    isOTReq = false;
                                  });
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error in submitting request")),
                                  );
                                });
                              } else {
                                print("validation failed");
                              }
                            }
                            else{
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("No internet connection. Please check your settings")),
                              );
                            }

                          },
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: MaterialButton(
                          color: Colors.red,
                          child: Text(
                            "Reset",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            _ecofOtFormKey.currentState!.reset();
                            setState(() {
                              isECOFFReq = false;
                              isOTReq = false;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: MaterialButton(
                          color: Colors.red,
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            _ecofOtFormKey.currentState!.reset();
                            setState(() {
                              isECOFFReq = false;
                              isOTReq = false;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  @override
  void dispose() {
    super.dispose();
  }
}

class HospitalCreditLetter extends StatefulWidget{
  @override
  State<HospitalCreditLetter> createState() => _HospitalCreditLetterState();
}
class _HospitalCreditLetterState extends State<HospitalCreditLetter>{
  final _crLtrFormKey = GlobalKey<FormBuilderState>();
  bool isLoading = false;
  late Future<APIResponseData> _apiResponseData;
  late var _endpointProvider;
  late DioClient _dio;
  HospCrLtrMasterData? masterData;
  List<HospCrLtrHospitalMasterData> hospitals = [];
  List<HospCrLtrEmpDepMasterData> patient = [];
  final ImagePicker _picker = ImagePicker();
  File? _attachment;
  String _attachmentName = '';

  @override
  void initState(){
    super.initState();
    _dio = new DioClient();
    _endpointProvider = new EndPointProvider(_dio.init());
    getHospCrLtrMasterData();
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              //colors: [Color.fromRGBO(255, 239, 186, 1), Color.fromRGBO(255, 255, 255, 1)]
              colors: [startColor, endColor]
          )
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          iconTheme: IconThemeData(
              color: appBarTextColor
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: appBarBackgroundColor,
            statusBarIconBrightness: statusBarBrightness,),
          backgroundColor: appBarBackgroundColor,
          bottomOpacity: 0.0,
          elevation: appBarElevation,
          leading: Container(
            width: 40,
            child: Image.asset('images/bcpl_logo.png'),
          ),
          title: Row(
            children:[
              Text('Connect',style: TextStyle(
                color:appBarTextColor,
              ),),
              Spacer(),
              IconButton(
                icon: Icon(Icons.sync),
                onPressed: () {
                  if(connectionStatus != ConnectivityResult.none){
                    setState(() {
                      isLoading = true;
                    });
                    _apiResponseData = _endpointProvider.fetchHosCrLtrMasterData();
                    _apiResponseData.then((result) {
                      if(result.isAuthenticated && result.status){
                        setState(() {
                          masterData =  HospCrLtrMasterData.fromJson(jsonDecode(result.data ?? ''));
                          hospitals = masterData!.hospitals;
                          patient = masterData!.patient;
                          isLoading = false;
                        });
                        final hosCrLtrMasterBox = Hive.box<HospCrLtrMasterData>('hospCrLtrMaster');
                        hosCrLtrMasterBox.clear();
                        hosCrLtrMasterBox.add(masterData!);
                      }
                    });
                  }
                  else{
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("No internet connection. Please check your settings")),
                    );
                  }
                },
                color: appBarTextColor,
              )
            ],
          ),
        ),
        endDrawer: AppDrawer(),
        body: isLoading ? waiting(context) : hospCrLetterForm(),
      ),
    );
  }

  Widget hospCrLetterForm(){
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height:10),
          Container(
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(10),
            child: Text('Request for Hospitalisation Credit Letter',style: TextStyle(
              fontWeight: FontWeight.w500,fontSize: 18,),),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white30,
            ),
            padding: EdgeInsets.all(15),
            child: FormBuilder(
              key: _crLtrFormKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  FormBuilderDropdown(
                    name: 'patient',
                    decoration: InputDecoration(
                      labelText: 'Patient Name',
                    ),
                    allowClear: true,
                    //hint: Text('Select Name'),
                    validator: FormBuilderValidators.compose(
                        [FormBuilderValidators.required(context)]),
                    items: patient.map((patient) => DropdownMenuItem(
                      value: patient,
                      child: Text('${patient.patientName}'),
                    ))
                        .toList(),
/*                     onChanged: (HospCrLtrEmpDepMasterData? newValue) {
                       setState(() {
                         _patientName = newValue!.dependentName;
                       });
                     },*/
                  ),
/*                  FormBuilderDateRangePicker(
                    name: 'date_range',
                    firstDate: DateTime(2021),
                    lastDate: DateTime(2100),
                    format: DateFormat('yyyy-MM-dd'),
                    //onChanged: _onChanged,
                    decoration: InputDecoration(
                      labelText: 'Period (From Date - To Date)',
                      //helperText: 'Enter Period',
                      // hintText: 'Enter Period',
                    ),
                  ),*/
                  FormBuilderDateTimePicker(
                    name: 'fromDate',
                    // onChanged: _onChanged,
                    inputType: InputType.date,
                    decoration: InputDecoration(
                      labelText: 'From Date',
                    ),
                    validator: FormBuilderValidators.compose(
                        [FormBuilderValidators.required(context)]),
                    //initialTime: TimeOfDay(hour: 8, minute: 0),
                     //initialValue: DateTime.now(),
                    // enabled: true,
                  ),
                  FormBuilderDateTimePicker(
                    name: 'toDate',
                    // onChanged: _onChanged,
                    inputType: InputType.date,
                    decoration: InputDecoration(
                      labelText: 'To Date',
                    ),
                    validator: FormBuilderValidators.compose(
                        [FormBuilderValidators.required(context)]),
                    //initialTime: TimeOfDay(hour: 8, minute: 0),
                    //initialValue: DateTime.now(),
                    // enabled: true,
                  ),
                  FormBuilderTextField(
                    name: 'period_days',
                    decoration: InputDecoration(
                      labelText:
                      'Period in Days',
                    ),
                    //onChanged: _onChanged,
                    // valueTransformer: (text) => num.tryParse(text),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context),
                      FormBuilderValidators.numeric(context),
                      FormBuilderValidators.max(context, 7),
                    ]),
                    keyboardType: TextInputType.number,
                  ),
                  FormBuilderChoiceChip(
                    name: 'outstation',
                    decoration: InputDecoration(
                      labelText: 'Outstation Facility',
                    ),
                    options: [
                      FormBuilderFieldOption(
                          value: 'Yes', child: Text('Yes')),
                      FormBuilderFieldOption(
                          value: 'No', child: Text('No')),
                    ],
                  ),
                  FormBuilderChoiceChip(
                    name: 'dr_recom',
                    decoration: InputDecoration(
                      labelText: 'Doctor Recommendation',
                    ),
                    options: [
                      FormBuilderFieldOption(
                          value: 'Yes', child: Text('Yes')),
                      FormBuilderFieldOption(
                          value: 'No', child: Text('No')),
                    ],
                  ),
                  FormBuilderTextField(
                    name: 'disease',
                    decoration: InputDecoration(
                      labelText:
                      'Nature of disease/surgery',
                    ),
                    //onChanged: _onChanged,
                    // valueTransformer: (text) => num.tryParse(text),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context),
                    ]),
                  ),
                  FormBuilderTextField(
                    name: 'dr_details',
                    decoration: InputDecoration(
                      labelText:
                      'Doctor name & address',
                    ),
                    //onChanged: _onChanged,
                    // valueTransformer: (text) => num.tryParse(text),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context),
                    ]),
                  ),
                  FormBuilderDropdown(
                    name: 'hospital',
                    decoration: InputDecoration(
                      labelText: 'Empanelled Institute',
                    ),
                    // initialValue: 'Male',
                    allowClear: true,
                    //hint: Text('Empanelled institute'),
                    validator: FormBuilderValidators.compose(
                        [FormBuilderValidators.required(context)]),
                    items: hospitals.map((hospital) => DropdownMenuItem(
                      value: hospital,
                      child: Text('${hospital.hospitalName}, ${hospital.hospitalCity}, ${hospital.hospitalState}'),
                    ))
                        .toList(),
                    // onChanged: (HospCrLtrHospitalMasterData? newValue) {
                    //   setState(() {
                    //     _hosptalName = newValue!.hospitalName;
                    //   });
                    // },
                  ),
                  FormBuilderTextField(
                    name: 'request',
                    decoration: InputDecoration(
                      labelText:
                      'Request',
                    ),
                    //onChanged: _onChanged,
                    // valueTransformer: (text) => num.tryParse(text),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context),
                    ]),
                  ),
                  FormBuilderTextField(
                    name: 'sp_request',
                    decoration: InputDecoration(
                      labelText:
                      'Special Request',
                    ),
                    //onChanged: _onChanged,
                    // valueTransformer: (text) => num.tryParse(text),
                    validator: FormBuilderValidators.compose([
                      //FormBuilderValidators.required(context),
                    ]),
                  ),
                  // Image Picker for Attachments
                  FormBuilderField(
                    name: "attach_files",
                    // validator: FormBuilderValidators.compose([
                    //   FormBuilderValidators.required(context),
                    // ]),
                    builder: (FormFieldState<dynamic> field) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          labelText: "Upload Prescription",
                          contentPadding:
                          EdgeInsets.only(top: 10.0, bottom: 0.0),
                          border: InputBorder.none,
                          errorText: field.errorText,
                        ),
                        child: GestureDetector(
                          onTap: (){
                            _showPicker(context);
                          },
                          child: Container(
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment : MainAxisAlignment.center,
                              children: [
                                Text('Tap to upload (Max 20MB)',style: TextStyle(color: Colors.red),),
                                Text(_attachmentName,style: TextStyle(color: Colors.black),),
                              ],
                            ),
                          ),

                        ),
                      );
                    },
                  ),

                  Row(
                    children: <Widget>[
                      Expanded(
                        child: MaterialButton(
                          color: Theme.of(context).accentColor,
                          child: Text(
                            "Submit",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            if(connectionStatus != ConnectivityResult.none){
                              _crLtrFormKey.currentState!.save();
                              if (_crLtrFormKey.currentState!.validate()) {
                                var formDataMap = _crLtrFormKey.currentState!.value;
                                var formDataMapM = Map.of(formDataMap);

                                if(_attachment != null){
                                  formDataMapM['file'] =  MultipartFile.fromFileSync(_attachment!.path, filename:_attachmentName);
                                }

                                formDataMapM['patient'] = jsonEncode(formDataMap['patient']);
                                formDataMapM['hospital'] = jsonEncode(formDataMap['hospital']);
                                //debugPrint(formData['date_range'].end.toString());
                                // formData.forEach((key, value) {
                                //   debugPrint(key + ":" + value.toString());
                                // });

                                /// From notepad

                                setState(() {
                                  isLoading = true;
                                });
                                _apiResponseData = _endpointProvider.postHosCrLtrRequest(empno,formDataMapM);

                                _apiResponseData.then((result) {
                                  if(result.isAuthenticated && result.status){
                                    //_crLtrFormKey.currentState!.reset();
                                    setState(() {
                                      isLoading = false;
                                    });
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Request successfully submitted")),
                                    );
                                  }
                                  else{
                                    //_crLtrFormKey.currentState!.reset();
                                    setState(() {
                                      isLoading = false;
                                    });
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Error in submitting request")),
                                    );
                                  }
                                }).catchError( (error) {
                                  //_crLtrFormKey.currentState!.reset();
                                  setState(() {
                                    isLoading = false;
                                  });
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error in submitting request")),
                                  );
                                });
                              } else {
                                print("validation failed");
                              }
                            }
                            else{
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("No internet connection. Please check your settings")),
                              );
                            }

                          },
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: MaterialButton(
                          color: Colors.red,
                          child: Text(
                            "Reset",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            _crLtrFormKey.currentState!.reset();
                          },
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: MaterialButton(
                          color: Colors.red,
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            _crLtrFormKey.currentState!.reset();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  getHospCrLtrMasterData(){
    final hosCrLtrMasterBox = Hive.box<HospCrLtrMasterData>('hospCrLtrMaster');
    if(hosCrLtrMasterBox.values.isEmpty){
      if(connectionStatus != ConnectivityResult.none){
        _apiResponseData = _endpointProvider.fetchHosCrLtrMasterData();
        _apiResponseData.then((result) {
          if(result.isAuthenticated && result.status){
            setState(() {
              masterData =  HospCrLtrMasterData.fromJson(jsonDecode(result.data ?? ''));
              hospitals = masterData!.hospitals;
              patient = masterData!.patient;
            });
            hosCrLtrMasterBox.add(masterData!);
          }
        });
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No internet connection. Please check your settings")),
        );
      }
    }
    else{
      setState(() {
        masterData =  hosCrLtrMasterBox.getAt(0) as HospCrLtrMasterData;
        hospitals = masterData!.hospitals;
        patient = masterData!.patient;
      });
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Gallery'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
  _imgFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
     setState(() {
       _attachment = File(image!.path);
       _attachmentName = path.basename(_attachment!.path);
     });
  }

  _imgFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      _attachment = File(image!.path);
      _attachmentName = path.basename(_attachment!.path);
    });
  }
}

Widget divider(){
  return Divider(
    color:Colors.grey,
    thickness:1,
    height:20,
    indent:10,
    endIndent:10,
  );
}
class RandomColorModel {

  Random random = Random();
  Color getColor() {
    return Color.fromARGB(random.nextInt(300), random.nextInt(300),
        random.nextInt(300), random.nextInt(300));
  }
}
class ClaimType {
  String claimType;
  String claimDesc;

  ClaimType( {required this.claimType,required this.claimDesc});

   factory ClaimType.fromJson(Map<String, dynamic> json) {
     return ClaimType(
       claimType: json['claimType'],
       claimDesc: json['claimDesc'],
     );
   }
}
Widget waiting(BuildContext context){
  return Container(
    height: MediaQuery.of(context).size.height / 1.3,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //CircularProgressIndicator(),
          Center(
            child: Lottie.asset('animations/ani_loading_hexa.json',
              width: 200,
              height: 200,),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child:Text('Serving your request. Please wait...',style: TextStyle(
              fontWeight: FontWeight.w500,fontSize: 16,),
            ),
          ),
        ],
      ),
    ),
  );
}
Widget refresh(BuildContext context){
  return Container(
    height: MediaQuery.of(context).size.height / 1.3,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Lottie.asset('animations/ani_loading_hexa.json',
              width: 200,
              height: 200,),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child:Text('Refreshing content. Please wait...',style: TextStyle(
              fontWeight: FontWeight.w500,fontSize: 16,),
            ),
          ),
        ],
      ),
    ),
  );
}
Widget noConnectivityError(){
  return Container(
      decoration: BoxDecoration(
        color: Colors.orangeAccent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.signal_wifi_connected_no_internet_4,size:30, color:Colors.black54),
          Container(
            padding:EdgeInsets.only(left:10),
            child: Center(
              child:Text('No Internet connection',style: TextStyle(
                fontWeight: FontWeight.w500,fontSize: 16,),
              ),
            ),
          ),
        ],
      )
  );
}
Color stringToColor(String color) {
  if(color == 'white'){
    return Colors.white;
  }
  else if(color == 'black'){
    return Colors.black;
  }
  else if(color == 'blue'){
    return Colors.blue;
  }
  else if(color == 'transparent'){
    return Colors.transparent;
  }
  else if(color.isEmpty || color == ''){
    return Colors.white;
  }
  else{
    //color = color.replaceAll("#", "");
    if (color.length == 6) {
      return Color(int.parse("0xFF"+color));
    } else if (color.length == 8) {
      return Color(int.parse("0x"+color));
    }
    else{
      return Colors.transparent;
    }
  }
}
Brightness stringToBrightness(String brightness) {
  if(Platform.isAndroid){
    if(brightness == 'dark'){
      return Brightness.dark;
    }
    else return Brightness.light;
  }
  else if(Platform.isIOS){
    if(brightness == 'dark'){
      return Brightness.light;
    }
    else return Brightness.dark;
  }
  else return Brightness.light;
}








