
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_projects/services/permissions.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/services/webservice.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io' as io;
import 'account.dart';
import 'constants.dart';
import 'content.dart';
import 'fonts_icons/connect_app_icon_icons.dart';
import 'home.dart';
import 'main.dart';
import 'models/models.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {
  @override
  State<AppDrawer> createState() => AppDrawerState();
}
class AppDrawerState extends State<AppDrawer> {
  bool isLoading = false;
  final _feedbackFormKey = GlobalKey<FormState>();
  final feedbackTextContrl = TextEditingController();
  late Future<APIResponseData> _apiResponseData;
  late DioClient _dio;
  late var _endpointProvider;
  bool bioAuth = false;

  @override
  void initState(){
    super.initState();
    _dio = new DioClient();
    _endpointProvider = new EndPointProvider(_dio.init());
    if(localAuthEnabled){
      setState((){
        bioAuth = localAuthEnabled;
      });
    }
/*    startColor = stringToColor(prefs.getString('startColor') ?? 'white');
    endColor = stringToColor(prefs.getString('endColor') ?? 'white');
    textColor = stringToColor(prefs.getString('textColor') ?? 'black');
    appBarBackgroundColor = stringToColor(prefs.getString('appBarBackgroundColor') ?? 'blue');
    appBarTextColor = stringToColor(prefs.getString('appBarTextColor') ?? 'white');
    statusBarBrightness = stringToBrightness(prefs.getString('statusBarBrightness') ?? 'light');*/
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 270,
            child: DrawerHeader(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        //colors: [Color.fromRGBO(255, 239, 186, 1), Color.fromRGBO(255, 255, 255, 1)]
                        colors: [startColor, endColor]
                    )
                ),
                child: Column(
                  children: [
                    Container(
                      padding:EdgeInsets.all(8),
                      height:130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12),
                        image: DecorationImage (
                          image: CachedNetworkImageProvider("https://connect.bcplindia.co.in/MobileAppAPI/imageFile?empno="+empno),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(user,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color:textColor,
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(designation + " (" + discipline +")",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          color:textColor,
                        ),
                      ),
                    ),
                  ],
                )
            ),
          ),
          ListTile(
            leading: Icon(Icons.home,color: Colors.blueAccent, size:25),
            title: const Text('Home'),
            onTap: () {

              //Navigator.pushNamed(context, homeRoute);
              //to prevent multiple back press, close all views and go to home
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => Home()), (Route<dynamic> route) => false);
            },
          ),
          ListTile(
            leading: Icon(Icons.download,color: Colors.green, size:25),
            title: const Text('Downloads'),
            onTap: () {
              Navigator.pushNamed(context, downloadsRoute);
            },
          ),
          ListTile(
            leading: Icon(Icons.feedback,color: Colors.orange, size:25),
            title: const Text('Feedback'),
            onTap: () {
              if(connectionStatus != ConnectivityResult.none){
                Navigator.pop(context);
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
                                height: height - (height/2.5),
                                width: width - (width/4),
                                child: isLoading ? waiting(context) : Form(
                                  key: _feedbackFormKey,
                                  child: Container(
                                    margin: EdgeInsets.symmetric(vertical: 20),
                                    child:Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Center(
                                          child:Lottie.asset('animations/ani_feedback.json',
                                            width: 150,
                                            height: 150,),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(0),
                                          child: Center(child: Text('Please provide your feedback',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16,
                                                color: Colors.blue[500],
                                              ))) ,
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          child: TextFormField(
                                            controller: feedbackTextContrl,
                                            maxLines: 5,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: 'Feedback',
                                            ),
                                            // The validator receives the text that the user has entered.
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter your feedback';
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
                                                  if (_feedbackFormKey.currentState!.validate()) {

                                                    setState(() {
                                                      isLoading = true;
                                                    });

                                                    String platform = '';
                                                    String appVersion = '';
                                                    String buildNumber = '';

                                                    if(Platform.isAndroid){
                                                      platform = 'Android';
                                                    }
                                                    else if(Platform.isIOS){
                                                      platform = 'IOS';
                                                    }
                                                    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
                                                      setState(() {
                                                        appVersion = packageInfo.version;
                                                        buildNumber = packageInfo.buildNumber;
                                                      });
                                                    });

                                                    _apiResponseData = _endpointProvider.postFeedback(feedbackTextContrl.text,platform,appVersion,buildNumber);
                                                    _apiResponseData.then((result) {
                                                      if(result.isAuthenticated && result.status){
                                                        setState(() {
                                                          isLoading = false;
                                                          feedbackTextContrl.text = '';
                                                          Navigator.pop(context);
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text("Feedback submitted")),
                                                          );
                                                        });
                                                      }
                                                      else{
                                                        setState(() {
                                                          isLoading = false;
                                                          feedbackTextContrl.text = '';
                                                        });
                                                        Navigator.pop(context);
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text("Error in feedback submission")),
                                                        );
                                                      }
                                                    }).catchError( (error) {
                                                      setState(() {
                                                        feedbackTextContrl.text = '';
                                                        isLoading = false;
                                                      });
                                                      Navigator.pop(context);
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text("Error in feedback submission")),
                                                      );
                                                    });
                                                  }
                                                },
                                                child: const Text('Submit'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    feedbackTextContrl.text = '';
                                                    isLoading = false;
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
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("No internet connection. Please check your settings")),
                );
              }

            },
          ),
          ListTile(
            leading: Icon(Icons.info,color: Colors.black45, size:25),
            title: const Text('App Info & Updates'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, aboutAppRoute);
            },
          ),
          ListTile(
            leading: Icon(Icons.fingerprint,color: Colors.deepPurple, size:25),
            title: const Text('Additional Authentication'),
            trailing:
            CupertinoSwitch(
              value: bioAuth,
              onChanged: (bool value) async{
                setState(() { bioAuth = value; });
                  if(bioAuth){
                    bool isBiometricSupported = await localAuth.isDeviceSupported();
                    bool canCheckBiometrics = await localAuth.canCheckBiometrics;
                    if(isBiometricSupported && canCheckBiometrics){
                      prefs.setBool('localBioAuth', true);
                      setState((){
                        localAuthEnabled = true;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Additional authentication enabled')),
                      );
                    }
                    else{
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sorry, additional authentication is not supported on your device')),
                      );
                    }
                  }
                  else{
                    prefs.setBool('localBioAuth', false);
                    setState((){
                      localAuthEnabled = false;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Additional authentication disabled')),
                    );
                  }
                },
            ),
/*            onTap: () {
              Navigator.pop(context);
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
                              height: height - (height/2),
                              width: width - (width/4),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('Do you want to enable additional biometric/screen lock authentication',style: TextStyle(
                                      fontWeight: FontWeight.w500,fontSize: 16,),),
                                    IconButton(
                                      icon: const Icon(Icons.thumb_up,size:30, color:Colors.green),
                                      tooltip: 'Sure, enable more security',
                                      onPressed: () async{
//check if biometric auth is supported
                                        bool isBiometricSupported = await localAuth.isDeviceSupported();
                                        bool canCheckBiometrics = await localAuth.canCheckBiometrics;
                                        if(isBiometricSupported && canCheckBiometrics){
                                          prefs.setBool('localBioAuth', true);
                                          setState((){
                                            localAuthEnabled = true;
                                          });
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Additional authentication enabled')),
                                          );
                                        }
                                        else{
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Sorry, additional authentication is not supported by your device')),
                                          );
                                        }
                                      },
                                    ),
                                    Text('Sure, enable more security'),
                                    IconButton(
                                      icon: const Icon(Icons.thumb_down,size:30, color:Colors.red),
                                      tooltip: 'Sure, enable more security',
                                      onPressed: () {
                                        prefs.setBool('localBioAuth', false);
                                        setState((){
                                          localAuthEnabled = false;
                                        });
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Additional authentication disabled')),
                                        );
                                      },
                                    ),
                                    Text('No, i am good! Disable additional security'),
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
            },*/
          ),
          ListTile(
            leading: Icon(Icons.palette,color: Colors.purple, size:25),
            title: const Text('App Theme'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, appThemeRoute);
              /*showDialog(
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
                              height: height - (height/2.5),
                              width: width - (width/4),
                              child: isLoading ? waiting(context) :
                                  Column(
                                    children: [
                                      Center(
                                        child: Text('Choose App Theme')
                                      ),
                                      Expanded(
                                          child: GridView.count(
                                            primary: false,
                                            padding: const EdgeInsets.all(10),
                                            crossAxisSpacing: 10,
                                            mainAxisSpacing: 10,
                                            crossAxisCount: 3,
                                            children: [
                                              createColorCell('ffffff','ffffff','000000','459AEF','000000','dark','Light'),
                                              createColorCell('5A5959','5A5959','ffffff','5A5959','ffffff','light','Dark'),
                                              createColorCell('74ebd5','acb6e5','000000','transparent','ffffff','light','Digital Water'),
                                              createColorCell('ffefba','ffffff','000000','transparent','000000','dark','Margo'),
                                              createColorCell('d9a7c7','fffcdc','000000','transparent','000000','dark','Cherry Blossom'),
                                              createColorCell('4ac29a','bdfff3','000000','transparent','000000','dark','Cinnamint'),
                                              createColorCell('fbc2eb','a6c1ee','000000','transparent','000000','dark','Ashville'),
                                              createColorCell('84fab0','8fd3f4','000000','transparent','000000','dark','Azure'),
                                              createColorCell('a8edea','fed6e3','000000','transparent','000000','dark','Wind'),
                                              //createColorCell('d299c2','fef9d7','000000','transparent','000000','dark','Wild Apple'),
                                              createColorCell('fdfcfb','e2d1c3','000000','transparent','000000','dark','Evarlasting Sky'),
                                              createColorCell('fddb92','d1fdff','000000','transparent','000000','dark','Blessing'),
                                              createColorCell('ebbba7','cfc7f8','000000','transparent','000000','dark','Pine'),
                                              createColorCell('e6e9f0','eef1f5','000000','transparent','000000','dark','Snow'),
                                              createColorCell('accbee','e7f0fd','000000','transparent','000000','dark','Ink'),
                                              createColorCell('e9defa','fbfcdb','000000','transparent','000000','dark','Kindness'),
                                              createColorCell('d3cce3','e9e4f0','000000','transparent','000000','dark','Delicate'),
                                              createColorCell('43c6ac','f8ffae','000000','transparent','000000','dark','Honey Dew'),
                                              createColorCell('ffafbd','ffc3a0','ffffff','transparent','ffffff','light','Roseanna'),
                                            ],
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
              );*/
            },
          ),
          ListTile(
            leading: Icon(Icons.power_settings_new,color: Colors.redAccent, size:25),
            title: const Text('Logout'),
            onTap: () {
              // Update the state of the app
              logout();
            },
          ),
        ],
      ),
    );
  }

  Future<void> logout() async {
    await prefs.clear();
    await storage.deleteAll();
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => Login()), (Route<dynamic> route) => false);
  }
}

