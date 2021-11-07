
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_projects/services/webservice.dart';

import 'app_drawer.dart';
import 'constants.dart';
import 'home.dart';
import 'main.dart';
import 'models/models.dart';

class ShiftRosterView extends StatefulWidget {
  @override
  State<ShiftRosterView> createState() => _ShiftRosterViewState();
}
class _ShiftRosterViewState extends State<ShiftRosterView>{
  @override
  void initState() {
    super.initState();
    startColor = stringToColor(prefs.getString('startColor') ?? 'white');
    endColor = stringToColor(prefs.getString('endColor') ?? 'white');
    textColor = stringToColor(prefs.getString('textColor') ?? 'black');
    appBarBackgroundColor = stringToColor(prefs.getString('appBarBackgroundColor') ?? 'blue');
    appBarTextColor = stringToColor(prefs.getString('appBarTextColor') ?? 'white');
    statusBarBrightness = stringToBrightness(prefs.getString('statusBarBrightness') ?? 'light');
  }
  @override
  Widget build(BuildContext context) {
    final List<ShiftRoster> shiftRosterData = ModalRoute.of(context)!.settings.arguments as List<ShiftRoster>;
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
          title: Text('Shift Roster',style: TextStyle(
            color:appBarTextColor,
          ),),
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
                      child: Text("Date",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold, color: appBarTextColor)),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text("Shift",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold, color: appBarTextColor)),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text("Approved",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold, color: appBarTextColor)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: createList(shiftRosterData),
            ),
          ],
        ),
      ),
    );
  }

  ListView createList(data){
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
                      child: Text(data[index].shift ?? ''),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1, // takes 30% of available width
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Text(data[index].approved ?? ''),
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
