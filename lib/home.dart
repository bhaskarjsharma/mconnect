
import 'dart:convert';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_projects/services/webservice.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'account.dart';
import 'constants.dart';
import 'main.dart';
import 'models/models.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home>  {
  late  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  @override
  void initState(){
    super.initState();

    flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings();
    final initSettings = InitializationSettings(android: android, iOS: iOS);
    flutterLocalNotificationsPlugin.initialize(initSettings, onSelectNotification: onSelectNotification);
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
            makeDashboardItem("News & Events",const Icon(FontAwesome.newspaper,size:30, color:Colors.blue),Colors.blue,newsRoute),
            makeDashboardItem("People",const Icon(FontAwesome.users,size:30, color:Colors.pink),Colors.pink,peopleRoute),
            makeDashboardItem("Documents",const Icon(FontAwesome.file_pdf,size:30, color:Colors.green),Colors.green,documentsRoute),
            makeDashboardItem("Leave Quota",const Icon(FontAwesome.info_circled,size:30, color:Colors.orange),Colors.orange,leaveQuotaRoute),
            makeDashboardItem("Holiday List",const Icon(FontAwesome.calendar_empty,size:30, color:Colors.brown),Colors.brown,holidayListRoute),
            makeDashboardItem("Payslips", const Icon(FontAwesome.rupee,size:30, color:Colors.cyan),Colors.cyan,homeRoute),
            makeDashboardItem("Attendance",const Icon(FontAwesome.bank,size:30, color:Colors.deepPurple),Colors.deepPurple,homeRoute),
            makeDashboardItem("Shift Roster",const Icon(FontAwesome.calendar,size:30, color:Colors.teal),Colors.teal,homeRoute),
            makeDashboardItem("ITAC",const Icon(FontAwesome.laptop,size:30, color:Colors.red),Colors.red,homeRoute),
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

  Future<void> showNotification(Map<String, dynamic> downloadStatus) async {
    final android = AndroidNotificationDetails(
        'channel id',
        'channel name',
        'channel description',
        priority: Priority.high,
        importance: Importance.max
    );
    final iOS = IOSNotificationDetails();
    final platform = NotificationDetails(android: android, iOS: iOS);
    final json = jsonEncode(downloadStatus);
    final isSuccess = downloadStatus['isSuccess'];

    await flutterLocalNotificationsPlugin.show(
        0, // notification id
        isSuccess ? 'Success' : 'Failure',
        isSuccess ? 'File has been downloaded successfully!' : 'There was an error while downloading the file.',
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
}

class AppDrawer extends StatefulWidget {
  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final String user = prefs.getString('name') ?? '';
  final String empno = prefs.getString('empno') ?? '';
  final String designation = prefs.getString('designation') ?? '';
  final String discipline = prefs.getString('discipline') ?? '';
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
                      child: Text(designation,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(discipline,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
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
            leading: Icon(Icons.security_update,color: Colors.green, size:25),
            title: const Text('Check Updates'),
            onTap: () {
              Navigator.pushNamed(context, homeRoute);
            },
          ),
          ListTile(
            leading: Icon(Icons.feedback,color: Colors.orange, size:25),
            title: const Text('Feedback'),
            onTap: () {
              Navigator.pushNamed(context, homeRoute);
            },
          ),
          ListTile(
            leading: Icon(Icons.info,color: Colors.black45, size:25),
            title: const Text('About'),
            onTap: () {
              Navigator.pushNamed(context, homeRoute);
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => Login()), (Route<dynamic> route) => false);
  }
}

class LeaveQuotas extends StatefulWidget {
  @override
  State<LeaveQuotas> createState() => _LeaveQuotaState();
}
class _LeaveQuotaState extends State<LeaveQuotas>{
  late Future<LeaveQuota> _leaveQuotaData;
  String _empno = '';

  @override
  void initState(){
    super.initState();
    //SharedPreferences prefs = SharedPreferences.getInstance() as SharedPreferences;
    _empno = prefs.getString('empno') ?? '';
    _leaveQuotaData = fetchLeaveQuota(_empno);
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
      body: getQuota(),
    );
  }
  FutureBuilder getQuota(){
    return FutureBuilder<LeaveQuota>(
      future: _leaveQuotaData,
      builder: (BuildContext context, snapshot){
        if (snapshot.hasData) {
          LeaveQuota? data = snapshot.data;
           return ListView(
             padding: EdgeInsets.all(10.0),
             children: [
               descSection("Casual Leave (CL)",snapshot.data!.QuotaCL,Icons.star),
               descSection("Earned Leave (EL)",snapshot.data!.QuotaEL,Icons.star),
               descSection("Half Pay Leave (HPL)",snapshot.data!.QuotaHPL,Icons.star),
               descSection("Restricted Holiday Leave (RH)",snapshot.data!.QuotaRH,Icons.star),
               descSection("Compensatory Off Leave (COFF)",snapshot.data!.QuotaCOFF,Icons.star),

             ],
           );

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
  late Future<List<HolidayList>> _holidayListData;
  TabController? _tabController;
  @override
  void initState(){
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
    _holidayListData = fetchHolidayList();
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
      body: getHolidayList(),
    );
  }
  FutureBuilder getHolidayList(){
    return FutureBuilder<List<HolidayList>>(
      future: _holidayListData,
      builder: (BuildContext context, snapshot){
        if (snapshot.hasData) {
          //LeaveQuota? data = snapshot.data;
          return Column(
            children: [
              TabBar(
                controller: _tabController,
                // give the indicator a decoration (color and border radius)
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    25.0,
                  ),
                  color: Colors.green,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                tabs: [
                  // first tab [you can add an icon using the icon property]
                  Tab(
                    text: 'Place Bid',
                  ),

                  // second tab [you can add an icon using the icon property]
                  Tab(
                    text: 'Buy Now',
                  ),
                ],
              ),
              // tab bar view here
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // first tab bar view widget
                    Center(
                      child: Text(
                        'Place Bid',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // second tab bar view widget
                    Center(
                      child: Text(
                        'Buy Now',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
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