class AboutApp extends StatefulWidget {
  @override
  State<AboutApp> createState() => _AboutAppState();
}
class _AboutAppState extends State<AboutApp>{
  String appName = '';
  String version = '';
  String buildNumber = '';
  bool isLoading = false;
  late Future<APIResponseData> _apiResponseData;
  late DioClient _dio;
  late var _endpointProvider;
  String updateStatus = '';
  bool updateAvailable = false;
  late AppUpdateInfo _appUpdateInfo;
  String _downloadPerc = '' ;

  @override
  void initState(){
    getPackageInfo();
    super.initState();
    _dio = new DioClient();
    _endpointProvider = new EndPointProvider(_dio.init());

  }
  getPackageInfo(){
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        appName = packageInfo.appName;
        //packageName = packageInfo.packageName;
        version = packageInfo.version;
        buildNumber = packageInfo.buildNumber;
      });
    });
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
          title: Text('About',style: TextStyle(
            color:appBarTextColor,
          ),),
        ),
        endDrawer: AppDrawer(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Lottie.asset('animations/ani_robot.json',
                  width: 200,
                  height: 157,),
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    child: Text('App Name'),
                  ),
                  Container(
                    width: 200,
                    child: Text(appName),
                  ),
                ],
              ),
              //SizedBox(height: 10),
              /* Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  child: Text('Package Name'),
                ),
                Container(
                  width: 200,
                  child: Text(packageName),
                ),

              ],
            ),*/
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    child: Text('Version'),
                  ),
                  Container(
                    width: 200,
                    child: Text(version),
                  ),

                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    child: Text('Build Number'),
                  ),
                  Container(
                    width: 200,
                    child: Text(buildNumber),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    child: Text('Developed By'),
                  ),
                  Container(
                    width: 200,
                    child: Text('Bhaskar Jyoti Sharma, Manager (IT)'),
                  ),
                ],
              ),
              SizedBox(height: 5),
              ElevatedButton(
                onPressed: (){
                  if(connectionStatus != ConnectivityResult.none){
                    setState(() {
                      isLoading = true;
                    });
                    String appVersion = '';
                    String buildNumber = '';
                    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
                      setState(() {
                        appVersion = packageInfo.version;
                        buildNumber = packageInfo.buildNumber;
                      });
                    });
                    _apiResponseData = _endpointProvider.checkUpdate(appVersion,buildNumber);
                    _apiResponseData.then((result) {
                      if(result.isAuthenticated && result.status){
                        setState(() {
                          isLoading = false;
                          updateAvailable = true;
                          _appUpdateInfo = AppUpdateInfo.fromJson(jsonDecode(result.data ?? ''));
                          updateStatus = 'Updates available. Version: ${_appUpdateInfo.version} Build Number: ${_appUpdateInfo.buildNumber}';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('App updates available')),
                          );
                        });
                      }
                      else{
                        setState(() {
                          isLoading = false;
                          updateAvailable = false;
                          updateStatus = result.data!;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(updateStatus)),
                        );
                      }
                    }).catchError( (error) {
                      setState(() {
                        isLoading = false;
                        updateAvailable = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error in checking updates")),
                      );
                    });
                  }
                  else{
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("No internet connection. Please check your settings")),
                    );
                  }
                },
                child: const Text('Check for updates'),
              ),
              SizedBox(height: 5),
              isLoading ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Container(
                    padding: EdgeInsets.all(5),
                    child:Text('Checking for updates. Please wait...',style: TextStyle(
                      fontWeight: FontWeight.w500,fontSize: 16,),
                    ),
                  ),
                ],
              ) : Text(updateStatus),
              //SizedBox(height: 10),
              updateAvailable ? GestureDetector(
                child: Center(
                  child: Lottie.asset('animations/ani_download.json',
                    width: 120,
                    height: 120,),
                ),
                onTap: () async{
                  if(connectionStatus != ConnectivityResult.none){
                    Map<String, dynamic> result = {
                      'isSuccess': false,
                      'contentType': false,
                      'filePath': null,
                      'error': null,
                    };
                    String saveDirPath = await getDownloadDirectory();
                    String finalSavePath = path.join(saveDirPath, _appUpdateInfo.fileName);
                    String appDownloadUrl = "https://connect.bcplindia.co.in/MobileAppAPI/DownloadAppUpdate";
                    final isPermissionStatusGranted = await requestStoragePermissions();
                    if (isPermissionStatusGranted) {
                      try {
                        final Dio _dio = Dio();
                        var response = await _dio.download(appDownloadUrl,
                            finalSavePath, onReceiveProgress: (int received, int total) {
                              if (total != -1) {
                                double val = (received / total * 100) as double;
                                num mod = pow(10.0, 1);
                                setState(() {
                                  _downloadPerc = 'Downloading: ' + val.toStringAsFixed(2) + ' %';
                                  //_progress = val / 100;
                                });
                              }
                            });
                        result['isSuccess'] = response.statusCode == 200;
                        result['contentType'] = 'FileDownload';
                        result['filePath'] = finalSavePath;
                      } catch (ex) {
                        result['error'] = ex.toString();
                        setState((){
                          isLoading = false;
                          //_progress = 0.0;
                          _downloadPerc = '';
                        });
                      }
                      finally {
                        setState((){
                          isLoading = false;
                          //_progress = 0.0;
                          _downloadPerc = '';
                        });
                        await showNotification(result);
                      }
                    }
                  }
                  else{
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("No internet connection. Please check your settings")),
                    );
                  }
                },
              ): SizedBox(height: 0),
              Text(_downloadPerc),

