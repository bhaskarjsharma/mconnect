
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/services/webservice.dart';
import 'package:intl/intl.dart';
import 'package:mat_month_picker_dialog/mat_month_picker_dialog.dart';
import 'constants.dart';
import 'home.dart';
import 'main.dart';
import 'models/models.dart';

class Payslip extends StatefulWidget {
  @override
  State<Payslip> createState() => _PayslipState();
}
class _PayslipState extends State<Payslip>{

  final _formKey = GlobalKey<FormState>();
  final monthContrl = TextEditingController();
  final yearContrl = TextEditingController();
  DateTime selectedDate = DateTime.now();
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
      body: payslipForm(),
    );
  }

  Form payslipForm(){
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
                  _selectFromDate(context);
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
                    Navigator.pushNamed(context, payslipDataRoute, arguments: PayslipScreenArguments(
                        DateFormat('MM').format(selectedDate),DateFormat('yyyy').format(selectedDate)),
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
    final selected = await showMonthPicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015),
        lastDate: DateTime.now()
    );
     if (selected != null)
       setState(() {
         selectedDate = selected;
         monthContrl.text = DateFormat('MMM-yyyy').format(selected);
    });
  }
}
class PayslipData extends StatefulWidget {

  final String month;
  final String year;

  PayslipData(this.month, this.year);

  @override
  State<PayslipData> createState() => _PayslipDataState();
}
class _PayslipDataState extends State<PayslipData> with SingleTickerProviderStateMixin{

  late Future<List<PayrollData>> _payrollData;
  String _empno = '';
  TabController? _tabController;

  final List<Tab> myTabs = <Tab>[
    Tab(text: 'Earnings'),
    Tab(text: 'Deductions'),
    Tab(text: 'Net Summary'),
  ];

  @override
  void initState(){
    _tabController = TabController(vsync: this, length: myTabs.length);
    _empno = prefs.getString('empno') ?? '';
    _payrollData = fetchPayrollData(_empno,widget.month,widget.year);
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
        title: Text('Connect - Payslip'),
        bottom:TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),
      ),
      endDrawer: AppDrawer(),
      body: getPayrollData(),
    );
  }

  FutureBuilder getPayrollData(){
    return FutureBuilder<List<PayrollData>>(
      future: _payrollData,
      builder: (BuildContext context, snapshot){
        if (snapshot.hasData) {
          List<PayrollData>? data = snapshot.data;
          List<PayrollData>? earnings = data!.where((element) =>
          element.WageTypeType == "ADDN").toList();

          List<PayrollData>? deduction = data!.where((element) =>
          element.WageTypeType == "DEDN").toList();

          List<PayrollData>? netPay = data!.where((element) =>
          element.WageTypeType == "OTHR").toList();

          return TabBarView(
              controller: _tabController,
              children: [
                createTabData(earnings),
                createTabData(deduction),
                createTabData(netPay),
              ]
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
  ListView createTabData(data) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Card(

            child: ListTile(
              title: Text(data[index].WageTypeText,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                ),),
              trailing: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  border: Border.all(
                    color: Colors.black12,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(data[index].WageTypeAmount,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),),
              ),
            ),
          );
        }
    );
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }
}
class PayslipScreenArguments {
  final String month;
  final String year;

  PayslipScreenArguments(this.month, this.year);
}
