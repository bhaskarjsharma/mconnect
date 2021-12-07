
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_projects/services/webservice.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
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
                    makeDashboardItem("Address Proof Certificate",const Icon(Icons.home,size:30, color:Colors.blue),Colors.blue,addrProofRoute),
                    makeDashboardItem("Address Change",const Icon(Icons.edit_location,size:30, color:Colors.amber),Colors.amber,addrChangeRoute),
                    makeDashboardItem("Outside Employment",const Icon(Icons.work,size:30, color:Colors.brown),Colors.red,outEmpRoute),
                    makeDashboardItem("Medical Benefit",const Icon(Icons.medication,size:30, color:Colors.purple),Colors.red,medBenefitRoute),
                    makeDashboardItem("Higher Education",const Icon(Icons.school,size:30, color:Colors.deepPurple),Colors.red,highEduRoute),
                    makeDashboardItem("Leased Accomodation",const Icon(Icons.night_shelter,size:30, color:Colors.blueGrey),Colors.red,claRoute),
                    makeDashboardItem("HRA Application",const Icon(Icons.store,size:30, color:Colors.orange),Colors.red,hraRoute),
                    makeDashboardItem("Quarter Allotment",const Icon(Icons.maps_home_work,size:30, color:Colors.lightBlueAccent),Colors.red,qtrAllocRoute),
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

class AddProofApp extends StatefulWidget {
  @override
  State<AddProofApp> createState() => AddProofAppState();
}
class AddProofAppState extends State<AddProofApp>{
  late DioClient _dio;
  late var _endpointProvider;
  late Future<APIResponseData> _apiResponseData;
  bool isLoading = false;
  final _addProofFormKey = GlobalKey<FormBuilderState>();

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
        body: isLoading ? waiting(context) : SingleChildScrollView(
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
                child: Text('Address Proof Certificate',style: TextStyle(
                  fontWeight: FontWeight.w500,fontSize: 18,),),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white30,
                ),
                padding: EdgeInsets.all(15),
                child: FormBuilder(
                  key: _addProofFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      FormBuilderChoiceChip(
                        name: 'cert_type',
                        decoration: InputDecoration(
                          labelText: 'Certificate Type',
                          helperText: 'Certificate will be issued as per address maintained in SAP',
                        ),
                        options: [
                          FormBuilderFieldOption(
                              value: 'Present Address', child: Text('Present Address')),
                          FormBuilderFieldOption(
                              value: 'Permanent Address', child: Text('Permanent Address')),
                        ],
                        validator: FormBuilderValidators.compose(
                            [FormBuilderValidators.required(context)]),
                      ),
                      FormBuilderTextField(
                        name: 'req_for_pur',
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText:
                          'Required For',
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
                                  _addProofFormKey.currentState!.save();
                                  var formDataMap = _addProofFormKey.currentState!.value;

                                  if (_addProofFormKey.currentState!.validate()) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    _apiResponseData = _endpointProvider.postAddCertRequest(formDataMap);

                                    _apiResponseData.then((result) {
                                      if(result.isAuthenticated && result.status){
                                        setState(() {
                                          isLoading = false;
                                        });
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Request successfully submitted")),
                                        );
                                      }
                                      else{
                                        setState(() {
                                          isLoading = false;
                                        });
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Error: ${result.error_details}")),
                                        );
                                      }
                                    }).catchError( (error) {
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
                                _addProofFormKey.currentState!.reset();
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
                                _addProofFormKey.currentState!.reset();
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
        ),
      ),
    );
  }
}

