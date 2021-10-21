import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../home.dart';
import 'package:flutter_projects/models/models.dart';
import 'package:flutter_projects/services/permissions.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../main.dart';


class DioClient{
  Dio init() {
    Dio _dio = new Dio();
    _dio.interceptors.add(new ApiInterceptors());
    return _dio;
  }
}

class ApiInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers["Authorization"] = "Bearer " + auth_token;
    return super.onRequest(options, handler);
  }
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    APIResponseData apiResponse = APIResponseData.fromJson(response.data);
    if(!apiResponse.isAuthenticated){
      // API token validation failed. Force Logout.
      prefs.clear();
      storage.deleteAll();
      ScaffoldMessenger.of(navigatorKey.currentState!.context).showSnackBar(
        SnackBar(content: Text("Session expired. Please login again")),
      );
      navigatorKey.currentState!.pushNamed('/Login');
    }
    else{
      return super.onResponse(response, handler);
    }
  }
}

class EndPointProvider{
  Dio _client;
  EndPointProvider(this._client);

  Future<APIResponseData> fetchNews() async{
    final response = await _client.get('https://connect.bcplindia.co.in/MobileAppAPI/News_Events');

    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);
    } else {
      print("The error message is: ${response.data}");
      throw Exception('Data transfer error');
    }
  }

  // Future<List<NewsContent>> fetchContent() async{
  //   final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/News_Events');
  //
  //   if (response.statusCode == 200) {
  //     List jsonResponse = response.data;
  //     return jsonResponse.map((newscontent) => new NewsContent.fromJson(newscontent)).toList();
  //   } else {
  //     print("The error message is: ${response.data}");
  //     throw Exception('Failed to authenticate.');
  //   }
  // }
  Future<APIResponseData> fetchContentAttachments(int contentId, String contentType) async{
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/ContentAttachments',
        data: {'contentId': contentId, 'contentType': contentType});

    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);

    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to retrieve data.');
    }
  }
  Future<APIResponseData> fetchEmployees(String empName, String empUnit, String empDiscp, String empBloodGrp) async{
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/EmployeeList',
      data: {'name': empName, 'unit': empUnit,'discipline': empDiscp, 'bloodGr': empBloodGrp});

    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);
    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to retrieve data.');
    }
  }
  Future<APIResponseData> fetchLeaveQuota(String empno) async{
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/GetLeaveQuota',
        data: {'empno': empno});

    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);
    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to retrieve data.');
    }
  }
  Future<APIResponseData> fetchDocuments(String docName, String docType) async{
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/DocumentList',
      data: {'docName': docName,'docType': docType,});

    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);
    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to retrieve data.');
    }
  }
  Future<APIResponseData> fetchHolidayList() async{
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/GetHolidayList');
    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);
    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to retrieve data.');
    }
  }
  Future<APIResponseData> fetchShiftRosterData(String empno, String fromDate, String toDate) async{
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/ShiftRosterData',
        data: {'empno': empno, 'fromDate': fromDate, 'toDate': toDate});

    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);
    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to retrieve data.');
    }
  }
  Future<APIResponseData> fetchAttendanceData(String empno, String fromDate, String toDate) async{
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/BiometricPunchData',
        data: {'empno': empno, 'fromDate': fromDate, 'toDate': toDate});

    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);
    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to retrieve data.');
    }
  }
  Future<APIResponseData> fetchPayrollData(String empno, String month, String year) async{
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/GetPayrollResult',
        data: {'empno': empno, 'month': month, 'year': year});

    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);

    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to retrieve data.');
    }
  }
  Future<APIResponseData> fetchClaimsData(String empno, String claimType, String fromDate, String toDate) async{
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/GetClaimDetails',
        data: {'empno': empno, 'claimType': claimType, 'fromDate': fromDate, 'toDate': toDate});

    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);

    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to retrieve data.');
    }
  }
  Future<APIResponseData> postAttendRegulRequest(String empno, String inTime, String outTime, String reason) async{
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/AttendanceRegularisationRequest',
        data: {'empno': empno, 'inTime': inTime, 'outTime': outTime, 'reason': reason});

    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);

    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to post data.');
    }
  }
  Future<APIResponseData> fetchITACMasterData() async{
    final response = await _client.get('https://connect.bcplindia.co.in/MobileAppAPI/ITACMaster');

    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);

    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to retrieve data.');
    }
  }
  Future<APIResponseData> postITACRequest(var formDataMap) async{
    FormData formData = FormData.fromMap(formDataMap);
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/ITACRequest',
        data: formData);

    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);

    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to post data.');
    }
  }
  Future<APIResponseData> fetchHosCrLtrMasterData() async{
    final response = await _client.get('https://connect.bcplindia.co.in/MobileAppAPI/getHospCrLetterMaster');

    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);

    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to retrieve data.');
    }
  }
  Future<APIResponseData> postHosCrLtrRequest(String empno, var formDataMap) async{
    FormData formData = FormData.fromMap(formDataMap);
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/HospCreditLetter',
        data: formData);
    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);
    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to post data.');
    }
  }
  Future<APIResponseData> postECOFFOTRequest(var formDataMap) async{
    FormData formData = FormData.fromMap(formDataMap);
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/EcoffOTRequest',
        data: formData);
    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);
    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to post data.');
    }
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







