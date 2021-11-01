
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_projects/services/permissions.dart';
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
                  color: Color.fromRGBO(165, 231, 206, 1.0),
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
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(designation + " (" + discipline +")",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
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
                              height: height - (height/2.3),
                              width: width - (width/4),
                              child: isLoading ? waiting(context) : Form(
                                key: _feedbackFormKey,
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 20),
                                  child:Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        child: Center(child: Text('Please provide your feedback',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 20,
                                              color: Colors.blue[500],
                                            ))) ,
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        child: TextFormField(
                                          controller: feedbackTextContrl,
                                          maxLines: 8,
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
            },
          ),
          ListTile(
            leading: Icon(Icons.info,color: Colors.black45, size:25),
            title: const Text('App Info & Updates'),
            onTap: () {
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
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          width: 40,
          child: Image.asset('images/bcpl_logo.png'),
        ),
        title: Text('Connect'),
      ),
      endDrawer: AppDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('images/bcpl_logo.png'),
            SizedBox(height: 10),
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
            SizedBox(height: 10),
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
            SizedBox(height: 10),
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
            SizedBox(height: 10),
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
            SizedBox(height: 10),
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: (){
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
              },
              child: const Text('Check for updates'),
            ),
            SizedBox(height: 10),
            isLoading ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                Container(
                  padding: EdgeInsets.all(10),
                  child:Text('Checking for updates. Please wait...',style: TextStyle(
                    fontWeight: FontWeight.w500,fontSize: 16,),
                  ),
                ),
              ],
            ) : Text(updateStatus),
            SizedBox(height: 10),
            updateAvailable ? ElevatedButton(
              onPressed: () async{
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
              },
              child: const Text('Download update'),
            ) : SizedBox(height: 0),
            Text(_downloadPerc),
          ],
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
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          width: 40,
          child: Image.asset('images/bcpl_logo.png'),
        ),
        title: Text('Connect'),
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
            return Center(child:Text('Downloads folder empty'),);
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
  List<AppNotification> notificationList = [];
  late var _endpointProvider;
  late Future<APIResponseData> _apiResponseData;
  late List<Document> documentList;
  late DioClient _dio;

  @override
  void initState(){
    super.initState();
    final String savedNotificationList = prefs.getString('savedNotification') ?? '';
    if(savedNotificationList != ''){
      notificationList = AppNotification.decode(savedNotificationList);
    }
    _dio = new DioClient();
    _endpointProvider = new EndPointProvider(_dio.init());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          width: 40,
          child: Image.asset('images/bcpl_logo.png'),
        ),
        title: Text('Connect'),
      ),
      endDrawer: AppDrawer(),
      body: notificationList.isNotEmpty? Column(
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
            child:ListView.builder(
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
            ),
          )
        ],
      ) : Container(
        height: MediaQuery.of(context).size.height / 1.3,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.notifications_none),
              Container(
                padding: EdgeInsets.all(10),
                child:Text('No pending notifications',style: TextStyle(
                  fontWeight: FontWeight.w500,fontSize: 16,),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class NewsWithAttchArguments{
  final String contentId;

  NewsWithAttchArguments(this.contentId);
}