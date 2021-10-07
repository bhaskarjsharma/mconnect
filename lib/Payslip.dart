
import 'dart:convert';

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
class _PayslipState extends State<Payslip> with SingleTickerProviderStateMixin{
  TabController? _tabController;

  final List<Tab> myTabs = <Tab>[
    Tab(text: 'Earnings'),
    Tab(text: 'Deductions'),
    Tab(text: 'Net Summary'),
  ];

  @override
  void initState(){
    _tabController = TabController(vsync: this, length: myTabs.length);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<PayrollData> payrollData = ModalRoute.of(context)!.settings.arguments as List<PayrollData>;
    final List<PayrollData> _earnings = payrollData.where((element) => element.WageTypeType == "ADDN").toList();
    final List<PayrollData> _deduction = payrollData.where((element) => element.WageTypeType == "DEDN").toList();
    final List<PayrollData> _netPay = payrollData.where((element) => element.WageTypeType == "OTHR").toList();
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          width: 40,
          child: Image.asset('images/bcpl_logo.png'),
        ),
        title: Text('Connect - People'),
        bottom:TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),
      ),
      endDrawer: AppDrawer(),

      body: TabBarView(
          controller: _tabController,
          children: [
            createTabData(_earnings),
            createTabData(_deduction),
            createTabData(_netPay),
          ]
      ),
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