/*            ElevatedButton(
              onPressed: () async{
                if(connectionStatus != ConnectivityResult.none){
                  Map<String, dynamic> result = {
                    'isSuccess': false,
                    'contentType': false,
                    'filePath': null,
                    'error': null,
                  };
                  String saveDirPath = await getDownloadDirectory();
                  String finalSavePath = path.join(saveDirPath, _appUpdateInfo.fileName);
                  String appDownloadUrl = "https://connect.bcplindia.co.in/MobileAppAPI/DownloadAppUpdate";
                  final isPermissionStatusGranted = await requestStoragePermissions();
                  if (isPermissionStatusGranted) {
                    try {
                      final Dio _dio = Dio();
                      var response = await _dio.download(appDownloadUrl,
                          finalSavePath, onReceiveProgress: (int received, int total) {
                            if (total != -1) {
                              double val = (received / total * 100) as double;
                              num mod = pow(10.0, 1);
                              setState(() {
                                _downloadPerc = 'Downloading: ' + val.toStringAsFixed(2) + ' %';
                                //_progress = val / 100;
                              });
                            }
                          });
                      result['isSuccess'] = response.statusCode == 200;
                      result['contentType'] = 'FileDownload';
                      result['filePath'] = finalSavePath;
                    } catch (ex) {
                      result['error'] = ex.toString();
                      setState((){
                        isLoading = false;
                        //_progress = 0.0;
                        _downloadPerc = '';
                      });
                    }
                    finally {
                      setState((){
                        isLoading = false;
                        //_progress = 0.0;
                        _downloadPerc = '';
                      });
                      await showNotification(result);
                    }
                  }
                }
                else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("No internet connection. Please check your settings")),
                  );
                }
              },
              child: const Text('Download update'),
            ) */

            ],
          ),
        ),
      ),
    );
  }
}