class AddChangeApp extends StatefulWidget {
  @override
  State<AddChangeApp> createState() => AddChangeAppState();
}
class AddChangeAppState extends State<AddChangeApp>{
  late DioClient _dio;
  late var _endpointProvider;
  late Future<APIResponseData> _apiResponseData;
  bool isLoading = false;
  final _addChangeFormKey = GlobalKey<FormBuilderState>();
  final ImagePicker _picker = ImagePicker();
  File? _attachment;
  String _attachmentName = '';

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
        body: isLoading ? waiting(context) : SingleChildScrollView(
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
                child: Text('Address Change Request',style: TextStyle(
                  fontWeight: FontWeight.w500,fontSize: 18,),),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white30,
                ),
                padding: EdgeInsets.all(15),
                child: FormBuilder(
                  key: _addChangeFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      FormBuilderChoiceChip(
                        name: 'req_type',
                        decoration: InputDecoration(
                          labelText: 'Address Type',
                          //helperText: 'Certificate will be issued as per address maintained in SAP',
                        ),
                        options: [
                          FormBuilderFieldOption(
                              value: 'Present Address', child: Text('Present Address')),
                          FormBuilderFieldOption(
                              value: 'Permanent Address', child: Text('Permanent Address')),
                        ],
                        validator: FormBuilderValidators.compose(
                            [FormBuilderValidators.required(context)]),
                      ),
                      FormBuilderTextField(
                        name: 'address',
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText:
                          'Address',
                        ),
                        //onChanged: _onChanged,
                        // valueTransformer: (text) => num.tryParse(text),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context),
                        ]),
                      ),
                      FormBuilderField(
                        name: "attach_files",
                        // validator: FormBuilderValidators.compose([
                        //   FormBuilderValidators.required(context),
                        // ]),
                        builder: (FormFieldState<dynamic> field) {
                          return InputDecorator(
                            decoration: InputDecoration(
                              labelText: "Upload Proof of Address",
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
                                  _addChangeFormKey.currentState!.save();
                                  var formDataMap = _addChangeFormKey.currentState!.value;
                                  var formDataMapM = Map.of(formDataMap);

                                  if(_attachment != null){
                                    formDataMapM['file'] =  MultipartFile.fromFileSync(_attachment!.path, filename:_attachmentName);
                                  }

                                  if (_addChangeFormKey.currentState!.validate()) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    _apiResponseData = _endpointProvider.postAddChangeRequest(formDataMapM);

                                    _apiResponseData.then((result) {
                                      if(result.isAuthenticated && result.status){
                                        setState(() {
                                          isLoading = false;
                                        });
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Request successfully submitted")),
                                        );
                                      }
                                      else{
                                        setState(() {
                                          isLoading = false;
                                        });
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Error: ${result.error_details}")),
                                        );
                                      }
                                    }).catchError( (error) {
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
                                _addChangeFormKey.currentState!.reset();
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
                                _addChangeFormKey.currentState!.reset();
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
        ),
      ),
    );
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

class OutEmpApp extends StatefulWidget {
  @override
  State<OutEmpApp> createState() => OutEmpAppState();
}
class OutEmpAppState extends State<OutEmpApp>{
  late DioClient _dio;
  late var _endpointProvider;
  late Future<APIResponseData> _apiResponseData;
  bool isLoading = false;
  final _outEmpFormKey = GlobalKey<FormBuilderState>();
  final ImagePicker _picker = ImagePicker();
  File? _attachment;
  String _attachmentName = '';

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
        body: isLoading ? waiting(context) : SingleChildScrollView(
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
                child: Text('Outside Employment Request',style: TextStyle(
                  fontWeight: FontWeight.w500,fontSize: 18,),),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white30,
                ),
                padding: EdgeInsets.all(15),
                child: FormBuilder(
                  key: _outEmpFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      FormBuilderChoiceChip(
                        name: 'req_type',
                        decoration: InputDecoration(
                          labelText: 'Request Type',
                          //helperText: 'Certificate will be issued as per address maintained in SAP',
                        ),
                        options: [
                          FormBuilderFieldOption(
                              value: 'intimation', child: Text('Intimation of Application')),
                          FormBuilderFieldOption(
                              value: 'NOC', child: Text('Request for NOC')),
                          FormBuilderFieldOption(
                              value: 'prop_chnl', child: Text('Proper Channel Forwarding')),
                        ],
                        validator: FormBuilderValidators.compose(
                            [FormBuilderValidators.required(context)]),
                      ),
                      FormBuilderTextField(
                        name: 'org_name',
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText:
                          'Name of Organization',
                        ),
                        //onChanged: _onChanged,
                        // valueTransformer: (text) => num.tryParse(text),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context),
                        ]),
                      ),
                      FormBuilderTextField(
                        name: 'post_applied',
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText:
                          'Position / Post Applied',
                        ),
                        //onChanged: _onChanged,
                        // valueTransformer: (text) => num.tryParse(text),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context),
                        ]),
                      ),
                      FormBuilderTextField(
                        name: 'advt_no',
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText:
                          'Advertisement Number',
                        ),
                        //onChanged: _onChanged,
                        // valueTransformer: (text) => num.tryParse(text),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context),
                        ]),
                      ),
                      FormBuilderField(
                        name: "attach_files",
                        // validator: FormBuilderValidators.compose([
                        //   FormBuilderValidators.required(context),
                        // ]),
                        builder: (FormFieldState<dynamic> field) {
                          return InputDecorator(
                            decoration: InputDecoration(
                              labelText: "Attachment (Advertisement/Call Letter)",
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
                                  _outEmpFormKey.currentState!.save();
                                  var formDataMap = _outEmpFormKey.currentState!.value;
                                  var formDataMapM = Map.of(formDataMap);

                                  if(_attachment != null){
                                    formDataMapM['file'] =  MultipartFile.fromFileSync(_attachment!.path, filename:_attachmentName);
                                  }
                                  if (_outEmpFormKey.currentState!.validate()) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    _apiResponseData = _endpointProvider.postOutEmpRequest(formDataMapM);

                                    _apiResponseData.then((result) {
                                      if(result.isAuthenticated && result.status){
                                        setState(() {
                                          isLoading = false;
                                        });
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Request successfully submitted")),
                                        );
                                      }
                                      else{
                                        setState(() {
                                          isLoading = false;
                                        });
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Error: ${result.error_details}")),
                                        );
                                      }
                                    }).catchError( (error) {
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
                                _outEmpFormKey.currentState!.reset();
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
                                _outEmpFormKey.currentState!.reset();
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
        ),
      ),
    );
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

class MedBenApp extends StatefulWidget {
  @override
  State<MedBenApp> createState() => MedBenAppState();
}
class MedBenAppState extends State<MedBenApp>{
  late DioClient _dio;
  late var _endpointProvider;
  late Future<APIResponseData> _apiResponseData;
  bool isLoading = false;
  final _medBenefitFormKey = GlobalKey<FormBuilderState>();
  final ImagePicker _picker = ImagePicker();
  File? _attachment;
  String _attachmentName = '';

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
        body: isLoading ? waiting(context) : SingleChildScrollView(
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
                child: Text('Medical Benefit Request',style: TextStyle(
                  fontWeight: FontWeight.w500,fontSize: 18,),),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white30,
                ),
                padding: EdgeInsets.all(15),
                child: FormBuilder(
                  key: _medBenefitFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      FormBuilderChoiceChip(
                        name: 'req_type',
                        decoration: InputDecoration(
                          labelText: 'Request Type',
                          //helperText: 'Certificate will be issued as per address maintained in SAP',
                        ),
                        options: [
                          FormBuilderFieldOption(
                              value: 'med_extension', child: Text('Extension of expired medical bill for reimbursement')),
                          FormBuilderFieldOption(
                              value: 'med_purchase', child: Text('Permission for medicine purchase for more than 30 days')),
                          FormBuilderFieldOption(
                              value: 'pres_validity', child: Text('Permission for medicine purchase after 3 days of prescription')),
                        ],
                        validator: FormBuilderValidators.compose(
                            [FormBuilderValidators.required(context)]),
                      ),
                      FormBuilderTextField(
                        name: 'reason',
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText:
                          'Reason / Remarks',
                        ),
                        //onChanged: _onChanged,
                        // valueTransformer: (text) => num.tryParse(text),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context),
                        ]),
                      ),
                      FormBuilderTextField(
                        name: 'pres_no',
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText:
                          'Prescription Number',
                        ),
                        //onChanged: _onChanged,
                        // valueTransformer: (text) => num.tryParse(text),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context),
                        ]),
                      ),
                      FormBuilderDateTimePicker(
                        name: 'pres_date',
                        // onChanged: _onChanged,
                        inputType: InputType.date,
                        decoration: InputDecoration(
                          labelText: 'Prescription Date',
                          //helperText: 'Date of Coff/Overtime',
                        ),
                        validator: FormBuilderValidators.compose(
                            [FormBuilderValidators.required(context)]),
                        //lastDate: lastDateforClaim,
                        firstDate: DateTime(2019,3,1),
                        //initialTime: TimeOfDay(hour: 8, minute: 0),
                        initialValue: DateTime.now(),
                        onChanged: (DateTime? newValue) {
                        },
                        // enabled: true,
                      ),
                      FormBuilderTextField(
                        name: 'bill_no',
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText:
                          'Bill Number',
                        ),
                        //onChanged: _onChanged,
                        // valueTransformer: (text) => num.tryParse(text),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context),
                        ]),
                      ),
                      FormBuilderDateTimePicker(
                        name: 'bill_date',
                        // onChanged: _onChanged,
                        inputType: InputType.date,
                        decoration: InputDecoration(
                          labelText: 'Bill Date',
                          //helperText: 'Date of Coff/Overtime',
                        ),
                        validator: FormBuilderValidators.compose(
                            [FormBuilderValidators.required(context)]),
                        //lastDate: lastDateforClaim,
                        firstDate: DateTime(2019,3,1),
                        //initialTime: TimeOfDay(hour: 8, minute: 0),
                        initialValue: DateTime.now(),
                        onChanged: (DateTime? newValue) {
                        },
                        // enabled: true,
                      ),
                      FormBuilderField(
                        name: "attach_files",
                        // validator: FormBuilderValidators.compose([
                        //   FormBuilderValidators.required(context),
                        // ]),
                        builder: (FormFieldState<dynamic> field) {
                          return InputDecorator(
                            decoration: InputDecoration(
                              labelText: "Prescription / Bill",
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
                                  _medBenefitFormKey.currentState!.save();
                                  var formDataMap = _medBenefitFormKey.currentState!.value;
                                  var formDataMapM = Map.of(formDataMap);

                                  if(_attachment != null){
                                    formDataMapM['file'] =  MultipartFile.fromFileSync(_attachment!.path, filename:_attachmentName);
                                  }
                                  if (_medBenefitFormKey.currentState!.validate()) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    _apiResponseData = _endpointProvider.postMedBenefitRequest(formDataMapM);

                                    _apiResponseData.then((result) {
                                      if(result.isAuthenticated && result.status){
                                        setState(() {
                                          isLoading = false;
                                        });
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Request successfully submitted")),
                                        );
                                      }
                                      else{
                                        setState(() {
                                          isLoading = false;
                                        });
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Error: ${result.error_details}")),
                                        );
                                      }
                                    }).catchError( (error) {
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
                                _medBenefitFormKey.currentState!.reset();
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
                                _medBenefitFormKey.currentState!.reset();
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
        ),
      ),
    );
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

class HighEduApp extends StatefulWidget {
  @override
  State<HighEduApp> createState() => HighEduAppState();
}
class HighEduAppState extends State<HighEduApp>{
  late DioClient _dio;
  late var _endpointProvider;
  late Future<APIResponseData> _apiResponseData;
  bool isLoading = false;
  final _highEduFormKey = GlobalKey<FormBuilderState>();
  final ImagePicker _picker = ImagePicker();
  File? _attachment;
  String _attachmentName = '';

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
        body: isLoading ? waiting(context) : SingleChildScrollView(
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
                child: Text('Permission for Higher Education',style: TextStyle(
                  fontWeight: FontWeight.w500,fontSize: 18,),),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white30,
                ),
                padding: EdgeInsets.all(15),
                child: FormBuilder(
                  key: _highEduFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      FormBuilderTextField(
                        name: 'course_name',
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText:
                          'Course Name',
                        ),
                        //onChanged: _onChanged,
                        // valueTransformer: (text) => num.tryParse(text),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context),
                        ]),
                      ),
                      FormBuilderTextField(
                        name: 'course_duration',
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText:
                          'Course Duration (Months)',

                        ),
                        //onChanged: _onChanged,
                        // valueTransformer: (text) => num.tryParse(text),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context),
                        ]),
                        keyboardType: TextInputType.number,
                      ),
                      FormBuilderChoiceChip(
                        name: 'course_mode',
                        decoration: InputDecoration(
                          labelText: 'Course Type',
                          //helperText: 'Certificate will be issued as per address maintained in SAP',
                        ),
                        options: [
                          FormBuilderFieldOption(
                              value: 'classroom', child: Text('Classroom Course')),
                          FormBuilderFieldOption(
                              value: 'distance', child: Text('Distance / Open Learning')),
                          FormBuilderFieldOption(
                              value: 'online', child: Text('Online Course')),
                          FormBuilderFieldOption(
                              value: 'multi_mode', child: Text('Combination of Classroom and Other Modes')),
                        ],
                        validator: FormBuilderValidators.compose(
                            [FormBuilderValidators.required(context)]),
                      ),
                      FormBuilderTextField(
                        name: 'inst_name',
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText:
                          'Institute Name',
                        ),
                        //onChanged: _onChanged,
                        // valueTransformer: (text) => num.tryParse(text),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context),
                        ]),
                      ),
                      FormBuilderTextField(
                        name: 'inst_addr',
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText:
                          'Institute Address',
                        ),
                        //onChanged: _onChanged,
                        // valueTransformer: (text) => num.tryParse(text),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context),
                        ]),
                      ),
                      FormBuilderChoiceChip(
                        name: 'course_relevant',
                        decoration: InputDecoration(
                          labelText: 'Whether Course is relevant to current job/role in BCPL',
                          //helperText: 'Certificate will be issued as per address maintained in SAP',
                        ),
                        options: [
                          FormBuilderFieldOption(
                              value: 'Yes', child: Text('Yes')),
                          FormBuilderFieldOption(
                              value: 'No', child: Text('No')),
                        ],
                        validator: FormBuilderValidators.compose(
                            [FormBuilderValidators.required(context)]),
                      ),
                      FormBuilderField(
                        name: "attach_files",
                        // validator: FormBuilderValidators.compose([
                        //   FormBuilderValidators.required(context),
                        // ]),
                        builder: (FormFieldState<dynamic> field) {
                          return InputDecorator(
                            decoration: InputDecoration(
                              labelText: "Attachment",
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
                                  _highEduFormKey.currentState!.save();
                                  var formDataMap = _highEduFormKey.currentState!.value;
                                  var formDataMapM = Map.of(formDataMap);

                                  if(_attachment != null){
                                    formDataMapM['file'] =  MultipartFile.fromFileSync(_attachment!.path, filename:_attachmentName);
                                  }
                                  if (_highEduFormKey.currentState!.validate()) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    _apiResponseData = _endpointProvider.postHighEduRequest(formDataMapM);

                                    _apiResponseData.then((result) {
                                      if(result.isAuthenticated && result.status){
                                        setState(() {
                                          isLoading = false;
                                        });
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Request successfully submitted")),
                                        );
                                      }
                                      else{
                                        setState(() {
                                          isLoading = false;
                                        });
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Error: ${result.error_details}")),
                                        );
                                      }
                                    }).catchError( (error) {
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
                                _highEduFormKey.currentState!.reset();
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
                                _highEduFormKey.currentState!.reset();
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
        ),
      ),
    );
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

class CLAApp extends StatefulWidget {
  @override
  State<CLAApp> createState() => CLAAppState();
}
class CLAAppState extends State<CLAApp>{
  late DioClient _dio;
  late var _endpointProvider;
  late Future<APIResponseData> _apiResponseData;
  bool isLoading = false;
  final _claFormKey = GlobalKey<FormBuilderState>();
  final ImagePicker _picker = ImagePicker();
  File? _attachment;
  String _attachmentName = '';

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
        body: isLoading ? waiting(context) : SingleChildScrollView(
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
                child: Text('Leased Accomodation Request',style: TextStyle(
                  fontWeight: FontWeight.w500,fontSize: 18,),),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white30,
                ),
                padding: EdgeInsets.all(15),
                child: FormBuilder(
                  key: _claFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      FormBuilderChoiceChip(
                        name: 'req_type',
                        decoration: InputDecoration(
                          labelText: 'Request Type',
                          //helperText: 'Certificate will be issued as per address maintained in SAP',
                        ),
                        options: [
                          FormBuilderFieldOption(
                              value: 'New', child: Text('Fresh/New Lease')),
                          FormBuilderFieldOption(
                              value: 'Renewal', child: Text('Lease Renewal')),
                        ],
                        validator: FormBuilderValidators.compose(
                            [FormBuilderValidators.required(context)]),
                      ),
                      FormBuilderChoiceChip(
                        name: 'acc_loc',
                        decoration: InputDecoration(
                          labelText: 'Location',
                          //helperText: 'Certificate will be issued as per address maintained in SAP',
                        ),
                        options: [
                          FormBuilderFieldOption(
                              value: 'Duliajan', child: Text('Duliajan')),
                          FormBuilderFieldOption(
                              value: 'Guwahati', child: Text('Guwahati')),
                          FormBuilderFieldOption(
                              value: 'Lakwa', child: Text('Lakwa/Sivsagar')),
                          FormBuilderFieldOption(
                              value: 'Lepetkata', child: Text('Lepetkata/Dibrugarh')),
                          FormBuilderFieldOption(
                              value: 'Noida/Delhi', child: Text('Noida/Delhi')),

                        ],
                        validator: FormBuilderValidators.compose(
                            [FormBuilderValidators.required(context)]),
                      ),
                      FormBuilderTextField(
                        name: 'acc_add',
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText:
                          'Accomodation Address',
                        ),
                        //onChanged: _onChanged,
                        // valueTransformer: (text) => num.tryParse(text),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context),
                        ]),
                      ),
                      FormBuilderDateTimePicker(
                        name: 'from_date',
                        // onChanged: _onChanged,
                        inputType: InputType.date,
                        decoration: InputDecoration(
                          labelText: 'Lease From Date',
                          //helperText: 'Date of Coff/Overtime',
                        ),
                        validator: FormBuilderValidators.compose(
                            [FormBuilderValidators.required(context)]),
                        //lastDate: lastDateforClaim,
                        firstDate: DateTime(2019,3,1),
                        //initialTime: TimeOfDay(hour: 8, minute: 0),
                        initialValue: DateTime.now(),
                        onChanged: (DateTime? newValue) {
                        },
                        // enabled: true,
                      ),
                      FormBuilderDateTimePicker(
                        name: 'to_date',
                        // onChanged: _onChanged,
                        inputType: InputType.date,
                        decoration: InputDecoration(
                          labelText: 'Lease To Date',
                          //helperText: 'Date of Coff/Overtime',
                        ),
                        validator: FormBuilderValidators.compose(
                            [FormBuilderValidators.required(context)]),
                        //lastDate: lastDateforClaim,
                        firstDate: DateTime(2019,3,1),
                        //initialTime: TimeOfDay(hour: 8, minute: 0),
                        initialValue: DateTime.now(),
                        onChanged: (DateTime? newValue) {
                        },
                        // enabled: true,
                      ),
                      FormBuilderTextField(
                        name: 'monthly_rent',
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText:
                          'Monthly Rent',
                        ),
                        //onChanged: _onChanged,
                        // valueTransformer: (text) => num.tryParse(text),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context),
                        ]),
                        keyboardType: TextInputType.number,
                      ),
                      FormBuilderTextField(
                        name: 'owner_name',
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText:
                          'Owners Name',
                        ),
                        //onChanged: _onChanged,
                        // valueTransformer: (text) => num.tryParse(text),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context),
                        ]),
                      ),
                      FormBuilderTextField(
                        name: 'owner_add',
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText:
                          'Owners Address',
                        ),
                        //onChanged: _onChanged,
                        // valueTransformer: (text) => num.tryParse(text),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context),
                        ]),
                      ),
                      FormBuilderChoiceChip(
                        name: 'owner_relative',
                        decoration: InputDecoration(
                          labelText: 'Whether Owner is Relative',
                          //helperText: 'Certificate will be issued as per address maintained in SAP',
                        ),
                        options: [
                          FormBuilderFieldOption(
                              value: 'Yes', child: Text('Yes')),
                          FormBuilderFieldOption(
                              value: 'No', child: Text('No')),
                        ],
                        validator: FormBuilderValidators.compose(
                            [FormBuilderValidators.required(context)]),
                      ),
                      FormBuilderChoiceChip(
                        name: 'owner_dependent',
                        decoration: InputDecoration(
                          labelText: 'Whether Owner is dependent',
                          //helperText: 'Certificate will be issued as per address maintained in SAP',
                        ),
                        options: [
                          FormBuilderFieldOption(
                              value: 'Yes', child: Text('Yes')),
                          FormBuilderFieldOption(
                              value: 'No', child: Text('No')),
                        ],
                        validator: FormBuilderValidators.compose(
                            [FormBuilderValidators.required(context)]),
                      ),
                      FormBuilderChoiceChip(
                        name: 'ownership_proof',
                        decoration: InputDecoration(
                          labelText: 'Proof of Ownership',
                          //helperText: 'Certificate will be issued as per address maintained in SAP',
                        ),
                        options: [
                          FormBuilderFieldOption(
                              value: 'Sale Deed', child: Text('Sale Deed')),
                          FormBuilderFieldOption(
                              value: 'Property Tax Bill', child: Text('Property Tax Bill')),
                          FormBuilderFieldOption(
                              value: 'Water Tax Bill', child: Text('Water Tax Bill')),
                        ],
                        validator: FormBuilderValidators.compose(
                            [FormBuilderValidators.required(context)]),
                      ),
                      FormBuilderTextField(
                        name: 'sec_dep',
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText:
                          'Advance Rent / Non Adjustible Security Deposit',
                        ),
                        //onChanged: _onChanged,
                        // valueTransformer: (text) => num.tryParse(text),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context),
                        ]),
                        keyboardType: TextInputType.number,
                      ),
                      FormBuilderTextField(
                        name: 'brok_charge',
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText:
                          'Brokerage Charge',
                        ),
                        //onChanged: _onChanged,
                        // valueTransformer: (text) => num.tryParse(text),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context),
                        ]),
                        keyboardType: TextInputType.number,
                      ),
                      FormBuilderField(
                        name: "attach_files",
                        // validator: FormBuilderValidators.compose([
                        //   FormBuilderValidators.required(context),
                        // ]),
                        builder: (FormFieldState<dynamic> field) {
                          return InputDecorator(
                            decoration: InputDecoration(
                              labelText: "Attachment",
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
                                  _claFormKey.currentState!.save();
                                  var formDataMap = _claFormKey.currentState!.value;
                                  var formDataMapM = Map.of(formDataMap);

                                  if(_attachment != null){
                                    formDataMapM['file'] =  MultipartFile.fromFileSync(_attachment!.path, filename:_attachmentName);
                                  }
                                  if (_claFormKey.currentState!.validate()) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    _apiResponseData = _endpointProvider.postCLARequest(formDataMapM);

                                    _apiResponseData.then((result) {
                                      if(result.isAuthenticated && result.status){
                                        setState(() {
                                          isLoading = false;
                                        });
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Request successfully submitted")),
                                        );
                                      }
                                      else{
                                        setState(() {
                                          isLoading = false;
                                        });
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Error: ${result.error_details}")),
                                        );
                                      }
                                    }).catchError( (error) {
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
                                _claFormKey.currentState!.reset();
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
                                _claFormKey.currentState!.reset();
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
        ),
      ),
    );
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

class HRAApp extends StatefulWidget {
  @override
  State<HRAApp> createState() => HRAAppState();
}
class HRAAppState extends State<HRAApp>{
  late DioClient _dio;
  late var _endpointProvider;
  late Future<APIResponseData> _apiResponseData;
  bool isLoading = false;
  final _hraFormKey = GlobalKey<FormBuilderState>();

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
        body: isLoading ? waiting(context) : SingleChildScrollView(
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
                child: Text('Requset for HRA',style: TextStyle(
                  fontWeight: FontWeight.w500,fontSize: 18,),),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white30,
                ),
                padding: EdgeInsets.all(15),
                child: FormBuilder(
                  key: _hraFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      FormBuilderChoiceChip(
                        name: 'acc_type',
                        decoration: InputDecoration(
                          labelText: 'Accomodation Type',
                          //helperText: 'Certificate will be issued as per address maintained in SAP',
                        ),
                        options: [
                          FormBuilderFieldOption(
                              value: 'Own', child: Text('Own Accomodation')),
                          FormBuilderFieldOption(
                              value: 'Rent', child: Text('Rented Accomodation')),
                          FormBuilderFieldOption(
                              value: 'CLA', child: Text('Company Leased')),
                          FormBuilderFieldOption(
                              value: 'COA', child: Text('Company Owned')),
                        ],
                        validator: FormBuilderValidators.compose(
                            [FormBuilderValidators.required(context)]),
                      ),
                      FormBuilderTextField(
                        name: 'acc_addr',
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText:
                          'Accomodation Address',
                        ),
                        //onChanged: _onChanged,
                        // valueTransformer: (text) => num.tryParse(text),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context),
                        ]),
                      ),
                      FormBuilderChoiceChip(
                        name: 'govt_acc',
                        decoration: InputDecoration(
                          labelText: 'Whether accomodation is a Govt accommodation provided by any other CPSE/ Govt',
                          //helperText: 'Certificate will be issued as per address maintained in SAP',
                        ),
                        options: [
                          FormBuilderFieldOption(
                              value: 'Yes', child: Text('Yes')),
                          FormBuilderFieldOption(
                              value: 'No', child: Text('No')),
                        ],
                        validator: FormBuilderValidators.compose(
                            [FormBuilderValidators.required(context)]),
                      ),
                      FormBuilderChoiceChip(
                        name: 'spouse_hra',
                        decoration: InputDecoration(
                          labelText: 'Whether spouse is getting HRA for the same accomodation',
                          //helperText: 'Certificate will be issued as per address maintained in SAP',
                        ),
                        options: [
                          FormBuilderFieldOption(
                              value: 'Yes', child: Text('Yes')),
                          FormBuilderFieldOption(
                              value: 'No', child: Text('No')),
                        ],
                        validator: FormBuilderValidators.compose(
                            [FormBuilderValidators.required(context)]),
                      ),
                      FormBuilderDateTimePicker(
                        name: 'hra_date',
                        // onChanged: _onChanged,
                        inputType: InputType.date,
                        decoration: InputDecoration(
                          labelText: 'HRA Claim From',
                          //helperText: 'Date of Coff/Overtime',
                        ),
                        validator: FormBuilderValidators.compose(
                            [FormBuilderValidators.required(context)]),
                        //lastDate: lastDateforClaim,
                        firstDate: DateTime(2019,3,1),
                        //initialTime: TimeOfDay(hour: 8, minute: 0),
                        initialValue: DateTime.now(),
                        onChanged: (DateTime? newValue) {
                        },
                        // enabled: true,
                      ),
                      FormBuilderTextField(
                        name: 'reason',
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText:
                          'HRA Claim Reason',
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
                                  _hraFormKey.currentState!.save();
                                  var formDataMap = _hraFormKey.currentState!.value;

                                  if (_hraFormKey.currentState!.validate()) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    _apiResponseData = _endpointProvider.postHRARequest(formDataMap);

                                    _apiResponseData.then((result) {
                                      if(result.isAuthenticated && result.status){
                                        setState(() {
                                          isLoading = false;
                                        });
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Request successfully submitted")),
                                        );
                                      }
                                      else{
                                        setState(() {
                                          isLoading = false;
                                        });
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Error: ${result.error_details}")),
                                        );
                                      }
                                    }).catchError( (error) {
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
                                _hraFormKey.currentState!.reset();
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
                                _hraFormKey.currentState!.reset();
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
        ),
      ),
    );
  }
}

