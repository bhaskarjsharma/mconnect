
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/models/models.dart';
import '../AttendanceView.dart';
import '../Payslip.dart';
import '../ShiftRosterView.dart';
import '../account.dart';
import '../app_drawer.dart';
import '../claim.dart';
import '../constants.dart';
import '../content.dart';
import '../disha.dart';
import '../documents.dart';
import '../home.dart';
import '../people.dart';
import '../quiz.dart';

class NavigationRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginRoute:
        return MaterialPageRoute(builder: (_) => Login());
      case homeRoute:
        return MaterialPageRoute(builder: (_) => Home());
      case newsRoute:
        return MaterialPageRoute(builder: (_) => News());
      case birthdayRoute:
        return MaterialPageRoute(builder: (_) => Birthday());
      case dishaRoute:
        return MaterialPageRoute(builder: (_) => Disha());
      case addrProofRoute:
        return MaterialPageRoute(builder: (_) => AddProofApp());
      case addrChangeRoute:
        return MaterialPageRoute(builder: (_) => AddChangeApp());
      case outEmpRoute:
        return MaterialPageRoute(builder: (_) => OutEmpApp());
      case medBenefitRoute:
        return MaterialPageRoute(builder: (_) => MedBenApp());
      case highEduRoute:
        return MaterialPageRoute(builder: (_) => HighEduApp());
      case claRoute:
        return MaterialPageRoute(builder: (_) => CLAApp());
      case hraRoute:
        return MaterialPageRoute(builder: (_) => HRAApp());
      case qtrAllocRoute:
        return MaterialPageRoute(builder: (_) => QtrAlloc());
      case profileRoute:
        return MaterialPageRoute(builder: (_) => UserProfile());
      case tfaRoute:
        final args = settings.arguments as OTPauth;
        return MaterialPageRoute(builder: (BuildContext context) => TwoFactorAuth(args.otpRecordID,args.deviceStatRecordID));
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
      case quizRoute:
        final args = settings.arguments;
        return MaterialPageRoute(builder: (BuildContext context) => QuizView(),settings: RouteSettings(arguments: args,),);
      case quizDetailRoute:
        final args = settings.arguments;
        return MaterialPageRoute(builder: (BuildContext context) => QuizDetail(),settings: RouteSettings(arguments: args,),);
      case quizStartRoute:
        final args = settings.arguments as QuizData;
        return MaterialPageRoute(builder: (BuildContext context) => QuizStart(args));
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
      case ecofOTRoute:
        return MaterialPageRoute(builder: (_) => ECOFF_OT());
      case itacRoute:
        return MaterialPageRoute(builder: (_) => ITAC());
      case notificationRoute:
        return MaterialPageRoute(builder: (_) => NotificationView());
      case appThemeRoute:
        return MaterialPageRoute(builder: (_) => AppTheme());
      case newsDetailsRoute:
        final args = settings.arguments as NewsContentArguments;
        return MaterialPageRoute(builder: (BuildContext context) => NewsDetails(args.contentId,args.contentType,args.contentTitle,args.contentDescription,args.creationDate));
      case newsDisplayRoute:
        final args = settings.arguments as NewsWithAttchArguments;
        return MaterialPageRoute(builder: (BuildContext context) => NewsDisplay(args.contentId));
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