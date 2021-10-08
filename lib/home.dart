
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_projects/people.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:mat_month_picker_dialog/mat_month_picker_dialog.dart';
import 'package:open_file/open_file.dart';
import 'AttendanceView.dart';
import 'Payslip.dart';
import 'ShiftRosterView.dart';
import 'documents.dart';
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
  late DioClient _dio;
  late var _endpointProvider;
  late Future<APIResponseData> _apiResponseData;

  late  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final _peopleFormKey = GlobalKey<FormState>();
  final _documentFormKey = GlobalKey<FormState>();
  final _paySlipFormKey = GlobalKey<FormState>();
  final _attendanceFormKey = GlobalKey<FormState>();
  final _shiftRosterFormKey = GlobalKey<FormState>();
  final _claimsFormKey = GlobalKey<FormState>();

  final empNameContrl = TextEditingController();
  String _empUnit = '';
  String _empDisc = '';
  String _empBldGrp = '';

  final docNameContrl = TextEditingController();
  String _documentCategory = '';

  final monthContrl = TextEditingController();
  final yearContrl = TextEditingController();
  late DateTime payslipSelectedDate;

  final attendanceFromDateContrl = TextEditingController();
  final attendanceToDateContrl = TextEditingController();
  DateTime attendanceSelectedFromDate = DateTime.now();
  DateTime attendanceSelectedToDate = DateTime.now();

  final shiftFromDateContrl = TextEditingController();
  final shiftToDateContrl = TextEditingController();
  DateTime shiftSelectedFromDate = DateTime.now();
  DateTime shiftSelectedToDate = DateTime.now();

  final claimsFromDateContrl = TextEditingController();
  final claimsToDateContrl = TextEditingController();
  DateTime claimsSelectedFromDate = DateTime.now();
  DateTime claimsSelectedToDate = DateTime.now();

  bool isLoading = false;

  late List<Employee> peopleData;
  late List<Document> documentList;
  late List<ClaimData> claimsData;
  late List<PayrollData> payrollData;
  late List<AttendanceData> attendanceData;
  late List<ShiftRoster> shiftRosterData;

  String _claimsType = '';
  ClaimType? _claimsTypeObj;
  static String claimTypeData = '''
  [
    {"claimType":"Z6C1", "claimDesc":"(6.10.C.i) Light Refreshment"},
    {"claimType":"Z6C2", "claimDesc":"(6.10.C.ii) Working Meal"},
    {"claimType":"Z6C3", "claimDesc":"(6.10.C.iii) Entertainment & Others"},
    {"claimType":"ZBAG", "claimDesc":"Briefcase/Handbag Reimbursement"},
    {"claimType":"COFF", "claimDesc":"Coff Encashment"},
    {"claimType":"LEEN", "claimDesc":"Leave Encashment"},
    {"claimType":"ZHO1", "claimDesc":"Medical Reimbursement"},
    {"claimType":"ZMOI", "claimDesc":"Mobile Handset Reimbursement"},
    {"claimType":"ZOPE", "claimDesc":"Out of Pocket Expense"},
    {"claimType":"ZOTM", "claimDesc":"Overtime Allowance"},
    {"claimType":"ZSPE", "claimDesc":"Spectacle Reimbursement"},
    {"claimType":"ZMOB", "claimDesc":"Tel/Cell Call Charges Reimbursement"}
    ]
  ''';

  List<ClaimType> claimTypes = List<ClaimType>.from(json.decode(claimTypeData).map((x) => ClaimType.fromJson(x)));

  @override
  void initState(){
    _dio = new DioClient();
    _endpointProvider = new EndPointProvider(_dio.init());
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
            if(title == "People"){
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
                                  child: isLoading ? waiting() :

                                  Form(
                                    key: _peopleFormKey,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,

                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.only(top:10,bottom:10),
                                          child: Center(child: Text('Find Employees',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 20,
                                                color: Colors.blue[500],
                                              ))) ,
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(top:10,bottom:10),
                                          child: TextFormField(
                                            controller: empNameContrl,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: 'Employee Name (Optional)',
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(top:10,bottom:10),
                                          child: InputDecorator(
                                            decoration: InputDecoration(
                                              labelText: 'Unit (Optional)',
                                              contentPadding: const EdgeInsets.only(left: 10.0),
                                              border: const OutlineInputBorder(),
                                              isDense: true,
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(

                                                isExpanded: true,
                                                icon: Icon(Icons.keyboard_arrow_down),
                                                value: _empUnit,
                                                style: TextStyle(color: Colors.black),
                                                items: <String>[
                                                  '',
                                                  'Civil',
                                                  'C&P',
                                                  'Company Secretary',
                                                  'IT',
                                                  'Law',
                                                  'Marketing',
                                                  'Security',
                                                ].map<DropdownMenuItem<String>>((String value) {
                                                  return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList(),

                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    _empUnit = newValue!;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(top:10,bottom:10),
                                          child: InputDecorator(
                                            decoration: InputDecoration(
                                              labelText: 'Discipline (Optional)',
                                              contentPadding: const EdgeInsets.only(left: 10.0),
                                              border: const OutlineInputBorder(),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value: _empDisc,
                                                style: TextStyle(color: Colors.black),
                                                items: <String>[
                                                  '',
                                                  'Civil',
                                                  'C&P',
                                                  'Company Secretary',
                                                  'IT',
                                                  'Law',
                                                  'Marketing',
                                                  'Security',
                                                ].map<DropdownMenuItem<String>>((String value) {
                                                  return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList(),
                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    _empDisc = newValue!;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),

                                        ),
                                        Container(
                                          padding: EdgeInsets.only(top:10,bottom:10),
                                          child: InputDecorator(
                                            decoration: InputDecoration(
                                              labelText: 'Blood Group (Optional)',
                                              //labelStyle: Theme.of(context).primaryTextTheme.caption!.copyWith(color: Colors.black),
                                              contentPadding: const EdgeInsets.only(left: 10.0),
                                              border: const OutlineInputBorder(),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value: _empBldGrp,
                                                style: TextStyle(color: Colors.black),
                                                items: <String>[
                                                  '',
                                                  'A-',
                                                  'A+',
                                                  'AB-',
                                                  'AB+',
                                                  'B-',
                                                  'B+',
                                                  'O-',
                                                  'O+',
                                                ].map<DropdownMenuItem<String>>((String value) {
                                                  return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList(),
                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    _empBldGrp = newValue!;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),

                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    isLoading = true;
                                                  });

                                                  _apiResponseData = _endpointProvider.fetchEmployees(empNameContrl.text,_empUnit,_empDisc,_empBldGrp);
                                                  _apiResponseData.then((result) {
                                                    if(result.isAuthenticated && result.status){
                                                      final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
                                                      setState(() {
                                                        empNameContrl.text = '';
                                                        _empUnit = '';
                                                        _empDisc = '';
                                                        _empBldGrp = '';
                                                        peopleData =  parsed.map<Employee>((json) => Employee.fromJson(json)).toList();
                                                        isLoading = false;
                                                        Navigator.pop(context);
                                                        Navigator.pushNamed(context, peopleRoute, arguments: peopleData,);
                                                      });
                                                    }
                                                    else{
                                                      setState(() {
                                                        empNameContrl.text = '';
                                                        _empUnit = '';
                                                        _empDisc = '';
                                                        _empBldGrp = '';
                                                        isLoading = false;
                                                      });
                                                      Navigator.pop(context);
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text("Error in data fetching")),
                                                      );
                                                    }
                                                  });
                                                },
                                                child: const Text('Submit'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    empNameContrl.text = '';
                                                    _empUnit = '';
                                                    _empDisc = '';
                                                    _empBldGrp = '';
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
                                );
                              },
                            ),
                          );
                      },
                    );
                  },
              );
            }
            else if(title == "Documents"){
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
                              height: height - (height/1.8),
                              width: width - (width/4),
                              child: isLoading ? waiting() : Form(
                                key: _documentFormKey,
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 20),
                                  child:Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.only(top:10,bottom:10),
                                        child: Center(child: Text('Search for Documents',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 20,
                                              color: Colors.blue[500],
                                            ))) ,
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(top:10,bottom:10),
                                        child: TextFormField(
                                          controller: docNameContrl,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'Document Name (Optional)',
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(top:10,bottom:10),
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            labelText: 'Document Category (Optional)',
                                            contentPadding: const EdgeInsets.only(left: 10.0),
                                            border: const OutlineInputBorder(),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: _documentCategory,
                                              style: TextStyle(color: Colors.black),
                                              items: <String>[
                                                '',
                                                'A-',
                                              ].map<DropdownMenuItem<String>>((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  _documentCategory = newValue!;
                                                });
                                              },
                                            ),
                                          ),
                                        ),

                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  isLoading = true;
                                                });

                                                _apiResponseData = _endpointProvider.fetchDocuments(docNameContrl.text,_documentCategory);
                                                _apiResponseData.then((result) {
                                                  if(result.isAuthenticated && result.status){
                                                    final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
                                                    setState(() {
                                                      docNameContrl.text = '';
                                                      _documentCategory = '';
                                                      documentList =  parsed.map<Document>((json) => Document.fromJson(json)).toList();
                                                      isLoading = false;
                                                      Navigator.pop(context);
                                                      Navigator.pushNamed(context, documentsRoute, arguments: documentList,);
                                                    });
                                                  }
                                                  else{
                                                    setState(() {
                                                      docNameContrl.text = '';
                                                      _documentCategory = '';
                                                      isLoading = false;
                                                    });
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text("Error in data fetching")),
                                                    );
                                                  }
                                                });
                                              },
                                              child: const Text('Submit'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  docNameContrl.text = '';
                                                  _documentCategory = '';
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
            else if(title == "Payslips"){
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
                              child: isLoading ? waiting() : Form(
                                key: _paySlipFormKey,
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 20),
                                  child:Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,

                                    children: <Widget>[
                                      Container(

                                        padding: EdgeInsets.all(10),
                                        child: Center(child: Text('View Payslip',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 20,
                                              color: Colors.blue[500],
                                            ))) ,
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        child: TextFormField(
                                          controller: monthContrl,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'Payroll Period',
                                          ),
                                          onTap: (){
                                            // Below line stops keyboard from appearing
                                            FocusScope.of(context).requestFocus(new FocusNode());
                                            _selectMonth(context,monthContrl);
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
                                                if (_paySlipFormKey.currentState!.validate()) {

                                                  setState(() {
                                                    isLoading = true;
                                                  });

                                                  _apiResponseData = _endpointProvider.fetchPayrollData("1219",DateFormat('MM').format(payslipSelectedDate),DateFormat('yyyy').format(payslipSelectedDate));
                                                  _apiResponseData.then((result) {
                                                    if(result.isAuthenticated && result.status){
                                                      final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
                                                      setState(() {
                                                        monthContrl.text = '';
                                                        payrollData =  parsed.map<PayrollData>((json) => PayrollData.fromJson(json)).toList();
                                                        isLoading = false;
                                                        Navigator.pop(context);
                                                        Navigator.pushNamed(context, payslipRoute, arguments: payrollData,);
                                                      });
                                                    }
                                                    else{
                                                      setState(() {
                                                        monthContrl.text = '';
                                                        isLoading = false;
                                                      });
                                                      Navigator.pop(context);
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text("Error in data fetching")),
                                                      );
                                                    }
                                                  });
                                                }
                                              },
                                              child: const Text('Show my payslip'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  monthContrl.text = '';
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
            else if(title == "Attendance"){
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
                              child: isLoading ? waiting() : Form(
                                key: _attendanceFormKey,
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 20),
                                  child:Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,

                                    children: <Widget>[
                                      Container(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Center(child: Text('View Biometric Attendance Data',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 20,
                                              color: Colors.blue[500],
                                            ))) ,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(10.0),
                                        child: TextFormField(
                                          controller: attendanceFromDateContrl,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'From Date',
                                          ),
                                          onTap: (){
                                            // Below line stops keyboard from appearing
                                            FocusScope.of(context).requestFocus(new FocusNode());
                                            _selectDate(context,attendanceSelectedFromDate,attendanceFromDateContrl);
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
                                        padding: const EdgeInsets.all(10.0),
                                        child: TextFormField(
                                          controller: attendanceToDateContrl,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'To Date',
                                          ),
                                          onTap: (){
                                            // Below line stops keyboard from appearing
                                            FocusScope.of(context).requestFocus(new FocusNode());
                                            _selectDate(context,attendanceSelectedToDate,attendanceToDateContrl);
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
                                                if (_attendanceFormKey.currentState!.validate()) {
                                                  setState(() {
                                                    isLoading = true;
                                                  });

                                                  _apiResponseData = _endpointProvider.fetchAttendanceData(empno,attendanceFromDateContrl.text,attendanceToDateContrl.text);
                                                  _apiResponseData.then((result) {
                                                    if(result.isAuthenticated && result.status){
                                                      final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
                                                      setState(() {
                                                        attendanceFromDateContrl.text = '';
                                                        attendanceToDateContrl.text = '';
                                                        attendanceData =  parsed.map<AttendanceData>((json) => AttendanceData.fromJson(json)).toList();
                                                        isLoading = false;
                                                        Navigator.pop(context);
                                                        Navigator.pushNamed(context, attendanceRoute, arguments: attendanceData,);
                                                      });
                                                    }
                                                    else{
                                                      setState(() {
                                                        attendanceFromDateContrl.text = '';
                                                        attendanceToDateContrl.text = '';
                                                        isLoading = false;
                                                      });
                                                      Navigator.pop(context);
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text("Error in data fetching")),
                                                      );
                                                    }
                                                  });
                                                }
                                              },
                                              child: const Text('Show biometric data'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  attendanceFromDateContrl.text = '';
                                                  attendanceToDateContrl.text = '';
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
            else if(title == "Shift Roster"){
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
                              child: isLoading ? waiting() : Form(
                                key: _shiftRosterFormKey,
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 20),
                                  child:Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,

                                    children: <Widget>[
                                      Container(

                                        padding: EdgeInsets.all(10),
                                        child: Center(child: Text('View Shift Roster',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 20,
                                              color: Colors.blue[500],
                                            ))) ,
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

                                                  _apiResponseData = _endpointProvider.fetchShiftRosterData(empno,shiftFromDateContrl.text,shiftToDateContrl.text);
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
                                                        SnackBar(content: Text("Error in data fetching")),
                                                      );
                                                    }
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
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              );
            }
            else if(title == "Claims"){
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
                              child: isLoading ? waiting() : Form(
                                key: _claimsFormKey,
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 20),
                                  child:Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,

                                    children: <Widget>[
                                      Container(

                                        padding: EdgeInsets.all(10),
                                        child: Center(child: Text('View Claims',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 20,
                                              color: Colors.blue[500],
                                            ))) ,
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(top:10,bottom:10),
                                        child: TextFormField(
                                          controller: claimsFromDateContrl,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'From Date',
                                          ),
                                          onTap: (){
                                            // Below line stops keyboard from appearing
                                            FocusScope.of(context).requestFocus(new FocusNode());
                                            _selectDate(context,claimsSelectedFromDate,claimsFromDateContrl);
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
                                        padding: EdgeInsets.only(top:10,bottom:10),
                                        child: TextFormField(
                                          controller: claimsToDateContrl,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'To Date',
                                          ),
                                          onTap: (){
                                            // Below line stops keyboard from appearing
                                            FocusScope.of(context).requestFocus(new FocusNode());
                                            _selectDate(context,claimsSelectedToDate,claimsToDateContrl);
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
                                        padding: EdgeInsets.only(top:10,bottom:10),
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                             labelText: 'Claim Type',
                                             contentPadding: const EdgeInsets.only(left: 10.0),
                                            border: const OutlineInputBorder(),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButtonFormField<ClaimType>(
                                              value: _claimsTypeObj,
                                              //hint: Text('Mandatory'),
                                              style: TextStyle(color: Colors.black),
                                              items: claimTypes.map<DropdownMenuItem<ClaimType>>((ClaimType value) {
                                                return DropdownMenuItem<ClaimType>(
                                                  value: value,
                                                  child: Text(value.claimDesc),
                                                );
                                              }).toList(),
                                              onChanged: (ClaimType? newValue) {
                                                setState(() {
                                                  _claimsTypeObj = newValue!;
                                                  _claimsType = newValue.claimType;
                                                });
                                              },
                                               validator: (value) {
                                                 if (value == null) {
                                                   return 'Please select claim type';
                                                 }
                                                 return null;
                                               },
                                            ),
                                          ),
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
                                                if (_claimsFormKey.currentState!.validate()) {
                                                  setState(() {
                                                    isLoading = true;
                                                  });

                                                  _apiResponseData = _endpointProvider.fetchClaimsData(empno,_claimsType,claimsFromDateContrl.text,claimsToDateContrl.text);
                                                  _apiResponseData.then((result) {
                                                    if(result.isAuthenticated && result.status){
                                                      final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
                                                      setState(() {
                                                        claimsFromDateContrl.text = '';
                                                        claimsToDateContrl.text = '';
                                                        _claimsType = '';
                                                        _claimsTypeObj = null;
                                                        claimsData =  parsed.map<ClaimData>((json) => ClaimData.fromJson(json)).toList();
                                                        isLoading = false;
                                                        Navigator.pop(context);
                                                        Navigator.pushNamed(context, claimsRoute, arguments: claimsData,);
                                                      });
                                                    }
                                                    else{
                                                      setState(() {
                                                        claimsFromDateContrl.text = '';
                                                        claimsToDateContrl.text = '';
                                                        _claimsTypeObj = null;
                                                        _claimsType = '';
                                                        isLoading = false;
                                                      });
                                                      Navigator.pop(context);
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text("Error in data fetching")),
                                                      );
                                                    }
                                                  });
                                                }
                                              },
                                              child: const Text('Show my claims'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  claimsFromDateContrl.text = '';
                                                  claimsToDateContrl.text = '';
                                                  _claimsType = '';
                                                  _claimsTypeObj = null;
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
              //Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => News()));
              Navigator.pushNamed(context, routeName);
            }

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

  Future<Null> _selectMonth(BuildContext context, var textController) async {
    final selected = await showMonthPicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2018),
        lastDate: DateTime.now()
    );
    if (selected != null)
      setState(() {
        payslipSelectedDate = selected;
        textController.text = DateFormat('MMM-yyyy').format(payslipSelectedDate);
      });
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

  Widget waiting(){
    return Container(
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
    );
  }
}

class ScreenArguments {
  final String fromDate;
  final String toDate;
  final String claimType;

  ScreenArguments(this.fromDate, this.toDate, this.claimType);
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
class ClaimType {
  String claimType;
  String claimDesc;

  ClaimType( {required this.claimType,required this.claimDesc});

   factory ClaimType.fromJson(Map<String, dynamic> json) {
     return ClaimType(
       claimType: json['claimType'],
       claimDesc: json['claimDesc'],
     );
   }
}