class QtrAlloc extends StatefulWidget {
  @override
  State<QtrAlloc> createState() => QtrAllocState();
}
class QtrAllocState extends State<QtrAlloc>{
  late DioClient _dio;
  late var _endpointProvider;
  late Future<APIResponseData> _apiResponseData;
  bool isLoading = false;
  final _qtrFormKey = GlobalKey<FormBuilderState>();

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
        body: isLoading ? waiting(context) : SingleChildScrollView(
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
                child: Text('Quarter Allotment Request',style: TextStyle(
                  fontWeight: FontWeight.w500,fontSize: 18,),),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white30,
                ),
                padding: EdgeInsets.all(15),
                child: FormBuilder(
                  key: _qtrFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      FormBuilderDateTimePicker(
                        name: 'join_date',
                        // onChanged: _onChanged,
                        inputType: InputType.date,
                        decoration: InputDecoration(
                          labelText: 'Date of Joining at Lepetkata / Lakwa',
                          //helperText: 'Date of Coff/Overtime',
                        ),
                        validator: FormBuilderValidators.compose(
                            [FormBuilderValidators.required(context)]),
                        //lastDate: lastDateforClaim,
                        firstDate: DateTime(2019,3,1),
                        //initialTime: TimeOfDay(hour: 8, minute: 0),
                        initialValue: DateTime.now(),
                        onChanged: (DateTime? newValue) {
                        },
                        // enabled: true,
                      ),
                      FormBuilderChoiceChip(
                        name: 'acc_type',
                        decoration: InputDecoration(
                          labelText: 'Particulars of Accomodation Already Occupied',
                          //helperText: 'Certificate will be issued as per address maintained in SAP',
                        ),
                        options: [
                          FormBuilderFieldOption(
                              value: 'Own', child: Text('Own Accomodation / HRA')),
                          FormBuilderFieldOption(
                              value: 'Rent', child: Text('Rented Accomodation')),
                          FormBuilderFieldOption(
                              value: 'CLA', child: Text('Company Leased')),
                          FormBuilderFieldOption(
                              value: 'COA', child: Text('Company Owned')),
                        ],
                        validator: FormBuilderValidators.compose(
                            [FormBuilderValidators.required(context)]),
                      ),
                      FormBuilderTextField(
                        name: 'qtr_pref',
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText:
                          'Preference of House',
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
                                  _qtrFormKey.currentState!.save();
                                  var formDataMap = _qtrFormKey.currentState!.value;

                                  if (_qtrFormKey.currentState!.validate()) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    _apiResponseData = _endpointProvider.postQtrAllocRequest(formDataMap);

                                    _apiResponseData.then((result) {
                                      if(result.isAuthenticated && result.status){
                                        setState(() {
                                          isLoading = false;
                                        });
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Request successfully submitted")),
                                        );
                                      }
                                      else{
                                        setState(() {
                                          isLoading = false;
                                        });
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Error: ${result.error_details}")),
                                        );
                                      }
                                    }).catchError( (error) {
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
                                _qtrFormKey.currentState!.reset();
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
                                _qtrFormKey.currentState!.reset();
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
        ),
      ),
    );
  }
}