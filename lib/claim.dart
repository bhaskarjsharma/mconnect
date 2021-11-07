
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';

import 'app_drawer.dart';
import 'home.dart';
import 'main.dart';
import 'models/models.dart';

class Claims extends StatefulWidget {

  @override
  State<Claims> createState() => _ClaimsState();
}
class _ClaimsState extends State<Claims>{
  List<ClaimData> _claims = [];
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    _claims = ModalRoute.of(context)!.settings.arguments as List<ClaimData>;
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
          title: Text('Connect - Claims',style: TextStyle(
            color:appBarTextColor,
          ),),
        ),
        endDrawer: AppDrawer(),
        body:createTable(),
      ),
    );
  }

  Container createTable(){
    return Container(

      child: HorizontalDataTable(
        leftHandSideColumnWidth: 100,
        rightHandSideColumnWidth: 1200,
        isFixedHeader: true,
        headerWidgets: _getTitleWidget(),
        leftSideItemBuilder: _generateFirstColumnRow,
        rightSideItemBuilder: _generateRightHandSideColumnRow,
        itemCount: _claims.length,
        rowSeparatorWidget: const Divider(
          color: Colors.black54,
          height: 1.0,
          thickness: 0.0,
        ),
        leftHandSideColBackgroundColor: Color(0xFFFFFFFF),
        rightHandSideColBackgroundColor: Color(0xFFFFFFFF),
        verticalScrollbarStyle: const ScrollbarStyle(
          isAlwaysShown: true,
          thickness: 4.0,
          radius: Radius.circular(5.0),
        ),
        horizontalScrollbarStyle: const ScrollbarStyle(
          isAlwaysShown: true,
          thickness: 4.0,
          radius: Radius.circular(5.0),
        ),
      ),
      height: MediaQuery.of(context).size.height,
    );
  }

  List<Widget> _getTitleWidget() {
    return [
      _getTitleItemWidget('Creation Date', 100),
      _getTitleItemWidget('Submit Date', 100),
      _getTitleItemWidget('Period/Block', 100),
      _getTitleItemWidget('Reference No', 150),
      _getTitleItemWidget('Status', 200),
      _getTitleItemWidget('Requested Amount', 100),
      _getTitleItemWidget('Approved Amount', 100),
      _getTitleItemWidget('Processing Date', 100),
      _getTitleItemWidget('Payment Date', 100),
      _getTitleItemWidget('Remarks', 200),
    ];
  }
  Widget _getTitleItemWidget(String label, double width) {
    return Container(
      child: Text(label, style: TextStyle(fontWeight: FontWeight.bold,color:textColor)),
      width: width,
      height: 56,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              //colors: [Color.fromRGBO(255, 239, 186, 1), Color.fromRGBO(255, 255, 255, 1)]
              colors: [startColor, endColor]
          )
      ),
    );
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    return Container(
      child: Text(_claims[index].CreationDt,style: TextStyle(color:textColor)),
      width: 100,
      height: 52,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              //colors: [Color.fromRGBO(255, 239, 186, 1), Color.fromRGBO(255, 255, 255, 1)]
              colors: [startColor, endColor]
          )
      ),
    );
  }
  Widget _generateRightHandSideColumnRow(BuildContext context,int index) {
    return Row(
      children: <Widget>[
        createCell(_claims[index].SubmitDt ?? '',100),
        createCell(_claims[index].Period ?? '',100),
        createCell(_claims[index].DocNo ?? '',150),
        createCell(_claims[index].ClaimStatus ?? '',200),
        createCell(_claims[index].ClaimAmt ?? '',100),
        createCell(_claims[index].AprrovedAmt ?? '',100),
        createCell(_claims[index].ProcessDt ?? '',100),
        createCell(_claims[index].PaymentDate ?? '',100),
        createCell(_claims[index].Remarks ?? '',200),
      ],
    );
  }
  Container createCell(String text, double? width){
    return Container(
      child: Text(text,style: TextStyle(color:textColor)),
      width: width,
      height: 52,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              //colors: [Color.fromRGBO(255, 239, 186, 1), Color.fromRGBO(255, 255, 255, 1)]
              colors: [startColor, endColor]
          )
      ),
    );
  }


  ListView createListClaims(data){
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Card(
              child: Row(
                children: [
                  makeColumnData(data[index].CreationDt ?? ''),
                  makeColumnData(data[index].SubmitDt ?? ''),
                  makeColumnData(data[index].Period ?? ''),
                  makeColumnData(data[index].DocNo ?? ''),
                  makeColumnData(data[index].ClaimStatus ?? ''),
                  makeColumnData(data[index].ClaimAmt ?? ''),
                  makeColumnData(data[index].AprrovedAmt ?? ''),
                  makeColumnData(data[index].ProcessDt ?? ''),
                  makeColumnData(data[index].PaymentDate ?? ''),
                  makeColumnData(data[index].Remarks ?? ''),
                ],
              ),
            ),

          );
        }
    );
  }

  Widget makeColumnData(String title){
    return Center(
      child: Container(
        padding: EdgeInsets.all(15),
        child: Text(title,style: TextStyle(
          fontWeight: FontWeight.w400,fontSize: 16,),),
      ),
    );
  }

}