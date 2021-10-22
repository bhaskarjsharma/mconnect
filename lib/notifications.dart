

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home.dart';

class NotificationView extends StatelessWidget  {

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
      body: Text('Notification screen'),
    );
  }

}

