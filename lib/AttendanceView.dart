
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  late Future<List<AttendanceData>> _attendanceData;
  String _empno = '';
  bool _loadImageError = false;
  @override
  void initState() {
    super.initState();
    _empno = prefs.getString('empno') ?? '';
    _attendanceData = fetchAttendanceData(_empno,widget.fromDate,widget.toDate);
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
      body: getAttendanceData(),
    );
  }

  FutureBuilder getAttendanceData(){
    return FutureBuilder<List<AttendanceData>>(
      future: _attendanceData,
      builder: (BuildContext context, AsyncSnapshot<List<AttendanceData>> snapshot){
        if (snapshot.hasData) {
          List<AttendanceData>? data = snapshot.data;
          return createListAttendance(data);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return SizedBox(
          height: MediaQuery.of(context).size.height / 1.3,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                Container(
                  padding: EdgeInsets.all(10),
                  child:Text('Fetching Data. Please Wait...',style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),),
                ),
              ],
            ),

          ),
        );
      },
    );
  }

  SingleChildScrollView createListAttendance(data){
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: FittedBox(
          child: DataTable(
            columns: <DataColumn>[
              DataColumn(
                label: Text(
                  'Date',
                  style: TextStyle(fontStyle: FontStyle.normal,fontSize: 20,),
                ),
              ),
              DataColumn(
                label: Text(
                  'Punch Date',
                  style: TextStyle(fontStyle: FontStyle.normal,fontSize: 20,),
                ),
              ),
              DataColumn(
                label: Text(
                  'Punch Time',
                  style: TextStyle(fontStyle: FontStyle.normal,fontSize: 20,),
                ),
              ),
              DataColumn(
                label: Text(
                  'Device',
                  style: TextStyle(fontStyle: FontStyle.normal,fontSize: 20,),
                ),
              ),
            ],
            rows: List<DataRow>.generate(
              data.length,
                  (int index) => DataRow(
                color: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                      // All rows will have the same selected color.
                      if (states.contains(MaterialState.selected)) {
                        return Theme.of(context).colorScheme.primary.withOpacity(0.08);
                      }
                      // Even rows will have a grey color.
                      if (index.isEven) {
                        return Colors.grey.withOpacity(0.3);
                      }
                      return null; // Use default value for other states and odd rows.
                    }),
                cells: <DataCell>[
                  DataCell(Text(data[index].date ?? '')),
                  DataCell(Text(data[index].punchDate ?? '')),
                  DataCell(Text(data[index].punchTime ?? '')),
                  DataCell(Text(data[index].deviceName ?? '')),
                ],
              ),
            ),
          ),
      ),
    );
  }
  ListView createListAttendance1(data) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Card(
            child: DataTable(
              columns: const <DataColumn>[
                DataColumn(
                  label: Text(
                    'Date',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Punch Date',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Punch Time',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Device',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ],
              rows: <DataRow>[
                DataRow(
                  cells: <DataCell>[
                    DataCell(Text(data[index].date ?? '')),
                    DataCell(Text(data[index].punchDate ?? '')),
                    DataCell(Text(data[index].punchTime ?? '')),
                    DataCell(Text(data[index].deviceName ?? '')),
                  ],
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