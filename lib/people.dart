import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/services/webservice.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'account.dart';
import 'app_drawer.dart';
import 'constants.dart';
import 'fonts_icons/connect_app_icon_icons.dart';
import 'home.dart';
import 'main.dart';
import 'models/models.dart';

class People extends StatefulWidget{
  @override
  State<People> createState() => _PeopleState();
}
class _PeopleState extends State<People>{
  bool isLoading = false;
  bool _showBackToTopButton = false;
  late ScrollController _scrollController;
  late DioClient _dio;
  late var _endpointProvider;
  late Future<APIResponseData> _apiResponseData;
  //late List<Employee> peopleData;

  @override
  void initState() {
    super.initState();
    _dio = new DioClient();
    _endpointProvider = new EndPointProvider(_dio.init());
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          if (_scrollController.offset >= 400) {
            _showBackToTopButton = true; // show the back-to-top button
          } else {
            _showBackToTopButton = false; // hide the back-to-top button
          }
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    List<Employee> _peopleData = ModalRoute.of(context)!.settings.arguments as List<Employee>;
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          width: 40,
          child: Image.asset('images/bcpl_logo.png'),
        ),
        title: Row(
          children:[
            Text('Connect - People'),
            Spacer(),
            IconButton(
              icon: Icon(Icons.sync),
              onPressed: () {
                if(connectionStatus != ConnectivityResult.none){
                  setState(() {
                    isLoading = true;
                  });
                  _apiResponseData = _endpointProvider.fetchEmployees('','','','');
                  _apiResponseData.then((result) async {
                    if(result.isAuthenticated && result.status){
                      final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
                      setState(() {
                        _peopleData =  parsed.map<Employee>((json) => Employee.fromJson(json)).toList();
                        isLoading = false;
                      });
                      var employeeBox = await Hive.openBox<Employee>('employeeList');
                      employeeBox.clear();
                      employeeBox.addAll(_peopleData);
/*                    Navigator.pop(context);
                    Navigator.pushNamed(context, peopleRoute, arguments: peopleData,);*/
                    }
                    else{
                      setState(() {
                        isLoading = false;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error in data fetching")),
                      );
                    }
                  }).catchError( (error) {
                    setState(() {
                      isLoading = false;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error in data fetching")),
                    );
                  });
                }
                else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("No internet connection. Please check your settings")),
                  );
                }
              },
              color: Colors.white,
            )
          ],
        ),
      ),
      endDrawer: AppDrawer(),
      body: isLoading ? refresh(context) :
      Column(
        children: [
          connectionStatus != ConnectivityResult.none ? SizedBox(height:0) : noConnectivityError(),
          Expanded(
            child: ListView.builder(
                itemCount: _peopleData.length,
                itemBuilder: (context, index) {
                  return Card(
                      child: createListTilePeople(_peopleData,index)
                  );
                }
            ),
          ),
        ],
      ),

      floatingActionButton: _showBackToTopButton == false
          ? null
          : FloatingActionButton(
        onPressed: _scrollToTop,
        child: Icon(Icons.arrow_upward),
      ),
    );
  }
  ListTile createListTilePeople(data,index) {
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
      title: Text(data[index].emp_name,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 18,
          )),
      subtitle: Text("${data[index].emp_desg}, ${data[index].emp_discipline}",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 15,
            color: Colors.blue[500],
          )),
      leading: CachedNetworkImage(
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => new CircleAvatar(
          backgroundColor: RandomColorModel().getColor(),
          child: Text(data[index].emp_name.substring(0,1).toUpperCase(),style: TextStyle(
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
  void _scrollToTop() {
    _scrollController.animateTo(0,
        duration: Duration(seconds: 3), curve: Curves.linear);
  }
  @override
  void dispose() {
    _scrollController.dispose(); // dispose the controller
    super.dispose();
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
      body: Column(
        children: [
          connectionStatus != ConnectivityResult.none ? SizedBox(height:0) : noConnectivityError(),
          Expanded(
            child: ListView(
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
          ),
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