class DownloadDirectory extends StatefulWidget {
  @override
  State<DownloadDirectory> createState() => _DownloadDirectoryState();
}
class _DownloadDirectoryState extends State<DownloadDirectory>{
  late String directory;
  late Future<List<FileSystemEntity>> file;

  @override
  void initState(){
    super.initState();
    file = getDownloads();

  }

  Future<List<FileSystemEntity>> getDownloads() async {
    directory = await getDownloadDirectory();
    return io.Directory("$directory/").listSync();
    // setState(() {
    //   return file = io.Directory("$directory/resume/").listSync();  //use your folder name insted of resume.
    // });
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
          title: Text('Downloads',style: TextStyle(
            color:appBarTextColor,
          ),),
        ),
        endDrawer: AppDrawer(),
        body: Column(
          children: [
            SizedBox(height:10),
            Container(
              padding: EdgeInsets.all(10),
              child:Text('Tap to view. Swipe to delete',style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            Expanded(
              child:getDownloadedFiles(),
            )
          ],
        ),
      ),
    );
  }

  FutureBuilder getDownloadedFiles(){
    return FutureBuilder<List<FileSystemEntity>>(
      future: file,
      builder: (BuildContext context, AsyncSnapshot<List<FileSystemEntity>> snapshot){
        if (snapshot.hasData) {
          List<FileSystemEntity>? data = snapshot.data;
          if(data!.isNotEmpty){
            return ListView.builder(
              itemCount: data!.length,
              itemBuilder: (BuildContext context, int index) {
                final item = path.basenameWithoutExtension((data[index] as File).path);
                return Dismissible(
                  // Each Dismissible must contain a Key. Keys allow Flutter to
                  // uniquely identify widgets.
                    key: Key(item),
                    // Provide a function that tells the app
                    // what to do after an item has been swiped away.
                    onDismissed: (direction) {
                      // Remove the item from the data source.
                      (data[index] as File).delete();
                      setState(() {
                        data.removeAt(index);
                      });
                      // Then show a snackbar.
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('$item deleted')));
                    },
                    // Show a red background as the item is swiped away.
                    background: Container(color: Colors.red),
                    child: createDownloadList(data,index),
                );
              },
            );
          }
          else{
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Lottie.asset('animations/ani_empty.json',
                      width: 231,
                      height: 95,),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child:Text('Download space empty',style: TextStyle(
                      fontWeight: FontWeight.w400,fontSize: 16,),
                    ),
                  ),
                ],
              ),
            );
          }

        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return SizedBox(
          height: MediaQuery.of(context).size.height / 1.3,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Card createDownloadList(data,index){
    String extension = path.extension((data[index] as File).path);
    String fileName = path.basenameWithoutExtension((data[index] as File).path);
    Icon fileIcon = Icon(ConnectAppIcon.file_pdf, size: 20, color: Colors.red);
    if(extension == '.pdf')
      fileIcon = Icon(ConnectAppIcon.file_pdf, size: 20, color: Colors.red);
    if(extension == '.docx' || extension == '.doc')
      fileIcon = Icon(ConnectAppIcon.file_word, size: 20, color: Colors.blue);
    if(extension == '.xls' || extension == '.xlsx')
      fileIcon = Icon(ConnectAppIcon.file_excel, size: 20, color: Colors.green);

    return Card(
      child: ListTile(
        leading: fileIcon,
        title: Text(fileName,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),),
        onTap: (){
          OpenFile.open((data[index] as File).path);
        },
      ),
/*      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if(extension == '.pdf')
          Icon(ConnectAppIcon.file_pdf, size: 20, color: Colors.red),
        if(extension == '.docx' || extension == '.doc')
          Icon(ConnectAppIcon.file_word, size: 20, color: Colors.blue),
        if(extension == '.xls' || extension == '.xlsx')
          Icon(ConnectAppIcon.file_excel, size: 20, color: Colors.green),
        InkWell(
          onTap: (){
            OpenFile.open((data[index] as File).path);
          },
          child: Text(fileName,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 15,
            ),),
        ),
*//*        InkWell(
          onTap: (){
            (data[index] as File).delete();
            data.removeAt(index);
            setState(() {
              data = data;
            });
          },
          child:CircleAvatar(
            backgroundColor: Colors.black12,
            child: Icon(Icons.delete,size:20,color:Colors.black38),
          ),
        ),*//*
      ],*/
    );
  }

}

