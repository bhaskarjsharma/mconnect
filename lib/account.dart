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
        leading: Container(
          width: 40,
          child: Image.asset('images/bcpl_logo.png'),
        ),
        title: Text(
          'Connect',
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
      body: Center(
        child: _isLoading ? SingleChildScrollView(child: Column(
          children: <Widget>[
            CircularProgressIndicator(),
            Container(
              padding: EdgeInsets.all(10),
              child:Text('Login In...',style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),),
            ),
          ],
        ),) : SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                child:Image.asset('images/connect_logo.png',scale: 2),
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
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(content: Text('Login In...')),
                    // );
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

