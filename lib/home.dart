import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'account.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>  {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Connect'),
      ),
      drawer: AppDrawer(),
      body: Center(
        child: ElevatedButton(
            child: Text('Logout'),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => Login()), (Route<dynamic> route) => false);
            }
        ),
      ),
    );
  }
}
