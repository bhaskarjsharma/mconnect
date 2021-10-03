
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../AttendanceView.dart';
import '../Payslip.dart';
import '../ShiftRosterView.dart';
import '../account.dart';
import '../constants.dart';
import '../content.dart';
import '../documents.dart';
import '../home.dart';
import '../people.dart';

class NavigationRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginRoute:
        return MaterialPageRoute(builder: (_) => Login());
      case homeRoute:
        return MaterialPageRoute(builder: (_) => Home());
      case newsRoute:
        return MaterialPageRoute(builder: (_) => News());
      case feedbackRoute:
        return MaterialPageRoute(builder: (_) => AppFeedback());
      case aboutAppRoute:
        return MaterialPageRoute(builder: (_) => AboutApp());
      case downloadsRoute:
        return MaterialPageRoute(builder: (_) => DownloadDirectory());
      case newsDetailsRoute:
        final args = settings.arguments as NewsContentArguments;
        return MaterialPageRoute(builder: (BuildContext context) => NewsDetails(args.contentId,args.contentType,args.contentTitle,args.contentDescription,args.creationDate));
      case peopleRoute:
        return MaterialPageRoute(builder: (BuildContext context) => People());
      case peopleListRoute:
        final args = settings.arguments as PeolpeScreenArguments;
        return MaterialPageRoute(builder: (BuildContext context) => PeopleList(args.empName,args.empUnit,args.empDisc,args.empBldGrp));
      case peopleDetailsRoute:
        final args = settings.arguments as PeolpeScreenArguments;
        return MaterialPageRoute(builder: (BuildContext context) => PeopleDetails(args.empNo,args.empName,args.empUnit,args.empDisc,
            args.empBldGrp,args.empDesg,args.empEmail,args.empMobile,args.empIntercom,args.empIntercomResidence));
      case documentsRoute:
        return MaterialPageRoute(builder: (BuildContext context) => DocumentScreen());
      case documentListRoute:
        final args = settings.arguments as DocumentScreenArguments;
        return MaterialPageRoute(builder: (BuildContext context) => DocumentList(args.docName,args.docType));
      case leaveQuotaRoute:
        return MaterialPageRoute(builder: (_) => LeaveQuotas());
      case holidayListRoute:
        return MaterialPageRoute(builder: (_) => Holidays());
      case shiftRosterRoute:
        return MaterialPageRoute(builder: (_) => ShiftRosterView());
      case shiftRosterListRoute:
        final args = settings.arguments as ShiftRosterScreenArguments;
        return MaterialPageRoute(builder: (BuildContext context) => ShiftRosterList(args.fromDate,args.toDate));
      case attendanceRoute:
        return MaterialPageRoute(builder: (_) => AttendanceView());
      case attendanceListRoute:
        final args = settings.arguments as AttendanceScreenArguments;
        return MaterialPageRoute(builder: (BuildContext context) => attendanceList(args.fromDate,args.toDate));
      case payslipRoute:
        return MaterialPageRoute(builder: (_) => Payslip());
      case payslipDataRoute:
        final args = settings.arguments as PayslipScreenArguments;
        return MaterialPageRoute(builder: (BuildContext context) => PayslipData(args.month,args.year));
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(
                  child: Text('No route defined for ${settings.name}')),
            ));
    }
  }
}