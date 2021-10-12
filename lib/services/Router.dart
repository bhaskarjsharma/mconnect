
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../AttendanceView.dart';
import '../Payslip.dart';
import '../ShiftRosterView.dart';
import '../account.dart';
import '../claim.dart';
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
      case peopleRoute:
        final args = settings.arguments;
        return MaterialPageRoute(builder: (BuildContext context) => People(),settings: RouteSettings(arguments: args,),);
      case documentsRoute:
        final args = settings.arguments;
        return MaterialPageRoute(builder: (BuildContext context) => Documents(),settings: RouteSettings(arguments: args,),);
      case payslipRoute:
        final args = settings.arguments;
        return MaterialPageRoute(builder: (BuildContext context) => Payslip(),settings: RouteSettings(arguments: args,),);
      case shiftRosterRoute:
        final args = settings.arguments;
        return MaterialPageRoute(builder: (BuildContext context) => ShiftRosterView(),settings: RouteSettings(arguments: args,),);
      case attendanceRoute:
        final args = settings.arguments;
        return MaterialPageRoute(builder: (BuildContext context) => AttendanceView(),settings: RouteSettings(arguments: args,),);
      case claimsRoute:
        final args = settings.arguments;
        return MaterialPageRoute(builder: (BuildContext context) => Claims(),settings: RouteSettings(arguments: args,),);
      case feedbackRoute:
        return MaterialPageRoute(builder: (_) => AppFeedback());
      case aboutAppRoute:
        return MaterialPageRoute(builder: (_) => AboutApp());
      case downloadsRoute:
        return MaterialPageRoute(builder: (_) => DownloadDirectory());
      case leaveQuotaRoute:
        return MaterialPageRoute(builder: (_) => LeaveQuotas());
      case holidayListRoute:
        return MaterialPageRoute(builder: (_) => Holidays());
      case hosCrLtrRoute:
        return MaterialPageRoute(builder: (_) => HospitalCreditLetter());
      case newsDetailsRoute:
        final args = settings.arguments as NewsContentArguments;
        return MaterialPageRoute(builder: (BuildContext context) => NewsDetails(args.contentId,args.contentType,args.contentTitle,args.contentDescription,args.creationDate));

    // case payslipDataRoute:
      //   final args = settings.arguments as PayslipScreenArguments;
      //   return MaterialPageRoute(builder: (BuildContext context) => PayslipData(args.month,args.year));

      // case peopleListRoute:
      //   final args = settings.arguments as PeolpeScreenArguments;
      //   return MaterialPageRoute(builder: (BuildContext context) => PeopleList(args.empName,args.empUnit,args.empDisc,args.empBldGrp));
      case peopleDetailsRoute:
        final args = settings.arguments as PeolpeScreenArguments;
        return MaterialPageRoute(builder: (BuildContext context) => PeopleDetails(args.empNo,args.empName,args.empUnit,args.empDisc,
            args.empBldGrp,args.empDesg,args.empEmail,args.empMobile,args.empIntercom,args.empIntercomResidence));

      // case documentListRoute:
      //   final args = settings.arguments as DocumentScreenArguments;
      //   return MaterialPageRoute(builder: (BuildContext context) => DocumentList(args.docName,args.docType));


      // case shiftRosterListRoute:
      //   final args = settings.arguments as ScreenArguments;
      //   return MaterialPageRoute(builder: (BuildContext context) => ShiftRosterList(args.fromDate,args.toDate));

      // case attendanceListRoute:
      //   final args = settings.arguments as ScreenArguments;
      //   return MaterialPageRoute(builder: (BuildContext context) => attendanceList(args.fromDate,args.toDate));


      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(
                  child: Text('No route defined for ${settings.name}')),
            ));
    }
  }
}