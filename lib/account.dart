import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:mobile_number/mobile_number.dart';
import 'dart:async';
import 'dart:convert';
import 'constants.dart';
import 'home.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'models/models.dart';
import 'dart:io';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}
class _LoginState extends State<Login> with TickerProviderStateMixin{

  //ConnectivityResult _connectionStatus = ConnectivityResult.mobile;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _isLoading = false;
  var errorMsg;
  final unameController = TextEditingController();
  final pwdController = TextEditingController();
  bool apiCall = false;
  late Future<EmployeeLoginData> _empLoginData;
  String _mobileNumber = '';
  List<SimCard> _simCard = <SimCard>[];
  bool access = false;

  late final AnimationController _controller = AnimationController(
    duration: Duration(seconds: 3),
    vsync: this,
  )..forward();
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  );

  @override
  void initState(){
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    MobileNumber.listenPhonePermission((isPermissionGranted) {
      if (isPermissionGranted) {
        initMobileNumberState();
      } else {}
    });

    initMobileNumberState();
  }

  Future<void> initMobileNumberState() async {
    if (!await MobileNumber.hasPhonePermission) {
      await MobileNumber.requestPhonePermission;
      return;
    }
    String mobileNumber = '';
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      mobileNumber = (await MobileNumber.mobileNumber)!;
      _simCard = (await MobileNumber.getSimCards)!;
    } on PlatformException catch (e) {
      debugPrint("Failed to get mobile number because of '${e.message}'");
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _mobileNumber = mobileNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          title: Text(
            'Connect',style: TextStyle(
            color:appBarTextColor,
            fontSize: 23.0, fontWeight: FontWeight.bold,
          ),
          ),
        ),
        body: Center(
          child: connectionStatus != ConnectivityResult.none ?
          _isLoading ? SingleChildScrollView(child: Column(
            children: <Widget>[
              Center(
                child: Lottie.asset('animations/ani_loading_hexa.json',
                  width: 200,
                  height: 200,),
              ),
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
                GestureDetector(
                  child: Lottie.asset('animations/ani_unlock.json',
                    width: 50,
                    height: 50,),
                  onTap: () async{
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(content: Text('Login In...')),
                    // );
                    setState(() {
                      _isLoading = true;
                    });

                    _empLoginData = authenticate(unameController.text,pwdController.text);
                    _empLoginData.then((result) async {
                      if(result.status){
                        // read mobile number from SIM or send SMS for OTP verification to
                        // BCPL registered mobile number
                        //first check if primary sim mobile number on device matches with registered number

                        if(Platform.isAndroid){
                          // sim card number detection works in android only
                          if(_mobileNumber == result.emp_mobileNo){
                            setState((){
                              access = true;
                            });
                          }
                          else{
                            // primary sim card number does not match. check for dual sim card numbers
                            for(SimCard sim in _simCard){
                              if(sim.number == result.emp_mobileNo){
                                setState((){
                                  access = true;
                                });
                                break;
                              }
                            }
                          }
                        }
                        else if(Platform.isIOS){
                          // for iphone initiate OTP verification
                          setState((){
                            access = true;
                          });
                        }

                        if(access){
                          // obtain shared preferences
                          final prefs = await SharedPreferences.getInstance();
                          // set value
                          prefs.setBool('isLoggedIn', true);
                          // Create secure storage
                          final storage = new FlutterSecureStorage();
                          // Write value
                          await storage.write(key: 'empno', value: result.emp_no);
                          await storage.write(key: 'name', value: result.emp_name);
                          await storage.write(key: 'desg', value: result.emp_desg);
                          await storage.write(key: 'disc', value: result.emp_disc);
                          await storage.write(key: 'grade', value: result.emp_grade);
                          await storage.write(key: 'auth_token', value: result.auth_jwt);

                          //Set variables for first time view
                          setState(() {
                            empno = result.emp_no!;
                            user = result.emp_name!;
                            designation = result.emp_desg!;
                            discipline = result.emp_disc!;
                            grade = result.emp_grade!;
                            auth_token = result.auth_jwt!;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Welcome, ${result.emp_name}")),
                          );
                          setState(() {
                            _isLoading = false;
                          });

                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => Home()), (Route<dynamic> route) => false);
                        }
                        else{
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Device mobile number validation failed.')),
                          );
                          setState(() {
                            _isLoading = false;
                            access = false;
                          });
                        }
                        //Navigator.pushNamed(context, tfaRoute);
                      }
                      else{
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid Credentials. Unable to login')),
                        );
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }).catchError( (error) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Unable to connect to server")),
                      );
                    });

/*                  EmployeeLoginData emp = await authenticate(unameController.text,pwdController.text);
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
                    }*/
                  },
                ),
                /*     Container(
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

              ),*/
                errorMsg == null? Container(): Text(
                  "${errorMsg}",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ) : noConnectivityError(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    unameController.dispose();
    pwdController.dispose();
    _connectivitySubscription.cancel();
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
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }
    return _updateConnectionStatus(result);
  }
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {

    if(result != ConnectivityResult.none){
      // connectivity detected
      if (Platform.isAndroid) {
        // Android- check if there is actual internet connection
        bool isDeviceConnected = false;
        try {
          final result = await InternetAddress.lookup('google.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            isDeviceConnected = true;
          } else {
            isDeviceConnected = false;
          }
        } on SocketException catch(_) {
          isDeviceConnected = false;
        }
        //isDeviceConnected = await DataConnectionChecker().hasConnection;
        if(isDeviceConnected){
          setState(() {
            connectionStatus = result;
          });
        }
      } else if (Platform.isIOS) {
        // result from default connectivity check can be updated
        setState(() {
          connectionStatus = result;
        });
      }
    }
    else{
      // No connectivity
      setState(() {
        connectionStatus = result;
      });
    }
  }
  Widget noConnectivityError(){
    return Container (
      height: MediaQuery.of(context).size.height / 1.3,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Lottie.asset('animations/ani_no_internet.json',
                width: 177,
                height: 244,),
            ),
            Center(
                child: Text('No Internet connection. Please check data/wifi settings',style: TextStyle(
                  fontWeight: FontWeight.w400,fontSize: 15,),)
            ),
          ],
        ),
      ),
    );
  }
}

