import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../account.dart';
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
      Hive.close();
      Hive.deleteFromDisk();
      ScaffoldMessenger.of(navigatorKey.currentState!.context).showSnackBar(
        SnackBar(content: Text("Session expired. Please login again")),
      );
      //navigatorKey.currentState!.pushNamed('/Login');
      //remove route from multiple back button
      navigatorKey.currentState!.pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => Login()), (Route<dynamic> route) => false);
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
  Future<APIResponseData> fetchQuizes() async{
    final response = await _client.get('https://connect.bcplindia.co.in/MobileAppAPI/GetQuizes');

    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);
    } else {
      print("The error message is: ${response.data}");
      throw Exception('Data transfer error');
    }
  }
  Future<APIResponseData> startQuiz(String quizID) async{
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/StartQuiz',
        data: {'quizID': quizID});

    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);
    } else {
      print("The error message is: ${response.data}");
      throw Exception('Data transfer error');
    }
  }
  Future<APIResponseData> postQuizResponse(var quizData) async{
    String data = jsonEncode(quizData);
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/SaveQuizResponse',
      options: Options(headers: {
        HttpHeaders.contentTypeHeader: "application/json; charset=UTF-8",
      }),
      data: data,);

    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);

    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to post data.');
    }
  }
  Future<APIResponseData> fetchSingleContent(String contentID, String contentType) async{
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/NewsByID',
        data: {'id': contentID, 'type': contentType});

    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);
    } else {
      print("The error message is: ${response.data}");
      throw Exception('Data transfer error');
    }
  }
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
  Future<APIResponseData> fetchLeaveQuota() async{
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/GetLeaveQuota');

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
  Future<APIResponseData> fetchShiftRosterData(String fromDate, String toDate) async{
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/ShiftRosterData',
        data: {'fromDate': fromDate, 'toDate': toDate});

    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);
    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to retrieve data.');
    }
  }
  Future<APIResponseData> fetchAttendanceData(String fromDate, String toDate) async{
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/BiometricPunchData',
        data: {'fromDate': fromDate, 'toDate': toDate});

    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);
    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to retrieve data.');
    }
  }
  Future<APIResponseData> fetchPayrollData(String month, String year) async{
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/GetPayrollResult',
        data: {'month': month, 'year': year});

    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);

    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to retrieve data.');
    }
  }
  Future<APIResponseData> fetchClaimsData(String claimType, String fromDate, String toDate) async{
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/GetClaimDetails',
        data: {'claimType': claimType, 'fromDate': fromDate, 'toDate': toDate});

    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);

    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to retrieve data.');
    }
  }
  Future<APIResponseData> postAttendRegulRequest(String inTime, String outTime, String reason) async{
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/AttendanceRegularisationRequest',
        data: {'inTime': inTime, 'outTime': outTime, 'reason': reason});

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
  Future<APIResponseData> fetchUserProfile() async{
    final response = await _client.get('https://connect.bcplindia.co.in/MobileAppAPI/UserProfile');

    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);

    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to retrieve data.');
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
  Future<APIResponseData> postHosCrLtrRequest(var formDataMap) async{
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
  Future<APIResponseData> postFeedback(String feedback, String platform, String appVersion, String buildNumber) async{
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/Feedback',
        data: {'feedback': feedback, 'platform': platform, 'appVersion': appVersion, 'buildNumber': buildNumber});

    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);

    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to retrieve data.');
    }
  }
  Future<APIResponseData> postAddCertRequest(var formDataMap) async{
    FormData formData = FormData.fromMap(formDataMap);
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/DishaAddCert',
        data: formData);
    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);
    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to post data.');
    }
  }
  Future<APIResponseData> postAddChangeRequest(var formDataMap) async{
    FormData formData = FormData.fromMap(formDataMap);
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/DishaAddChange',
        data: formData);
    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);
    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to post data.');
    }
  }
  Future<APIResponseData> postOutEmpRequest(var formDataMap) async{
    FormData formData = FormData.fromMap(formDataMap);
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/DishaOutEmployment',
        data: formData);
    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);
    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to post data.');
    }
  }
  Future<APIResponseData> postMedBenefitRequest(var formDataMap) async{
    FormData formData = FormData.fromMap(formDataMap);
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/DishaMedBenefit',
        data: formData);
    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);
    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to post data.');
    }
  }
  Future<APIResponseData> postHighEduRequest(var formDataMap) async{
    FormData formData = FormData.fromMap(formDataMap);
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/DishaHighEdu',
        data: formData);
    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);
    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to post data.');
    }
  }
  Future<APIResponseData> postCLARequest(var formDataMap) async{
    FormData formData = FormData.fromMap(formDataMap);
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/DishaCLAReq',
        data: formData);
    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);
    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to post data.');
    }
  }
  Future<APIResponseData> postHRARequest(var formDataMap) async{
    FormData formData = FormData.fromMap(formDataMap);
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/DishaHRAReq',
        data: formData);
    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);
    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to post data.');
    }
  }
  Future<APIResponseData> postQtrAllocRequest(var formDataMap) async{
    FormData formData = FormData.fromMap(formDataMap);
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/DishaQtrAlloc',
        data: formData);
    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);
    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to post data.');
    }
  }
  Future<APIResponseData> checkUpdate(String currentAppVersion, String currentAppBuildNumber) async{
    final response = await _client.post('https://connect.bcplindia.co.in/MobileAppAPI/checkAppUpdate',
        data: {'currentAppVersion': currentAppVersion, 'currentAppBuildNumber': currentAppBuildNumber});

    if (response.statusCode == 200) {
      return APIResponseData.fromJson(response.data);

    } else {
      print("The error message is: ${response.data}");
      throw Exception('Failed to retrieve data.');
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







