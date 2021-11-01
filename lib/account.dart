import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'home.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'models/models.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin{
  bool _isLoading = false;
  var errorMsg;
  final unameController = TextEditingController();
  final pwdController = TextEditingController();
  bool apiCall = false;
  late final AnimationController _controller = AnimationController(
    duration: Duration(seconds: 3),
    vsync: this,
  )..forward();
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          width: 40,
          child: Image.asset('images/bcpl_logo.png'),
        ),
        title: Text(
          'Connect',style: TextStyle(
          color:Colors.black54,
          fontSize: 23.0, fontWeight: FontWeight.bold,
        ),
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
                child: ScaleTransition(
                  scale: _animation,
                  child: Image.asset('images/connect_logo.png',scale: 2),
                ),
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
                        prefs.setBool('isLoggedIn', true);
                        // Create secure storage
                        final storage = new FlutterSecureStorage();
                        // Write value
                        await storage.write(key: 'empno', value: emp.emp_no);
                        await storage.write(key: 'name', value: emp.emp_name);
                        await storage.write(key: 'desg', value: emp.emp_desg);
                        await storage.write(key: 'disc', value: emp.emp_disc);
                        await storage.write(key: 'grade', value: emp.emp_grade);
                        await storage.write(key: 'auth_token', value: emp.auth_jwt);

                        //Set variables for first time view
                        setState(() {
                          empno = emp.emp_no!;
                          user = emp.emp_name!;
                          designation = emp.emp_desg!;
                          discipline = emp.emp_disc!;
                          grade = emp.emp_grade!;
                          auth_token = emp.auth_jwt!;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text("Welcome, ${emp.emp_name}")),
                        );
                        setState(() {
                          _isLoading = false;
                        });
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => Home()), (Route<dynamic> route) => false);
                      }
                      else{
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Invalid Credentials. Unable to login')),
                         );
                         setState(() {
                           _isLoading = false;
                         });
                      }
                    }
                    else{
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid Credentials. Unable to login')),
                      );
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