class NotificationView extends StatefulWidget {
  @override
  State<NotificationView> createState() => _NotificationViewState();
}
class _NotificationViewState extends State<NotificationView>{
  late String directory;
  //List<AppNotification> notificationList = [];
  late var _endpointProvider;
  late Future<APIResponseData> _apiResponseData;
  late List<Document> documentList;
  late DioClient _dio;

  bool notificationAvailable = false;

  @override
  void initState(){
    super.initState();
    final appNotificationBox = Hive.box<AppNotification>('appNotifications');
    if(appNotificationBox.values.isNotEmpty){
      setState((){
        notificationAvailable = true;
      });
    }
/*    final appNotificationBox = Hive.box<AppNotification>('appNotifications');
    notificationList = appNotificationBox.values.toList();*/

/*    final String savedNotificationList = prefs.getString('savedNotification') ?? '';
    if(savedNotificationList != ''){
      notificationList = AppNotification.decode(savedNotificationList);
    }*/
    _dio = new DioClient();
    _endpointProvider = new EndPointProvider(_dio.init());
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
          title: Text('Notifications',style: TextStyle(
            color:appBarTextColor,
          ),),
        ),
        endDrawer: AppDrawer(),
        body: notificationAvailable ? Column(
          children: [
            SizedBox(height:10),
            Container(
              padding: EdgeInsets.all(10),
              child:Text('Tap to view. Swipe to delete',style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box<AppNotification>('appNotifications').listenable(),
                builder: (context, Box<AppNotification> items, widget) {
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = items.getAt(index)!.notificationTitle;
                      return Dismissible(
                        // Each Dismissible must contain a Key. Keys allow Flutter to
                        // uniquely identify widgets.
                        key: Key(item),
                        onDismissed: (direction) {
                          // Remove the item from the data source.
                          items.deleteAt(index);
                          // Then show a snackbar.
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text('$item dismissed')));
                        },
                        // Show a red background as the item is swiped away.
                        background: Container(color: Colors.red),
                        child: ListTile(
                          title: Text(items.getAt(index)!.notificationTitle),
                          subtitle: Text(items.getAt(index)!.notificationBody),
                          onTap: (){
                            if(items.getAt(index)!.contentType == 'News'){
                              if(items.getAt(index)!.contentID != ''){
                                if(connectionStatus != ConnectivityResult.none){
                                  Navigator.pushNamed(context, newsDisplayRoute, arguments: NewsWithAttchArguments(
                                      items.getAt(index)!.contentID),
                                  );
                                }
                                else{
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("No internet connection. Please check your settings")),
                                  );
                                }
                                //Navigator.pushNamed(context, newsDisplayRoute, arguments: notificationList[index].contentID,);
                              }
                              else{
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error in fetching data")),
                                );
                              }
                            }
                            else if(items.getAt(index)!.contentType == 'Document'){
                              if(items.getAt(index)!.notificationTitle != ''){
                                if(connectionStatus != ConnectivityResult.none){
                                  _apiResponseData = _endpointProvider.fetchDocuments(items.getAt(index)!.notificationTitle,'');
                                  _apiResponseData.then((result) {
                                    if(result.isAuthenticated && result.status){
                                      final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
                                      setState(() {
                                        documentList =  parsed.map<Document>((json) => Document.fromJson(json)).toList();
                                        Navigator.pop(context);
                                        Navigator.pushNamed(context, documentsRoute, arguments: documentList,);
                                      });
                                    }
                                    else{
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Error in data fetching")),
                                      );
                                    }
                                  }).catchError( (error) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Error in data fetching")),
                                    );
                                  });
                                }
                                else{
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("No internet connection. Please check your settings")),
                                  );
                                }
                              }
                              else{
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error in fetching data")),
                                );
                              }
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),