class TwoFactorAuth extends StatefulWidget {
  @override
  State<TwoFactorAuth> createState() => _TwoFactorAuthState();
}
class _TwoFactorAuthState extends State<TwoFactorAuth>{

  //ConnectivityResult _connectionStatus = ConnectivityResult.mobile;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _isLoading = false;
  var errorMsg;
  final unameController = TextEditingController();
  final pwdController = TextEditingController();
  bool apiCall = false;

  late String code;
  late bool loaded;
  late bool shake;
  late bool valid;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _textNode = FocusNode();

  @override
  void initState(){
    code = '';
    loaded = true;
    shake = false;
    valid = true;
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }
  void onCodeInput(String value) {
    setState(() {
      code = value;
    });
  }

  Future<void> verifyMfaAndNext() async {
    setState(() {
      loaded = false;
    });
    const bool result = false; //backend call
    setState(() {
      loaded = true;
      valid = result;
    });

    if (valid) {
      // do next
    } else {
      setState(() {
        shake = true;
      });
      await Future<String>.delayed(
          const Duration(milliseconds: 300), () => '1');
      setState(() {
        shake = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
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
          title: Text(
            'Connect',style: TextStyle(
            color:appBarTextColor,
            fontSize: 23.0, fontWeight: FontWeight.bold,
          ),
          ),
        ),
        body: Center(
          child: connectionStatus != ConnectivityResult.none ?
          _isLoading ? SingleChildScrollView(child: Column(
            children: <Widget>[
              Center(
                child: Lottie.asset('animations/ani_loading_hexa.json',
                  width: 200,
                  height: 200,),
              ),
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
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 80),
                  child: Text(
                    'Verify your phone',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 60,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text('Please enter the 6 digit pin sent to your mobile number',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color:textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 90,
                  width: 300,
                  // color: Colors.amber,
                  child: Stack(
                    children: <Widget>[
                      Opacity(
                        opacity: 0.0,
                        child: TextFormField(
                          controller: _controller,
                          focusNode: _textNode,
                          keyboardType: TextInputType.number,
                          onChanged: onCodeInput,
                          maxLength: 6,
                        ),
                      ),
                      Positioned(
                        bottom: 40,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: getField(),
                        ),
                      )
                    ],
                  ),
                ),
                CupertinoButton(
                  onPressed: verifyMfaAndNext,
                  color: Colors.grey,
                  child: Text(
                    'Verify',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
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
          ) : noConnectivityError(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _connectivitySubscription.cancel();
    super.dispose();
  }
  List<Widget> getField() {
    final List<Widget> result = <Widget>[];
    for (int i = 1; i <= 6; i++) {
      result.add(
          Column(
            children: <Widget>[
              if (code.length >= i)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                  ),
                  child: Text(
                    code[i - 1],
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                ),
                child: Container(
                  height: 5.0,
                  width: 30.0,
                  color: shake ? Colors.red : Colors.black,
                ),
              ),
            ],
          ),
      );
    }
    return result;
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }
    return _updateConnectionStatus(result);
  }
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {

    if(result != ConnectivityResult.none){
      // connectivity detected
      if (Platform.isAndroid) {
        // Android- check if there is actual internet connection
        bool isDeviceConnected = false;
        try {
          final result = await InternetAddress.lookup('google.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            isDeviceConnected = true;
          } else {
            isDeviceConnected = false;
          }
        } on SocketException catch(_) {
          isDeviceConnected = false;
        }
        //isDeviceConnected = await DataConnectionChecker().hasConnection;
        if(isDeviceConnected){
          setState(() {
            connectionStatus = result;
          });
        }
      } else if (Platform.isIOS) {
        // result from default connectivity check can be updated
        setState(() {
          connectionStatus = result;
        });
      }
    }
    else{
      // No connectivity
      setState(() {
        connectionStatus = result;
      });
    }
  }
  Widget noConnectivityError(){
    return Container (
      height: MediaQuery.of(context).size.height / 1.3,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Lottie.asset('animations/ani_no_internet.json',
                width: 177,
                height: 244,),
            ),
            Center(
                child: Text('No Internet connection. Please check data/wifi settings',style: TextStyle(
                  fontWeight: FontWeight.w400,fontSize: 15,),)
            ),
          ],
        ),
      ),
    );
  }
}


