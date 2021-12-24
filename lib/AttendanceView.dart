
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_projects/services/webservice.dart';
import 'app_drawer.dart';
import 'constants.dart';
import 'home.dart';
import 'main.dart';
import 'models/models.dart';

class BiometricPunchView extends StatefulWidget {
  @override
  State<BiometricPunchView> createState() => _BiometricPunchViewState();
}
class _BiometricPunchViewState extends State<BiometricPunchView>{

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<BioPunchData> attendanceData = ModalRoute.of(context)!.settings.arguments as List<BioPunchData>;
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
          title: Text('Punch Times',style: TextStyle(
            color:appBarTextColor,
          ),),
        ),
        endDrawer: AppDrawer(),
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                //color:Color.fromRGBO(165, 231, 206, 1.0),
              ),
              height: 40.0,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text("Date",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold, color: appBarTextColor)),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text("Punch Date",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold, color: appBarTextColor)),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text("Punch Time",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold, color: appBarTextColor)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: createListAttendance(attendanceData),
            ),
          ],
        ),
      ),
    );
  }
  ListView createListAttendance(data){
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Card(
            child: Row(
              children: [
                Expanded(
                  flex: 1, // takes 30% of available width
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Text(data[index].date ?? ''),
                    ),
                  ),

                ),
                Expanded(
                  flex: 1, // takes 30% of available width
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Text(data[index].punchDate ?? ''),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1, // takes 30% of available width
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Text(data[index].punchTime ?? ''),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }
}

class AttendanceView extends StatefulWidget {
  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}
class _AttendanceViewState extends State<AttendanceView>{

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AttendanceData attendanceData = ModalRoute.of(context)!.settings.arguments as AttendanceData;
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
          title: Text('Attendance',style: TextStyle(
            color:appBarTextColor,
          ),),
        ),
        endDrawer: AppDrawer(),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  width:60,
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(left:5,bottom: 5),
                  alignment: Alignment.centerLeft,
                  child: Text('From'),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  width:100,
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(left:3,right:5,bottom: 5),
                  alignment: Alignment.centerLeft,
                  child: Text('${attendanceData.Begda}',textAlign: TextAlign.center,),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  width:60,
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(left:5,bottom: 5),
                  alignment: Alignment.centerLeft,
                  child: Text('To'),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  width:100,
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(left:3,right:5,bottom: 5),
                  alignment: Alignment.centerLeft,
                  child: Text('${attendanceData.Endda}',textAlign: TextAlign.center,),
                ),
              ],
            ),
            buildRow('Absent','${attendanceData.absent_count}','',''),
            buildRow('First Absent','${attendanceData.first_abs_count}','Second Absent','${attendanceData.second_abs_count}'),
            //buildRow('Second Half Absent','${attendanceData.second_abs_count}'),
            buildRow('In Missing','${attendanceData.in_miss_count}','Out Missing','${attendanceData.out_miss_count}'),
            //buildRow('Out Missing','${attendanceData.out_miss_count}'),
            buildRow('In Late','${attendanceData.in_late_count}','Out Early','${attendanceData.out_early_count}'),
            //buildRow('Out Early','${attendanceData.out_early_count}'),
            //buildRow('Relx. In Time','${attendanceData.in_relax_count}','Relx. Out Time','${attendanceData.out_relax_count}'),
            //buildRow('Relaxable Out Time','${attendanceData.out_relax_count}'),

            Container(
              decoration: BoxDecoration(
                //color:Color.fromRGBO(165, 231, 206, 1.0),
              ),
              height: 40.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black12,
                  border: Border.all(
                    color: Colors.black12,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text("Date",style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal, color: appBarTextColor)),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text("Shift",style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal, color: appBarTextColor)),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text("Attend.",style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal, color: appBarTextColor)),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text("In & Out Time",style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal, color: appBarTextColor)),
                      ),
                    ),
/*                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text("In Time",style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal, color: appBarTextColor)),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text("Out Date",style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal, color: appBarTextColor)),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text("Out Time",style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal, color: appBarTextColor)),
                    ),
                  ),*/
                  ],
                ),
              ),

            ),
            Expanded(
              child: createListAttendance(attendanceData.AttndData),
            ),
          ],
        ),
      ),
    );
  }
  Row buildRow(String title1, String data1,String title2, String data2){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,

          ),
          width:120,
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(left:5,bottom: 5),
          alignment: Alignment.centerLeft,
          child: Text(title1),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
          width:50,
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(left:3,right:5,bottom: 5),
          alignment: Alignment.centerLeft,
          child: Text(data1,textAlign: TextAlign.center,),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
          width:120,
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(left:5,bottom: 5),
          alignment: Alignment.centerLeft,
          child: Text(title2),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
          width:50,
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(left:3,right:5,bottom: 5),
          alignment: Alignment.centerLeft,
          child: Text(data2,textAlign: TextAlign.center,),
        ),
      ],
    );
  }
  ListView createListAttendance(data){
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Card(
            child: Row(
              children: [
                Expanded(
                  flex: 1, // takes 30% of available width
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Text(data[index].ShiftDt ?? ''),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1, // takes 30% of available width
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Text(data[index].Shift ?? ''),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1, // takes 30% of available width
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Text(data[index].Attendance ?? ''),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2, // takes 30% of available width
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Text('${data[index].InDate} ${data[index].InTime}'  ?? ''),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Text('${data[index].OutDate} ${data[index].OutTime}'  ?? ''),
                      ),
                    ],
                  ),
                ),
/*                Expanded(
                  flex: 1, // takes 30% of available width
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Text(data[index].InTime ?? ''),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1, // takes 30% of available width
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Text(data[index].OutDate ?? ''),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1, // takes 30% of available width
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Text(data[index].OutTime ?? ''),
                    ),
                  ),
                ),*/
              ],
            ),
          );
        }
    );
  }
}