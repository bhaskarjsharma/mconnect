
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_projects/services/webservice.dart';
import 'app_drawer.dart';
import 'constants.dart';
import 'home.dart';
import 'main.dart';
import 'models/models.dart';

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
    final List<AttendanceData> attendanceData = ModalRoute.of(context)!.settings.arguments as List<AttendanceData>;
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          width: 40,
          child: Image.asset('images/bcpl_logo.png'),
        ),
        title: Text('Connect - People'),
      ),
      endDrawer: AppDrawer(),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color:Color.fromRGBO(165, 231, 206, 1.0),
            ),
            height: 40.0,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text("Date",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text("Punch Date",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text("Punch Time",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
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
