
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:open_file/open_file.dart';
import 'fonts_icons/connect_app_icon_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_projects/services/webservice.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'account.dart';
import 'constants.dart';
import 'main.dart';
import 'models/models.dart';
import 'dart:io' as io;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;

class Home extends StatefulWidget {
  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home>  {
  late  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  @override
  void initState(){
    super.initState();
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
      body: Container(
        padding:EdgeInsets.only(top: 10),
        //decoration: BoxDecoration(color:Colors.amberAccent),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          padding: EdgeInsets.all(10.0), // 3px padding all around

          children: <Widget>[
            makeDashboardItem("News & Events",const Icon(ConnectAppIcon.newspaper,size:30, color:Colors.blue),Colors.blue,newsRoute),
            makeDashboardItem("People",const Icon(ConnectAppIcon.users,size:30, color:Colors.pink),Colors.pink,peopleRoute),
            makeDashboardItem("Documents",const Icon(ConnectAppIcon.article_alt,size:30, color:Colors.green),Colors.green,documentsRoute),
            makeDashboardItem("Leave Quota",const Icon(Icons.info,size:30, color:Colors.orange),Colors.orange,leaveQuotaRoute),
            makeDashboardItem("Holiday List",const Icon(ConnectAppIcon.calendar,size:30, color:Colors.brown),Colors.brown,holidayListRoute),
            makeDashboardItem("Payslips", const Icon(ConnectAppIcon.rupee_sign,size:30, color:Colors.cyan),Colors.cyan,payslipRoute),
            makeDashboardItem("Attendance",const Icon(Icons.fingerprint,size:30, color:Colors.deepPurple),Colors.deepPurple,attendanceRoute),
            makeDashboardItem("Shift Roster",const Icon(ConnectAppIcon.calendar_alt,size:30, color:Colors.teal),Colors.teal,shiftRosterRoute),
            makeDashboardItem("Claims",const Icon(ConnectAppIcon.file_alt,size:30, color:Colors.red),Colors.red,homeRoute),

          ],
        ),
      ),
    );
  }

  Card makeDashboardItem(String title, Widget icon, MaterialColor colour, String routeName){
    return Card(
      //elevation: 1.0,
      //margin: EdgeInsets.all(10.0),

      child: Container(
        decoration: BoxDecoration(color:Colors.white10),
        height:30,
        child: InkWell(
          onTap: (){
            //Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => News()));
            Navigator.pushNamed(context, routeName);
          },
          child:Column(
            children:
            [
              SizedBox(height:20),
              icon,
              Text(title,
                  style: TextStyle(fontSize: 15, color: Colors.black),
                  textAlign: TextAlign.center)
            ],
          ),
        ),
      ),
    );
  }
}

class AppDrawer extends StatefulWidget {
  @override
  State<AppDrawer> createState() => AppDrawerState();
}

class AppDrawerState extends State<AppDrawer> {

  @override
  void initState(){
    super.initState();
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
              Navigator.pushNamed(context, feedbackRoute);
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

class LeaveQuotas extends StatefulWidget {
  @override
  State<LeaveQuotas> createState() => _LeaveQuotaState();
}
class _LeaveQuotaState extends State<LeaveQuotas>{
  late LeaveQuota _leaveQuotaData;
  late Future<APIResponseData> _apiResponseData;
  bool isLoading = true;

  @override
  void initState(){
    super.initState();
    DioClient _dio = new DioClient();
    var _endpointProvider = new EndPointProvider(_dio.init());
    _apiResponseData = _endpointProvider.fetchLeaveQuota(empno);
    _apiResponseData.then((result) {
      if(result.isAuthenticated && result.status){
        setState(() {
          _leaveQuotaData = LeaveQuota.fromJson(jsonDecode(result.data ?? ''));
          isLoading = false;
        });
      }
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
      body: isLoading? Container(
        height: MediaQuery.of(context).size.height / 1.3,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Container(
                padding: EdgeInsets.all(10),
                child:Text('Getting your data. Please wait...',style: TextStyle(
                  fontWeight: FontWeight.w500,fontSize: 18,),
                ),
              ),
            ],
          ),
        ),

      ) : ListView(
        padding: EdgeInsets.all(10.0),
        children: [
          descSection("Casual Leave (CL)",_leaveQuotaData.QuotaCL,Icons.star),
          descSection("Earned Leave (EL)",_leaveQuotaData.QuotaEL,Icons.star),
          descSection("Half Pay Leave (HPL)",_leaveQuotaData.QuotaHPL,Icons.star),
          descSection("Restricted Holiday Leave (RH)",_leaveQuotaData.QuotaRH,Icons.star),
          descSection("Compensatory Off Leave (COFF)",_leaveQuotaData.QuotaCOFF,Icons.star),

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
  bool isLoading = true;
  TabController? _tabController;
  final List<Tab> myTabs = <Tab>[
    Tab(text: 'General Holiday'),
    Tab(text: 'Restricted Holiday'),
  ];

  @override
  void initState(){
    //_tabController = TabController(length: 2, vsync: this);
    _tabController = TabController(vsync: this, length: myTabs.length);
    super.initState();
    DioClient _dio = new DioClient();
    var _endpointProvider = new EndPointProvider(_dio.init());
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
      }
    });
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
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
        bottom:TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),
      ),
      endDrawer: AppDrawer(),
      body: isLoading? Container(
        height: MediaQuery.of(context).size.height / 1.3,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Container(
                padding: EdgeInsets.all(10),
                child:Text('Getting your data. Please wait...',style: TextStyle(
                  fontWeight: FontWeight.w500,fontSize: 18,),
                ),
              ),
            ],
          ),
        ),

      ) : TabBarView(
          controller: _tabController,
          children: [
            createHolidayList(_ghList),
            createHolidayList(_rhList),
          ]
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
              ),
          );
        }
    );
  }
}

class AppFeedback extends StatelessWidget  {
  final _formKey = GlobalKey<FormState>();
  final feedbackTextContrl = TextEditingController();

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
      body: feedbackForm(),
    );
  }

  Form feedbackForm(){
    return Form(
      key: _formKey,
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
              child: Center( child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(content: Text('Thank you for your valuable feedback')),
                    // );
                  }
                },
                child: const Text('Submit'),
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutApp extends StatefulWidget {
  @override
  State<AboutApp> createState() => _AboutAppState();
}
class _AboutAppState extends State<AboutApp>{
  String appName = '';
  String packageName = '';
  String version = '';
  String buildNumber = '';

  @override
  void initState(){
    getPackageInfo();
    super.initState();
  }
  getPackageInfo(){
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        appName = packageInfo.appName;
        packageName = packageInfo.packageName;
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
            Row(
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
            ),
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

              },
              child: const Text('Check for updates'),
            ),
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
      body: getDownloadedFiles(),
    );
  }

  FutureBuilder getDownloadedFiles(){
    return FutureBuilder<List<FileSystemEntity>>(
      future: file,
      builder: (BuildContext context, AsyncSnapshot<List<FileSystemEntity>> snapshot){
        if (snapshot.hasData) {
          List<FileSystemEntity>? data = snapshot.data;
          if(data!.isNotEmpty){
            return Container(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      itemCount: data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          child: createDownloadList(data,index),
                        );
                      },
                    ),
                  ),
                ],
              ),
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

  Row createDownloadList(data,index){
    String extension = path.extension((data[index] as File).path);
    String fileName = path.basenameWithoutExtension((data[index] as File).path);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        InkWell(
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
        ),
      ],
    );
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








