
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home.dart';

class Claims extends StatefulWidget {
  final String fromDate;
  final String toDate;
  final String claimType;

  Claims(this.fromDate, this.toDate, this.claimType);

  @override
  State<Claims> createState() => _ClaimsState();
}
class _ClaimsState extends State<Claims>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          width: 40,
          child: Image.asset('images/bcpl_logo.png'),
        ),
        title: Text('Connect - Claims'),
      ),
      endDrawer: AppDrawer(),
      body: Text('Claims'),
    );
  }
}