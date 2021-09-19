import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'home.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final unameController = TextEditingController();
  final pwdController = TextEditingController();
  bool apiCall = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter layout demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Connect'),
        ),
        body: ListView(
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
                  apiCall = true; // Set state like this
                  Employee emp = await authenticate(unameController.text,pwdController.text);
                  if(emp != null) {
                    // obtain shared preferences
                    final prefs = await SharedPreferences.getInstance();
                    // set value
                    prefs.setString('empno', emp.empno);
                    prefs.setString('name', emp.name);
                    prefs.setBool('isLoggedIn', true);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                    );
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
}

Future<Employee> authenticate(String uname, String pwd) async{
  final response = await http.post(
    Uri.parse('https://connect.bcplindia.co.in/MobileAppAPI/authenticate'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'username': uname,
      'password':pwd,
    }),
  );

  if (response.statusCode == 201) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.
    return Employee.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Failed to authenticate.');
  }
}

class Employee{
  final String empno;
  final String name;

  Employee({required this.empno, required this.name});
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      empno: json['empno'],
      name: json['name'],
    );
  }
}

