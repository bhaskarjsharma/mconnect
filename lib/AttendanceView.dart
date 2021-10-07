
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_projects/services/webservice.dart';
import 'constants.dart';
import 'home.dart';
import 'main.dart';
import 'models/models.dart';

class AttendanceView extends StatefulWidget {
  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}
class _AttendanceViewState extends State<AttendanceView>{

  final _formKey = GlobalKey<FormState>();
  final fromDateContrl = TextEditingController();
  final toDateContrl = TextEditingController();
  DateTime selectedFromDate = DateTime.now();
  DateTime selectedToDate = DateTime.now();

  @override
  initState() {
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
        title: Text('Connect - People'),
      ),
      endDrawer: AppDrawer(),
      body: ShiftRosterForm(),
    );
  }

  Form ShiftRosterForm(){
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
              child: Center(child: Text('View Biometric Attendance Data',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: Colors.blue[500],
                  ))) ,
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: TextFormField(
                controller: fromDateContrl,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'From Date',
                ),
                onTap: (){
                  // Below line stops keyboard from appearing
                  FocusScope.of(context).requestFocus(new FocusNode());
                  _selectFromDate(context);
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
                controller: toDateContrl,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'To Date',
                ),
                onTap: (){
                  // Below line stops keyboard from appearing
                  FocusScope.of(context).requestFocus(new FocusNode());
                  _selectToDate(context);
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
              child: Center( child: ElevatedButton(
                onPressed: () {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    Navigator.pushNamed(context, attendanceListRoute, arguments: AttendanceScreenArguments(
                        fromDateContrl.text,toDateContrl.text),
                    );
                  }
                },
                child: const Text('Fetch Data'),
              ),
              ),
            ),
          ],
        ),
      ),

    );
  }

  Future<Null> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedFromDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2018),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedFromDate)
      setState(() {
        fromDateContrl.text = "${picked.toLocal()}".split(' ')[0];
      });
  }
  Future<Null> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedToDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2018),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedToDate)
      setState(() {
        toDateContrl.text = "${picked.toLocal()}".split(' ')[0];
      });
  }

}
class attendanceList extends StatefulWidget {

  final String fromDate;
  final String toDate;

  attendanceList(this.fromDate, this.toDate);

  @override
  State<attendanceList> createState() => _attendanceListState();
}
class _attendanceListState extends State<attendanceList>{

  late List<AttendanceData> _attendanceData;
  late Future<APIResponseData> _apiResponseData;
  bool isLoading = true;

  @override
  void initState() {
    DioClient _dio = new DioClient();
    var _endpointProvider = new EndPointProvider(_dio.init());
    _apiResponseData = _endpointProvider.fetchAttendanceData(empno,widget.fromDate,widget.toDate);
    _apiResponseData.then((result) {
      if(result.isAuthenticated && result.status){
        final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
        setState(() {
          _attendanceData =  parsed.map<AttendanceData>((json) => AttendanceData.fromJson(json)).toList();
          isLoading = false;
        });
      }
    });
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
        title: Text('Connect - People'),
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

      ) : getAttendanceList()

    );
  }

  Column getAttendanceList(){
    return Column(
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
          child: createListAttendance(_attendanceData),
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
class AttendanceScreenArguments {
  final String fromDate;
  final String toDate;

  AttendanceScreenArguments(this.fromDate, this.toDate);
}