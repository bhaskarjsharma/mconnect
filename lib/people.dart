import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/services/webservice.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'account.dart';
import 'constants.dart';
import 'fonts_icons/connect_app_icon_icons.dart';
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
  String _empUnit = '';
  String _empDisc = '';
  String _empBldGrp = '';

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
      body: PeopleFinderForm(),
    );
  }

  Form PeopleFinderForm(){
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
                  labelText: 'Employee Name (Optional)',
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



              // child:TextFormField(
              //   controller: empUnitControl,
              //   decoration: InputDecoration(
              //     border: OutlineInputBorder(),
              //     labelText: 'Employee Unit',
              //   ),
              // ),
            ),
            Container(
              padding: EdgeInsets.all(10),
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
              padding: EdgeInsets.all(10),
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
              child: Center( child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, peopleListRoute, arguments: PeolpeScreenArguments(
                      '',empNameContrl.text,_empUnit,_empDisc,_empBldGrp,
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
        title: Text('Connect - People'),
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
    String profilePicUrl = "https://connect.bcplindia.co.in/MobileAppAPI/imageFile?empno="+data[index].emp_no;
    return ListTile(
      onTap: () async{
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
      leading: CachedNetworkImage(
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => new CircleAvatar(
          backgroundColor: RandomColorModel().getColor(),
          child: Text(title.substring(0,1).toUpperCase(),style: TextStyle(
              color: Colors.black,),) ,
        ),
        fit: BoxFit.contain,
        imageUrl: profilePicUrl,
        imageBuilder: (context, imageProvider) { // you can access to imageProvider
          return CircleAvatar( // or any widget that use imageProvider like (PhotoView)
            backgroundImage: imageProvider,
          );
        },
      ),


      // CircleAvatar(
      //     backgroundImage: profileImage,
      //     backgroundColor: RandomColorModel().getColor(),
      //     foregroundColor: Colors.black,
      //     child: profileImage. Text(title.substring(0,1).toUpperCase(),style: TextStyle(
      //          color: Colors.black,
      //       ),
      //      ),
         // onBackgroundImageError: this._loadImageError ? null : (dynamic exception, StackTrace? stackTrace){
         //     this.setState((){
         //       this._loadImageError = true;
         //     });
         // },
         // child:this._loadImageError? Text(title.substring(0,1).toUpperCase(),style: TextStyle(
         //   color: Colors.black,
         // )) : null
         //),
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
        title: Text('Connect - People'),
      ),
      endDrawer: AppDrawer(),
      body: ListView(
        //padding: EdgeInsets.all(10.0),
        children: [
          imageSection(),
          //divider(),
          nameSection(),
          buttonSection(),
          descSection("Unit",widget.empUnit,Icons.business),
          descSection("Email",widget.empEmail.toLowerCase(),Icons.email),
          doubleDisp("Intercom (O)","Intercom (R)",widget.empIntercom,widget.empIntercomResidence,ConnectAppIcon.phone),
        ],
      ),
    );
  }

  Widget imageSection() {
    return Card(
        elevation:0,
      child: CachedNetworkImage(
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => new Container(
            padding:EdgeInsets.all(8),
            height:200,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black12),
                image: DecorationImage (
                  image: AssetImage ('images/user_default.png'),
                  fit: BoxFit.contain,
                )
            )
        ),
        fit: BoxFit.contain,
        imageUrl: "https://connect.bcplindia.co.in/MobileAppAPI/imageFile?empno="+widget.empNo,
        imageBuilder: (context, imageProvider) { // you can access to imageProvider
          return Container( // or any widget that use imageProvider like (PhotoView)
              padding:EdgeInsets.all(8),
              height:200,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black12),
                  image: DecorationImage (
                    image: imageProvider,
                    fit: BoxFit.contain,
                  )
              )
          );
        },
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
  Widget buttonSection(){
    return Container(
      padding:EdgeInsets.all(15.0),
      child:
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButtonColumn(Colors.redAccent,Icons.call,'Call',widget.empMobile,"tell"),
          _buildButtonColumn(Colors.green,Icons.chat,'Message',widget.empMobile,"sms"),
          _buildButtonColumn(Colors.blue,Icons.share,'Share',widget.empName+ " : "+widget.empMobile,"share"),
          _buildButtonColumn(Colors.deepOrangeAccent,Icons.email,'Mail',widget.empEmail,"mail"),
        ],
      ),
    );
  }

  // void _launchURL(String _url) async =>
  //     await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';
}
InkWell _buildButtonColumn(Color color, IconData icon, String label,String data,String launcherType) {
  return InkWell(
    onTap: () async{
      String url='';
      if(launcherType == "tell" || launcherType == "sms" || launcherType == "mail"){
        if(launcherType == "tell"){
          url = "tel:"+data;
        }
        else if(launcherType == "sms"){
          url = "sms:"+data;
        }
        else if(launcherType == "mail"){
          url = "mailto:"+data;
        }
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw "Can't open launcher.";
        }
      }
      else if(launcherType == "share"){
        Share.share("Contact: "+data);
      }
    },
    child: Column(
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
  ),
  );
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