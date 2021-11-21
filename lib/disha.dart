
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_projects/services/webservice.dart';
import 'package:intl/intl.dart';

import 'app_drawer.dart';
import 'constants.dart';
import 'fonts_icons/connect_app_icon_icons.dart';
import 'home.dart';
import 'main.dart';
import 'models/models.dart';

class Disha extends StatefulWidget {
  @override
  State<Disha> createState() => DishaState();
}
class DishaState extends State<Disha>{
  late DioClient _dio;
  late var _endpointProvider;
  late Future<APIResponseData> _apiResponseData;
  bool isLoading = false;


  final _shiftRosterFormKey = GlobalKey<FormState>();
  final _attRegulFormKey = GlobalKey<FormState>();

  final shiftFromDateContrl = TextEditingController();
  final shiftToDateContrl = TextEditingController();
  DateTime shiftSelectedFromDate = DateTime.now();
  DateTime shiftSelectedToDate = DateTime.now();

  final attRegInTimeContrl = TextEditingController();
  final attRegOutTimeContrl = TextEditingController();
  final attRegReasonContrl = TextEditingController();
  DateTime attRegIntime = DateTime.now();
  DateTime attRegOutTime = DateTime.now();


  late List<ShiftRoster> shiftRosterData;

  @override
  void initState() {
    super.initState();
    _dio = new DioClient();
    _endpointProvider = new EndPointProvider(_dio.init());
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
          title: Text('Disha',style: TextStyle(
            color:appBarTextColor,
          ),),
        ),
        endDrawer: AppDrawer(),
        body: Container(
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
                    makeDashboardItem("Shift Roster",const Icon(ConnectAppIcon.calendar_alt,size:30, color:Colors.teal),Colors.teal,shiftRosterRoute),
                    makeDashboardItem("Regularise Attendance",const Icon(Icons.schedule,size:30, color:Colors.deepPurple),Colors.red,homeRoute),
                    makeDashboardItem("ECOFF & Overtime",const Icon(Icons.payments,size:30, color:Colors.lime),Colors.red,ecofOTRoute),
                    makeDashboardItem("Hosp. Credit Letter",const Icon(Icons.local_hospital,size:30, color:Colors.red),Colors.red,hosCrLtrRoute),
                    makeDashboardItem("Address Proof Certificate",const Icon(Icons.home,size:30, color:Colors.blue),Colors.blue,hosCrLtrRoute),
                    makeDashboardItem("Address Change",const Icon(Icons.edit_location,size:30, color:Colors.amber),Colors.amber,hosCrLtrRoute),
                    makeDashboardItem("Outside Employment",const Icon(Icons.work,size:30, color:Colors.brown),Colors.red,hosCrLtrRoute),
                    makeDashboardItem("Medical Benefit",const Icon(Icons.medication,size:30, color:Colors.purple),Colors.red,hosCrLtrRoute),
                    makeDashboardItem("Higher Education",const Icon(Icons.school,size:30, color:Colors.deepPurple),Colors.red,hosCrLtrRoute),
                    makeDashboardItem("Leased Accomodation",const Icon(Icons.night_shelter,size:30, color:Colors.blueGrey),Colors.red,hosCrLtrRoute),
                    makeDashboardItem("HRA Application",const Icon(Icons.store,size:30, color:Colors.orange),Colors.red,hosCrLtrRoute),
                    makeDashboardItem("Quarter Allotment",const Icon(Icons.maps_home_work,size:30, color:Colors.lightBlueAccent),Colors.red,hosCrLtrRoute),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
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
          if(title == "Shift Roster"){
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
          else{
            if(connectionStatus != ConnectivityResult.none){
              Navigator.pushNamed(context, routeName);
            }
            else{
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("No internet connection. Please check your settings")),
              );
            }
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
}