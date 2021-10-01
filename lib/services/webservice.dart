import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../home.dart';
import 'package:flutter_projects/models/models.dart';
import 'package:flutter_projects/services/permissions.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Future<List<NewsContent>> fetchContent() async{
  final response = await http.get(
    Uri.parse('https://connect.bcplindia.co.in/MobileAppAPI/News_Events'),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    //return NewsContent.fromJson(jsonDecode(response.body));

    List jsonResponse = jsonDecode(response.body);
    return jsonResponse.map((newscontent) => new NewsContent.fromJson(newscontent)).toList();
  } else {
    // If the server did not return a 200 OK response,
    print("The error message is: ${response.body}");
    throw Exception('Failed to authenticate.');
  }
}

Future<List<NewsAttachment>> fetchContentAttachments(int contentId, String contentType) async{

  // Here Dio is used instead of the native HTTP
  final response = await Dio().post('https://connect.bcplindia.co.in/MobileAppAPI/ContentAttachments',
      data: {'contentId': contentId, 'contentType': contentType});

  if (response.statusCode == 200) {
    List jsonResponse = response.data;
    return jsonResponse.map((attachments) => NewsAttachment.fromJson(attachments)).toList();

  } else {
    print("The error message is: ${response.data}");
    throw Exception('Failed to retrieve data.');
  }
}

Future<List<Employee>> fetchEmployees(String empName, String empUnit, String empDiscp, String empBloodGrp) async{
  final response = await http.post(
    Uri.parse('https://connect.bcplindia.co.in/MobileAppAPI/EmployeeList'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'name': empName,
      'unit': empUnit,
      'discipline':empDiscp,
      'bloodGr':empBloodGrp,
    }),
  );

  if (response.statusCode == 200) {
    List jsonResponse = jsonDecode(response.body);
    return jsonResponse.map((employees) => new Employee.fromJson(employees)).toList();

  } else {
    print("The error message is: ${response.body}");
    throw Exception('Failed to retrieve data.');
  }
}

Future<LeaveQuota> fetchLeaveQuota(String empno) async{
  final response = await http.post(
    Uri.parse('https://connect.bcplindia.co.in/MobileAppAPI/GetLeaveQuota'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'empno': empno,
    }),
  );

  if (response.statusCode == 200) {
    return LeaveQuota.fromJson(jsonDecode(response.body));
  } else {
    print("The error message is: ${response.body}");
    throw Exception('Failed to retrieve data.');
  }
}

Future<List<Document>> fetchDocuments(String docName, String docType) async{
  final response = await http.post(
    Uri.parse('https://connect.bcplindia.co.in/MobileAppAPI/DocumentList'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'docName': docName,
      'docType': docType,
    }),
  );

  if (response.statusCode == 200) {
    List jsonResponse = jsonDecode(response.body);
    return jsonResponse.map((docs) => Document.fromJson(docs)).toList();

  } else {
    print("The error message is: ${response.body}");
    throw Exception('Failed to retrieve data.');
  }
}
Future<List<HolidayList>> fetchHolidayList() async{

  // Here Dio is used instead of the native HTTP
  final response = await Dio().get('https://connect.bcplindia.co.in/MobileAppAPI/GetHolidayList');

  if (response.statusCode == 200) {
    List jsonResponse = response.data;
    return jsonResponse.map((dataList) => HolidayList.fromJson(dataList)).toList();

  } else {
    print("The error message is: ${response.data}");
    throw Exception('Failed to retrieve data.');
  }
}
Future<List<ShiftRoster>> fetchShiftRosterData(String empno, String fromDate, String toDate) async{

  // Here Dio is used instead of the native HTTP
  final response = await Dio().post('https://connect.bcplindia.co.in/MobileAppAPI/ShiftRosterData',
      data: {'empno': empno, 'fromDate': fromDate, 'toDate': toDate});

  if (response.statusCode == 200) {
    List jsonResponse = response.data;
    return jsonResponse.map((dataList) => ShiftRoster.fromJson(dataList)).toList();

  } else {
    print("The error message is: ${response.data}");
    throw Exception('Failed to retrieve data.');
  }
}
Future<List<AttendanceData>> fetchAttendanceData(String empno, String fromDate, String toDate) async{

  // Here Dio is used instead of the native HTTP
  final response = await Dio().post('https://connect.bcplindia.co.in/MobileAppAPI/BiometricPunchData',
      data: {'empno': empno, 'fromDate': fromDate, 'toDate': toDate});

  if (response.statusCode == 200) {
    List jsonResponse = response.data;
    return jsonResponse.map((dataList) => AttendanceData.fromJson(dataList)).toList();

  } else {
    print("The error message is: ${response.data}");
    throw Exception('Failed to retrieve data.');
  }
}
Future<List<PayrollData>> fetchPayrollData(String empno, String month, String year) async{

  // Here Dio is used instead of the native HTTP
  final response = await Dio().post('https://connect.bcplindia.co.in/MobileAppAPI/GetPayrollResult',
      data: {'empno': empno, 'month': month, 'year': year});

  if (response.statusCode == 200) {
    List jsonResponse = response.data;
    return jsonResponse.map((dataList) => PayrollData.fromJson(dataList)).toList();

  } else {
    print("The error message is: ${response.data}");
    throw Exception('Failed to retrieve data.');
  }
}
Future<String> getDownloadDirectory() async {
  var externalStorageDirPath;
  if (Platform.isAndroid) {
    final directory = await getExternalStorageDirectory();
    externalStorageDirPath = directory?.path;
  }
  else if (Platform.isIOS) {
    externalStorageDirPath = (await getApplicationDocumentsDirectory()).absolute.path;
  }
  return externalStorageDirPath;
}