/*            child:ListView.builder(
              itemCount: notificationList!.length,
              itemBuilder: (BuildContext context, int index) {
                final item = notificationList[index].notificationBody;
                return Dismissible(
                  // Each Dismissible must contain a Key. Keys allow Flutter to
                  // uniquely identify widgets.
                  key: Key(item),
                  // Provide a function that tells the app
                  // what to do after an item has been swiped away.
                  onDismissed: (direction) {
                    // Remove the item from the data source.
                    setState(() {
                      notificationList.removeAt(index);
                    });
                    final appNotificationBox = Hive.box<AppNotification>('appNotifications');
                    appNotificationBox.deleteAt(index);

                    final String encodedData = AppNotification.encode(notificationList);
                    prefs.setString('savedNotification', encodedData);

                    if(notificationList.isEmpty){
                      prefs.remove('savedNotification');
                    }
                    // Then show a snackbar.
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('$item dismissed')));
                  },
                  // Show a red background as the item is swiped away.
                  background: Container(color: Colors.red),
                  child: ListTile(
                    title: Text(notificationList[index].notificationTitle),
                    subtitle: Text(notificationList[index].notificationBody),
                    onTap: (){
                      if(notificationList[index].contentType == 'News'){
                        if(notificationList[index].contentID != ''){
                          Navigator.pushNamed(context, newsDisplayRoute, arguments: NewsWithAttchArguments(
                              notificationList[index].contentID),
                          );
                          //Navigator.pushNamed(context, newsDisplayRoute, arguments: notificationList[index].contentID,);
                        }
                      }
                      else if(notificationList[index].contentType == 'Document'){
                        if(notificationList[index].notificationTitle != ''){
                          _apiResponseData = _endpointProvider.fetchDocuments(notificationList[index].notificationTitle,'');
                          _apiResponseData.then((result) {
                            if(result.isAuthenticated && result.status){
                              final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
                              setState(() {
                                documentList =  parsed.map<Document>((json) => Document.fromJson(json)).toList();
                                Navigator.pop(context);
                                Navigator.pushNamed(context, documentsRoute, arguments: documentList,);
                              });
                            }
                            else{
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error in data fetching")),
                              );
                            }
                          }).catchError( (error) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error in data fetching")),
                            );
                          });
                        }
                      }
                    },
                  ),
                );
              },
            ),*/
            )
          ],
        ) : Container(
          height: MediaQuery.of(context).size.height / 1.3,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Lottie.asset('animations/ani_empty.json',
                    width: 231,
                    height: 95,),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child:Text('Notification space empty',style: TextStyle(
                    fontWeight: FontWeight.w400,fontSize: 16,),
                  ),
                ),
                /*Icon(Icons.notifications_none),
              Container(
                padding: EdgeInsets.all(10),
                child:Text('No pending notifications',style: TextStyle(
                  fontWeight: FontWeight.w500,fontSize: 16,),
                ),
              ),*/
              ],
            ),
          ),
        ),
      ),
    );

  }
}

