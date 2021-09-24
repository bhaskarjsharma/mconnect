import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'home.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isLoading = false;
  var errorMsg;
  final unameController = TextEditingController();
  final pwdController = TextEditingController();
  bool apiCall = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connect'),
      ),
      body: Container(
        child: _isLoading ? Center(child: CircularProgressIndicator()) : ListView(
          children: <Widget>[
            Container(
              child: Image.asset('images/bcpl_logo.png'),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: unameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'User Name',
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: pwdController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: ElevatedButton(
                child: Text('Login'),
                onPressed: () async{
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Login In...')),
                  );
                  setState(() {
                    _isLoading = true;
                  });
                  EmployeeLoginData emp = await authenticate(unameController.text,pwdController.text);
                  if(emp != null) {
                    if(emp.status){
                      // obtain shared preferences
                      final prefs = await SharedPreferences.getInstance();
                      // set value
                      prefs.setString('empno', emp.emp_no);
                      prefs.setString('name', emp.emp_name);
                      prefs.setBool('isLoggedIn', true);
                      setState(() {
                        _isLoading = false;
                      });
                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => Home()), (Route<dynamic> route) => false);
                    }
                    else{
                      setState(() {
                        _isLoading = false;
                      });
                      // showDialog(
                      //   context: context,
                      //   builder: (context) {
                      //     return AlertDialog(
                      //       // Retrieve the text the that user has entered by using the
                      //       // TextEditingController.
                      //       content: Text('Authentication Failed'),
                      //     );
                      //   },
                      // );
                    }
                  }
                  else{
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          // Retrieve the text the that user has entered by using the
                          // TextEditingController.
                          content: Text('Authentication Failed'),
                        );
                      },
                    );
                  }
                },
              ),

            ),
            errorMsg == null? Container(): Text(
              "${errorMsg}",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    unameController.dispose();
    pwdController.dispose();
    super.dispose();
  }

  Future<EmployeeLoginData> authenticate(String uname, String pwd) async{
    final response = await http.post(
      Uri.parse('https://connect.bcplindia.co.in/MobileAppAPI/Login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': uname,
        'password':pwd,
      }),
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return EmployeeLoginData.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      setState(() {
        _isLoading = false;
      });
      errorMsg = response.body;
      print("The error message is: ${response.body}");
      throw Exception('Failed to authenticate.');
    }
  }
}
class AppDrawer extends StatefulWidget {
  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late SharedPreferences sharedPreferences;
  final String user = prefs.getString('name') ?? '';

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
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromRGBO(165, 231, 206, 1.0),
            ),
            child: Text(user,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                )),
          ),
          ListTile(
            title: const Text('Home'),
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => Home()), (Route<dynamic> route) => false);
            },
          ),
          ListTile(
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => Login()), (Route<dynamic> route) => false);
  }
}

class EmployeeLoginData{
  final bool status;
  final String emp_no;
  final String emp_name;

  EmployeeLoginData({required this.status, required this.emp_no, required this.emp_name});
  factory EmployeeLoginData.fromJson(Map<String, dynamic> json) {
    return EmployeeLoginData(
      status: json['status'],
      emp_no: json['emp_no'],
      emp_name: json['emp_name'],
    );
  }
}

