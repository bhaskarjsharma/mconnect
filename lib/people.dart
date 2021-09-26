import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/services/webservice.dart';

import 'account.dart';
import 'constants.dart';
import 'home.dart';
import 'main.dart';
import 'models/models.dart';

class People extends StatefulWidget {
  @override
  State<People> createState() => _PeopleState();
}
class _PeopleState extends State<People>{

  final _formKey = GlobalKey<FormState>();
  final empNameContrl = TextEditingController();
  final empUnitControl = TextEditingController();
  final empDiscControl = TextEditingController();
  final empBloodGrpControl = TextEditingController();

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
      body: PeopleFinderForm(),
    );
  }

  Form PeopleFinderForm(){
    return Form(
      key: _formKey,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        child:Column(

          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(

              padding: EdgeInsets.all(10),
              child: Center(child: Text('Find Employees',
                  style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: Colors.blue[500],
              ))) ,
            ),
            Container(

              padding: EdgeInsets.all(10),
              child: TextFormField(
                controller: empNameContrl,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Employee Name',
                ),
                // The validator receives the text that the user has entered.
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Please enter some text';
                //   }
                //   return null;
                // },
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child:TextFormField(
                controller: empUnitControl,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Employee Unit',
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: TextFormField(
                controller: empDiscControl,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Employee Discipline',
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: TextFormField(
                controller: empBloodGrpControl,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Employee Blood Group',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10.0),
              child: Center( child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, peopleListRoute, arguments: PeolpeScreenArguments(
                      '',empNameContrl.text,empUnitControl.text,empDiscControl.text,empBloodGrpControl.text,
                    '','','','',''
                  ),);
                  //Navigator.pushNamed(context, peopleRoute, arguments: 'Data from home');
                  // Validate returns true if the form is valid, or false otherwise.
                  // if (_formKey.currentState!.validate()) {
                  //   // If the form is valid, display a snackbar. In the real world,
                  //   // you'd often call a server or save the information in a database.
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     const SnackBar(content: Text('Fetching Data')),
                  //   );
                  // }
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
class PeopleList extends StatefulWidget {

  final String empName;
  final String empUnit;
  final String empDisc;
  final String empBldGrp;

  PeopleList(this.empName, this.empUnit, this.empDisc, this.empBldGrp);

  @override
  State<PeopleList> createState() => _PeopleListState();
}
class _PeopleListState extends State<PeopleList>{

  late Future<List<Employee>> _peopleData;
  bool _loadImageError = false;
  @override
  void initState() {
    super.initState();
    _peopleData = fetchEmployees(widget.empName,widget.empUnit,widget.empDisc,widget.empBldGrp);
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
      body: getPeople(),
    );
  }

  FutureBuilder getPeople(){
    return FutureBuilder<List<Employee>>(
      future: _peopleData,
      builder: (BuildContext context, AsyncSnapshot<List<Employee>> snapshot){
        if (snapshot.hasData) {
          List<Employee>? data = snapshot.data;
          return createListPeople(data);
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
  ListView createListPeople(data) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Card(
              child: createListTilePeople(data,index,data[index].emp_name, data[index].emp_desg + ", " + data[index].emp_discipline)
          );
        }
    );
  }
  ListTile createListTilePeople(data,index,String title, String subtitle) {
    return ListTile(
      onTap: (){
        Navigator.pushNamed(context, peopleDetailsRoute, arguments: PeolpeScreenArguments(
            data[index].emp_no ?? '',data[index].emp_name ?? '',data[index].emp_unit ?? '',data[index].emp_discipline ?? '',data[index].emp_bloodgroup ?? '',
            data[index].emp_desg ?? '',data[index].emp_email ?? '',data[index].emp_mobileNo ?? '',data[index].emp_intercom ?? '',
            data[index].emp_intercomResidence ?? ''
          ),
        );
      },
      title: Text(title,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 18,
          )),
      subtitle: Text(subtitle,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 15,
            color: Colors.blue[500],
          )),
      leading: CircleAvatar(
          backgroundColor: RandomColorModel().getColor(),
        backgroundImage: this._loadImageError ? null : NetworkImage(''),
        onBackgroundImageError: this._loadImageError ? null : (dynamic exception, StackTrace? stackTrace){
            this.setState((){
              this._loadImageError = true;
            });
        },
        child:this._loadImageError? Text(title.substring(0,1).toUpperCase(),style: TextStyle(
          color: Colors.black,
        )) : null
         ),
    );
  }
}
class PeopleDetails extends StatefulWidget {
  final String empNo;
  final String empName;
  final String empUnit;
  final String empDisc;
  final String empBldGrp;
  final String empDesg;
  final String empEmail;
  final String empMobile;
  final String empIntercom;
  final String empIntercomResidence;


  PeopleDetails(this.empNo,this.empName, this.empUnit,this.empDisc, this.empBldGrp,
      this.empDesg, this.empEmail,this.empMobile, this.empIntercom,this.empIntercomResidence);

  @override
  State<PeopleDetails> createState() => _PeopleDetailsState();
}
class _PeopleDetailsState extends State<PeopleDetails>{
  bool _loadImageError = false;
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
      body: ListView(
        //padding: EdgeInsets.all(10.0),
        children: [
          imageSection(widget.empNo),
          //divider(),
          nameSection(),
          buttonSection,
          descSection("Unit",widget.empUnit,Icons.business),
          descSection("Email",widget.empEmail.toLowerCase(),Icons.email),
          doubleDisp("Intercom (O)","Intercom (R)",widget.empIntercom,widget.empIntercomResidence,Icons.call),
        ],
      ),
    );
  }

  Widget imageSection(String empno) {
    return Card(
        elevation:0,
      child: Container(
        padding:EdgeInsets.all(8),
        child: CircleAvatar(
            radius: 70.0,
            backgroundColor: Colors.lime,
            backgroundImage: this._loadImageError ? null : NetworkImage('https://connect.bcplindia.co.in/Home/image?empno=1219'),
            onBackgroundImageError: this._loadImageError ? null : (dynamic exception, StackTrace? stackTrace){
              this.setState((){
                this._loadImageError = true;
              });
            },
            child:this._loadImageError? Text(widget.empName.substring(0,1).toUpperCase(),style: TextStyle(
              color: Colors.black,
            )) : null
        ),
      ),
    );
  }
  Widget nameSection(){
    return Card(
      elevation:2,
      child: ListTile(
        isThreeLine: true,
      title: Text(widget.empName,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20,
          )),
      subtitle:  Text(widget.empDesg +" ("+ widget.empDisc +")"+ "\n"+"+91 "+widget.empMobile,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Colors.blue[500],
          )),

      // leading: Icon(
      //   icon,
      //   color: Colors.blue[500],
      // ),
    ),
    ) ;
  }
  Widget descSection(String title, String subtitle, IconData icon){
    return ListTile(

      title: Text(title,
          style: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 15,
          )),
      subtitle: Text(subtitle,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 18,
            color: Colors.blue[500],
          )),
      leading: Icon(
        icon,
        color: Colors.blue[500],
      ),
    );
  }
  Widget doubleDisp(String title1, String title2, String subtitle1,String subtitle2, IconData icon){
    return Row(
      children: <Widget>[
        Expanded(
          child: ListTile(
            isThreeLine: true,
            leading: Icon(
              icon,
              color: Colors.blue[500],
            ),
            title: Text(title1,
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 15,
                )),
            subtitle: Text(subtitle1,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: Colors.blue[500],
                )),
          ),
        ),
        Expanded(
          child: ListTile(
            isThreeLine: true,
            leading: Icon(
              icon,
              color: Colors.blue[500],
            ),
            title: Text(title2,
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 15,
                )),
            subtitle: Text(subtitle2,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: Colors.blue[500],
                )),
          ),
        ),
      ],
    );
  }
  Widget buttonSection = Container(
      padding:EdgeInsets.all(15.0),
      child:
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButtonColumn(Colors.redAccent,Icons.call,'Call'),
          _buildButtonColumn(Colors.green,Icons.chat,'Message'),
          _buildButtonColumn(Colors.blue,Icons.share,'Share'),
          _buildButtonColumn(Colors.deepOrangeAccent,Icons.email,'Mail'),
        ],
      ),
  );

  // void _launchURL(String _url) async =>
  //     await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';
}
Column _buildButtonColumn(Color color, IconData icon, String label) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, color: color, size:25),
      Container(
        margin: const EdgeInsets.only(top: 8),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: color,
          ),
        ),
      ),
    ],
  );
}
class RandomColorModel {

  Random random = Random();
  Color getColor() {
    return Color.fromARGB(random.nextInt(300), random.nextInt(300),
        random.nextInt(300), random.nextInt(300));
  }
}
class PeolpeScreenArguments {
  final String empNo;
  final String empName;
  final String empUnit;
  final String empDisc;
  final String empBldGrp;
  final String empDesg;
  final String empEmail;
  final String empMobile;
  final String empIntercom;
  final String empIntercomResidence;

  PeolpeScreenArguments(this.empNo,this.empName, this.empUnit,this.empDisc, this.empBldGrp,
      this.empDesg, this.empEmail,this.empMobile, this.empIntercom,this.empIntercomResidence);
}