class AppTheme extends StatefulWidget {
  @override
  State<AppTheme> createState() => _AppThemeState();
}
class _AppThemeState extends State<AppTheme>{
  late Color localStartColor;
  late Color localendColor;
  late Color localtextColor;
  late Color localappBarBackgroundColor;
  late Color localappBarTextColor;
  late Brightness localstatusBarBrightness;

  String localThemeName = '';
  String startColorTxt = '';
  String endColorTxt = '';
  String textColorTxt = '';
  String appBarBackgroundColorTxt = '';
  String appBarTextColorTxt = '';
  String statusBarBrightnessTxt = '';

  @override
  initState() {
    super.initState();
    localThemeName = themePrefs.getString('appTheme') ?? 'kindness';
    localStartColor = stringToColor(themePrefs.getString('startColor') ?? 'e9defa');
    localendColor = stringToColor(themePrefs.getString('endColor') ?? 'fbfcdb');
    localtextColor = stringToColor(themePrefs.getString('textColor') ?? '000000');
    localappBarBackgroundColor = stringToColor(themePrefs.getString('appBarBackgroundColor') ?? 'transparent');
    localappBarTextColor = stringToColor(themePrefs.getString('appBarTextColor') ?? '000000');
    localstatusBarBrightness = stringToBrightness(themePrefs.getString('statusBarBrightness') ?? 'dark');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              //colors: [Color.fromRGBO(255, 239, 186, 1), Color.fromRGBO(255, 255, 255, 1)]
              colors: [localStartColor, localendColor]
          )
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          iconTheme: IconThemeData(
              color: localappBarTextColor
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: localappBarBackgroundColor,
            statusBarIconBrightness: localstatusBarBrightness,),
          backgroundColor: localappBarBackgroundColor,
          bottomOpacity: 0.0,
          elevation: 0,
          leading: Container(
            width: 40,
            child: Image.asset('images/bcpl_logo.png'),
          ),
          title: Text('App Theme',style: TextStyle(
            color:localappBarTextColor,
          ),),
        ),
        endDrawer: AppDrawer(),
        body: Column(
          children: [
            Center(
                child: Text(localThemeName,style: TextStyle(fontSize: 18, color: localtextColor ),
                    textAlign: TextAlign.center)
            ),
            Expanded(
              child: GridView.count(
                primary: false,
                padding: const EdgeInsets.all(10),
                crossAxisSpacing: 0,
                mainAxisSpacing: 0,
                crossAxisCount: 4,
                children: [
                  createColorCell('ffffff','ffffff','000000','459AEF','ffffff','Light','Light'),
                  createColorCell('121212','121212','ffffff','121212','ffffff','light','Dark'),
                  createColorCell('74ebd5','acb6e5','000000','transparent','ffffff','light','Digital Water'),
                  createColorCell('ffefba','ffffff','000000','transparent','000000','dark','Margo'),
                  createColorCell('d9a7c7','fffcdc','000000','transparent','000000','dark','Cherry Blossom'),
                  createColorCell('4ac29a','bdfff3','000000','transparent','000000','dark','Cinnamint'),
                  createColorCell('fbc2eb','a6c1ee','000000','transparent','000000','dark','Ashville'),
                  createColorCell('84fab0','8fd3f4','000000','transparent','000000','dark','Azure'),
                  createColorCell('a8edea','fed6e3','000000','transparent','000000','dark','Wind'),
                  //createColorCell('d299c2','fef9d7','000000','transparent','000000','dark','Wild Apple'),
                  createColorCell('fdfcfb','e2d1c3','000000','transparent','000000','dark','Evarlasting Sky'),
                  createColorCell('fddb92','d1fdff','000000','transparent','000000','dark','Blessing'),
                  createColorCell('ebbba7','cfc7f8','000000','transparent','000000','dark','Pine'),
                  createColorCell('e6e9f0','eef1f5','000000','transparent','000000','dark','Snow'),
                  createColorCell('accbee','e7f0fd','000000','transparent','000000','dark','Ink'),
                  createColorCell('e9defa','fbfcdb','000000','transparent','000000','dark','Kindness'),
                  createColorCell('d3cce3','e9e4f0','000000','transparent','000000','dark','Delicate'),
                  createColorCell('43c6ac','f8ffae','000000','transparent','000000','dark','Honey Dew'),
                  createColorCell('ffafbd','ffc3a0','000000','transparent','000000','light','Roseanna'),
                  createColorCell('c79081','dfa579','000000','transparent','000000','light','Desert'),
                  createColorCell('8baaaa','ae8b9c','ffffff','transparent','ffffff','light','Jungle Day'),
                  createColorCell('abecd6','fbed96','000000','transparent','000000','dark','Over Sun'),
                  createColorCell('e6b980','eacda3','000000','transparent','000000','dark','Caramel'),
                  createColorCell('d7d2cc','304352','ffffff','transparent','ffffff','dark','Metal'),
                  createColorCell('616161','9bc5c3','ffffff','transparent','ffffff','dark','Mole Hall'),
                  createColorCell('dfe9f3','ffffff','000000','transparent','000000','dark','Glass'),
                  createColorCell('243949','517fa4','ffffff','transparent','ffffff','light','Stone'),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            setState((){
              startColor = stringToColor(startColorTxt);
              endColor = stringToColor(endColorTxt);
              textColor = stringToColor(textColorTxt);
              appBarBackgroundColor = stringToColor(appBarBackgroundColorTxt);
              appBarTextColor = stringToColor(appBarTextColorTxt);
              statusBarBrightness = stringToBrightness(statusBarBrightnessTxt);
            });
            themePrefs.setString('appTheme', localThemeName);
            themePrefs.setString('startColor', startColorTxt);
            themePrefs.setString('endColor', endColorTxt);
            themePrefs.setString('textColor', textColorTxt);
            themePrefs.setString('appBarBackgroundColor', appBarBackgroundColorTxt);
            themePrefs.setString('appBarTextColor', appBarTextColorTxt);
            themePrefs.setInt('appBarElevation', 0);
            themePrefs.setString('statusBarBrightness', statusBarBrightnessTxt);
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => Home()), (Route<dynamic> route) => false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Theme Set")),
            );
          },
          label: const Text('Set Theme'),
          icon: const Icon(Icons.thumb_up),
          backgroundColor: Colors.lightBlue,
        ),
      ),
    );

  }
  GestureDetector createColorCell(String start,String end,String bodyTextColor,String appBarBackColor,
      String appBarTextColour,String statusBarBright,String colorName){
    return GestureDetector(
      child: Column(
        children: [
          Container(
            height:30,
            width:30,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: Colors.black12),
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [stringToColor(start), stringToColor(end)]
                )
            ),
          ),
          Text(colorName,
              style: TextStyle(fontSize: 14, color: localtextColor ),
              textAlign: TextAlign.center),
        ],
      ),
      onTap: (){
        setState((){
          localThemeName = colorName;
          localStartColor = stringToColor(start);
          localendColor = stringToColor(end);
          localtextColor = stringToColor(bodyTextColor);
          localappBarBackgroundColor = stringToColor(appBarBackColor);
          localappBarTextColor = stringToColor(appBarTextColour);
          //appBarElevation = 0;
          localstatusBarBrightness = stringToBrightness(statusBarBright);

          startColorTxt = start;
          endColorTxt = end;
          textColorTxt = bodyTextColor;
          appBarBackgroundColorTxt = appBarBackColor;
          appBarTextColorTxt = appBarTextColour;
          statusBarBrightnessTxt = statusBarBright;
        });

        //Navigator.pop(context);
        //Navigator.pushNamed(context, homeRoute);
        //Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => Home()), (Route<dynamic> route) => false);
      },
    );
  }
}

class NewsWithAttchArguments{
  final String contentId;

  NewsWithAttchArguments(this.contentId);
}