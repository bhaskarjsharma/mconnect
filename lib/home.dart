
import 'dart:convert';


import 'package:flutter_projects/services/webservice.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'account.dart';
import 'constants.dart';
import 'main.dart';
import 'models/models.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>  {

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
            makeDashboardItem("News & Events",Icons.feed,Colors.blue,newsRoute),
            makeDashboardItem("People",Icons.people,Colors.pink,peopleRoute),
            makeDashboardItem("Documents",Icons.collections,Colors.green,documentsRoute),
            makeDashboardItem("Leave Quota",Icons.date_range,Colors.orange,leaveQuotaRoute),
            makeDashboardItem("Holiday List",Icons.today,Colors.brown,holidayListRoute),
            makeDashboardItem("Documents",Icons.collections,Colors.green,homeRoute),

          ],
        ),
      ),
    );
  }

  Card makeDashboardItem(String title, IconData icon, MaterialColor colour, String routeName){
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
              Icon(icon,size:40.0,
                color: colour,
              ),
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
          //LeaveQuota? data = snapshot.data;
          return ListView(
            padding: EdgeInsets.all(10.0),
            children: [
              Container(
                padding: EdgeInsets.all(10.0),
                height: 50,
                color: Colors.amber[100],
                child: Text('CL : '+ snapshot.data!.QuotaCL,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,

                      fontSize: 20,
                    )),
              ),
              Container(
                padding: EdgeInsets.all(10.0),
                height: 50,
                color: Colors.amber[200],
                child: Text('EL : '+ snapshot.data!.QuotaEL,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,

                      fontSize: 20,
                    )),
              ),
              Container(
                height: 50,
                padding: EdgeInsets.all(10.0),
                color: Colors.amber[100],
                child: Text('HPL : '+ snapshot.data!.QuotaHPL,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,

                      fontSize: 20,
                    )),
              ),
              Container(
                height: 50,
                padding: EdgeInsets.all(10.0),
                color: Colors.amber[200],
                child: Text('RH : '+ snapshot.data!.QuotaRH,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,

                      fontSize: 20,
                    )),
              ),
              Container(
                height: 50,
                padding: EdgeInsets.all(10.0),
                color: Colors.amber[100],
                child: Text('COFF : '+ snapshot.data!.QuotaCOFF,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,

                      fontSize: 20,
                    )),
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
}






