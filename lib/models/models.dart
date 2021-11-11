
import 'dart:convert';
import 'package:hive/hive.dart';
part 'models.g.dart';

class APIResponseData{
  final bool isAuthenticated;
  final bool status;
  final String? data;
  final String? error_code;
  final String? error_details;

  APIResponseData({required this.isAuthenticated, required this.status, required this.data,
    required this.error_code,required this.error_details});

  factory APIResponseData.fromJson(Map<String, dynamic> json) {
    return APIResponseData(
      isAuthenticated: json['isAuthenticated'],
      status: json['status'],
      data: json['data'],
      error_code: json['error_code'],
      error_details: json['error_details'],
    );
  }
}
class EmployeeLoginData{
  final bool status;
  final String? emp_no;
  final String? emp_name;
  final String? emp_desg;
  final String? emp_disc;
  final String? emp_grade;
  final String? auth_jwt;

  EmployeeLoginData({required this.status, this.emp_no,  this.emp_name,  this.emp_desg,  this.emp_disc,this.emp_grade, this.auth_jwt});
  factory EmployeeLoginData.fromJson(Map<String, dynamic> json) {
    return EmployeeLoginData(
      status: json['status'],
      emp_no: json['emp_no'],
      emp_name: json['emp_name'],
      emp_desg: json['emp_desg'],
      emp_disc: json['emp_discipline'],
      emp_grade: json['emp_grade'],
      auth_jwt: json['auth_token'],
    );
  }
}
@HiveType(typeId: 5)
class NewsContent extends HiveObject {
  @HiveField(0)
  final int contentId;
  @HiveField(1)
  final String contentType;
  @HiveField(2)
  final String contentTitle;
  @HiveField(3)
  final String contentDescription;
  @HiveField(4)
  final String creationDate;
  //final List<NewsAttachment> attachments;

  NewsContent({required this.contentId, required this.contentType, required this.contentTitle,
    required this.contentDescription,required this.creationDate});

  factory NewsContent.fromJson(Map<String, dynamic> json) {
    return NewsContent(
      contentId: json['ContentID'],
      contentType: json['contentType'],
      contentTitle: json['title'],
      contentDescription: json['description'],
      creationDate: json['creationDate'],
      //attachments: json['attachments'],
    );
  }
}
class NewsContentWithAttachment{
  final int contentId;
  final String contentType;
  final String contentTitle;
  final String contentDescription;
  final String creationDate;
  final List<NewsAttachment> attachments;

  NewsContentWithAttachment({required this.contentId, required this.contentType, required this.contentTitle,
    required this.contentDescription,required this.creationDate,required this.attachments});

  factory NewsContentWithAttachment.fromJson(Map<String, dynamic> json) {
    return NewsContentWithAttachment(
      contentId: json['ContentID'],
      contentType: json['contentType'],
      contentTitle: json['title'],
      contentDescription: json['description'],
      creationDate: json['creationDate'],
      attachments: (json['attachments'] as List).map((e) => NewsAttachment.fromJson(e)).toList(),
    );
  }
}
class NewsAttachment {
  final int attachmentID ;
  final String attachmentFileName ;
  final String attachmentFileType ;
  final String attachmentFilePath ;

  NewsAttachment({required this.attachmentID, required this.attachmentFileName, required this.attachmentFileType,
    required this.attachmentFilePath});

  factory NewsAttachment.fromJson(Map<String, dynamic> json) {
    return NewsAttachment(
      attachmentID: json['attachmentID'],
      attachmentFileName: json['attachmentFileName'],
      attachmentFileType: json['attachmentFileType'],
      attachmentFilePath: json['attachmentFilePath'],
    );
  }
}
@HiveType(typeId: 0)
class Employee extends HiveObject {
  @HiveField(0)
  final bool status;
  @HiveField(1)
  final String? emp_no;
  @HiveField(2)
  final String? emp_name;
  @HiveField(3)
  final String? emp_desg;
  @HiveField(4)
  final String? emp_grade;
  @HiveField(5)
  final String? emp_dept;
  @HiveField(6)
  final String? emp_discipline;
  @HiveField(7)
  final String? emp_location;
  @HiveField(8)
  final String? emp_unit;
  @HiveField(9)
  final String? emp_email;
  @HiveField(10)
  final String? emp_mobileNo;
  @HiveField(11)
  final String? emp_intercom;
  @HiveField(12)
  final String? emp_intercomResidence;
  @HiveField(13)
  final String? emp_company;
  @HiveField(14)
  final String? emp_DOB;
  @HiveField(15)
  final String? emp_gender;
  @HiveField(16)
  final String? emp_bloodgroup;
  @HiveField(17)
  final String? emp_DOJ;

  Employee({required this.status,required this.emp_no, required this.emp_name, required this.emp_desg, required this.emp_grade,
            required this.emp_dept,required this.emp_discipline,required this.emp_location,
    required this.emp_unit,required this.emp_email,required this.emp_mobileNo,
  required this.emp_intercom,required this.emp_intercomResidence,required this.emp_company,
  required this.emp_DOB,required this.emp_gender,required this.emp_bloodgroup,required this.emp_DOJ});

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      status: json['status'],
      emp_no: json['emp_no'],
      emp_name: json['emp_name'],
      emp_desg: json['emp_desg'],
      emp_grade: json['emp_grade'],
      emp_dept: json['emp_dept'],
      emp_discipline: json['emp_discipline'],
      emp_location: json['emp_location'],
      emp_unit: json['emp_unit'],
      emp_email: json['emp_email'],
      emp_mobileNo: json['emp_mobileNo'],
      emp_intercom: json['emp_intercom'],
      emp_intercomResidence: json['emp_intercomResidence'],
      emp_company: json['emp_company'],
      emp_DOB: json['emp_DOB'],
      emp_gender: json['emp_gender'],
      emp_bloodgroup: json['emp_bloodgroup'],
      emp_DOJ: json['emp_DOJ'],
    );
  }
}
@HiveType(typeId: 1)
class LeaveQuota extends HiveObject{
  @HiveField(0)
  final String Pernr;
  @HiveField(1)
  final String QuotaCL;
  @HiveField(2)
  final String QuotaEL;
  @HiveField(3)
  final String QuotaHPL;
  @HiveField(4)
  final String QuotaRH;
  @HiveField(5)
  final String QuotaCOFF;

  LeaveQuota({required this.Pernr,required this.QuotaCL, required this.QuotaEL, required this.QuotaHPL,
    required this.QuotaRH,required this.QuotaCOFF});

  factory LeaveQuota.fromJson(Map<String, dynamic> json) {
    return LeaveQuota(
      Pernr: json['Pernr'],
      QuotaCL: json['QuotaCL'],
      QuotaEL: json['QuotaEL'],
      QuotaHPL: json['QuotaHPL'],
      QuotaRH: json['QuotaRH'],
      QuotaCOFF: json['QuotaCOFF'],
    );
  }
}
@HiveType(typeId: 2)
class Document extends HiveObject{
  @HiveField(0)
  final String docId;
  @HiveField(1)
  final String docType;
  @HiveField(2)
  final String docFileName;
  @HiveField(3)
  final String docDisplayName;
  @HiveField(4)
  final String docPath;
  @HiveField(5)
  final String docContentType;
  @HiveField(6)
  final String docSize;
  @HiveField(7)
  final String docDate;

  Document({required this.docId,required this.docType, required this.docFileName, required this.docDisplayName,
    required this.docPath,required this.docContentType,required this.docSize,required this.docDate});

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      docId: json['docId'],
      docType: json['docType'],
      docFileName: json['docFileName'],
      docDisplayName: json['docDisplayName'],
      docPath: json['docPath'],
      docContentType: json['docContentType'],
      docSize: json['docSize'],
      docDate: json['docDate'],
    );
  }
}
@HiveType(typeId: 3)
class HolidayList extends HiveObject{
  @HiveField(0)
  final String holidayDate;
  @HiveField(1)
  final String holidayName;
  @HiveField(2)
  final String holidayType;

  HolidayList({required this.holidayDate,required this.holidayName, required this.holidayType});

  factory HolidayList.fromJson(Map<String, dynamic> json) {
    return HolidayList(
      holidayDate: json['HolidayDate'],
      holidayName: json['HolidayName'],
      holidayType: json['HolidayType'],
    );
  }
}
class ShiftRoster{
  final String date;
  final String shift;
  final bool approved;

  ShiftRoster({required this.date,required this.shift, required this.approved});

  factory ShiftRoster.fromJson(Map<String, dynamic> json) {
    return ShiftRoster(
      date: json['date'],
      shift: json['shift'],
      approved: json['approved'],
    );
  }
}
class AttendanceData{
  final String date;
  final String punchDate;
  final String punchTime;
  final String deviceName;

  AttendanceData({required this.date,required this.punchDate, required this.punchTime, required this.deviceName});

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      date: json['date'],
      punchDate: json['punchDate'],
      punchTime: json['punchTime'],
      deviceName: json['deviceName'],
    );
  }
}
class PayrollData{
  final String Pernr;
  final String Month;
  final String Year;
  final String WageType;
  final String WageTypeText;
  final String WageTypeType;
  final String WageTypeAmount;

  PayrollData({required this.Pernr,required this.Month, required this.Year, required this.WageType,
    required this.WageTypeText,required this.WageTypeType,required this.WageTypeAmount});

  factory PayrollData.fromJson(Map<String, dynamic> json) {
    return PayrollData(
      Pernr: json['Pernr'],
      Month: json['Month'],
      Year: json['Year'],
      WageType: json['WageType'],
      WageTypeText: json['WageTypeText'],
      WageTypeType: json['WageTypeType'],
      WageTypeAmount: json['WageTypeAmount'],
    );
  }
}
class ClaimData{
  final String Begda;
  final String Pernr;
  final String ClaimType;
  final String Endda;
  final String CreationDt;
  final String SubmitDt;
  final String Period;
  final String DocNo;
  final String ClaimStatus;
  final String ProcessDt;
  final String ClaimAmt;
  final String AprrovedAmt;
  final String PaymentDate;
  final String Remarks;

  ClaimData({required this.Begda,required this.Pernr ,required this.ClaimType ,required this.Endda ,required this.CreationDt
  ,required this.SubmitDt ,required this.Period ,required this.DocNo ,required this.ClaimStatus ,required this.ProcessDt ,required this.ClaimAmt
  ,required this.AprrovedAmt ,required this.PaymentDate ,required this.Remarks});

  factory ClaimData.fromJson(Map<String, dynamic> json) {
    return ClaimData(
      Begda   : json['Begda'],
      Pernr : json['Pernr'],
      ClaimType  : json['ClaimType'],
      Endda   : json['Endda'],
      CreationDt  : json['CreationDt'],
      SubmitDt  : json['SubmitDt'],
      Period    : json['Period'],
      DocNo  : json['DocNo'],
      ClaimStatus   : json['ClaimStatus'],
      ProcessDt   : json['ProcessDt'],
      ClaimAmt   : json['ClaimAmt'],
      AprrovedAmt   : json['AprrovedAmt'],
      PaymentDate   : json['PaymentDate'],
      Remarks  : json['Remarks'],
    );
  }
}
@HiveType(typeId: 4)
class ITACMasterData extends HiveObject{
  @HiveField(0)
  final List<String> data1;
  @HiveField(1)
  final List<String> data2;

  ITACMasterData({required this.data1, required this.data2});

  factory ITACMasterData.fromJson(Map<String, dynamic> json) {
    return ITACMasterData(
      data1: (json['data1'] as List).map((e) => e as String).toList(),
      data2: (json['data2'] as List).map((e) => e as String).toList(),
    );
  }
}
@HiveType(typeId: 6)
class HospCrLtrMasterData extends HiveObject{
  @HiveField(0)
  final List<HospCrLtrHospitalMasterData> hospitals;
  @HiveField(1)
  final List<HospCrLtrEmpDepMasterData> patient;

  HospCrLtrMasterData({required this.hospitals, required this.patient});

  factory HospCrLtrMasterData.fromJson(Map<String, dynamic> json) {

    return HospCrLtrMasterData(
      hospitals: (json['hospitals'] as List).map((e) => HospCrLtrHospitalMasterData.fromJson(e)).toList(),
      patient: (json['patient'] as List).map((e) => HospCrLtrEmpDepMasterData.fromJson(e)).toList(),
    );
  }
}
class HospCrLtrEmpDepMasterData{
  final String patientName;
  final String relationWithEmp;

  HospCrLtrEmpDepMasterData({required this.patientName, required this.relationWithEmp});

  factory HospCrLtrEmpDepMasterData.fromJson(Map<String, dynamic> json) {
    return HospCrLtrEmpDepMasterData(
      patientName   : json['patientName'],
      relationWithEmp   : json['relationWithEmp'],
    );
  }
  Map<String, dynamic> toJson() =>
      {
        'patientName': patientName,
        'relationWithEmp': relationWithEmp,
      };
}
class HospCrLtrHospitalMasterData{
  final int hospitalId;
  final String hospitalName;
  final String hospitalCity;
  final String hospitalState;
  final String hospitalAddress;

  HospCrLtrHospitalMasterData({required this.hospitalId, required this.hospitalName, required this.hospitalCity, required this.hospitalState, required this.hospitalAddress});

  factory HospCrLtrHospitalMasterData.fromJson(Map<String, dynamic> json) {
    return HospCrLtrHospitalMasterData(
      hospitalId   : json['hospitalId'],
      hospitalName   : json['hospitalName'],
      hospitalCity   : json['hospitalCity'],
      hospitalState   : json['hospitalState'],
      hospitalAddress   : json['hospitalAddress'],
    );
  }
  Map<String, dynamic> toJson() =>
      {
        'hospitalId': hospitalId,
        'hospitalName': hospitalName,
        'hospitalCity': hospitalCity,
        'hospitalState': hospitalState,
        'hospitalAddress': hospitalAddress,
      };
}
class AppUpdateInfo{
  final String version;
  final String buildNumber;
  final String fileName;
  final String filePath;

  AppUpdateInfo({required this.version,required this.buildNumber,required this.fileName,required this.filePath});

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      version: json['version'],
      buildNumber: json['buildNumber'],
      fileName: json['fileName'],
      filePath: json['filePath'],
    );
  }
}
@HiveType(typeId: 7)
class AppNotification extends HiveObject{
  @HiveField(0)
  final String notificationTitle;
  @HiveField(1)
  final String notificationBody;
  @HiveField(2)
  final String contentType;
  @HiveField(3)
  final String contentID;

  AppNotification({required this.notificationTitle,required this.notificationBody,
    required this.contentType,required this.contentID});

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      notificationTitle: json['notificationTitle'],
      notificationBody: json['notificationBody'],
      contentType: json['contentType'],
      contentID: json['contentID'],
    );
  }
  static Map<String, dynamic> toMap(AppNotification not) => {
    'notificationTitle': not.notificationTitle,
    'notificationBody': not.notificationBody,
    'contentType': not.contentType,
    'contentID': not.contentID,
  };
  static String encode(List<AppNotification> notifications) => json.encode(
    notifications
        .map<Map<String, dynamic>>((data) => AppNotification.toMap(data))
        .toList(),
  );
  static List<AppNotification> decode(String notifications) =>
      (json.decode(notifications) as List<dynamic>)
          .map<AppNotification>((item) => AppNotification.fromJson(item))
          .toList();
}
class QuizData{
  final int QuizID;
  final String title;
  final String StartTime;
  final String EndTime;
  final int timeDuration;
  final int noOfQns;
  final List<QuestionData> Questions ;

  QuizData({required this.QuizID, required this.title, required this.StartTime,
    required this.EndTime,required this.timeDuration,required this.noOfQns,required this.Questions});

  factory QuizData.fromJson(Map<String, dynamic> json) {
    return QuizData(
      QuizID: json['QuizID'],
      title: json['title'],
      StartTime: json['StartTime'],
      EndTime: json['EndTime'],
      timeDuration: json['timeDuration'],
      noOfQns: json['noOfQns'],
      Questions: (json['Questions'] as List).map((e) => QuestionData.fromJson(e)).toList(),
    );
  }
}
class QuestionData{
  final int QuestionId;
  final String QuestionText;
  int AnswerId;
  final List<AnswerChoiceData> AnswerChoices;

QuestionData({required this.QuestionId, required this.QuestionText, required this.AnswerId,
    required this.AnswerChoices});

  factory QuestionData.fromJson(Map<String, dynamic> json) {
    return QuestionData(
      QuestionId: json['QuestionId'],
      QuestionText: json['QuestionText'],
      AnswerId: json['AnswerId'],
      AnswerChoices: (json['AnswerChoices'] as List).map((e) => AnswerChoiceData.fromJson(e)).toList(),
    );
  }
}
class AnswerChoiceData{
  final int AnswerChoiceID ;
  final int choiceNo ;
  final String AnswerText ;

  AnswerChoiceData({required this.AnswerChoiceID, required this.choiceNo, required this.AnswerText});

  factory AnswerChoiceData.fromJson(Map<String, dynamic> json) {
    return AnswerChoiceData(
      AnswerChoiceID: json['AnswerChoiceID'],
      choiceNo: json['choiceNo'],
      AnswerText: json['AnswerText'],
    );
  }
}
class QuizRespnse{
  final int QuizID;
  final DateTime QuizStartTime;
  final DateTime QuizEndTime;
  final List<QuestionAnswer> answer;

  QuizRespnse({required this.QuizID, required this.QuizStartTime, required this.QuizEndTime,
    required this.answer});

  factory QuizRespnse.fromJson(Map<String, dynamic> json) {
    return QuizRespnse(
      QuizID: json['QuizID'],
      QuizStartTime: json['QuizStartTime'],
      QuizEndTime: json['QuizEndTime'],
      answer: (json['QuestionAnswer'] as List).map((e) => QuestionAnswer.fromJson(e)).toList(),
    );
  }
  Map<String, dynamic> toJson() =>
      {
        'QuizID': QuizID,
        'QuizStartTime': QuizStartTime,
        'QuizEndTime': QuizEndTime,
        'answer': answer,
      };
}
class QuestionAnswer{
  int QuestionId;
  int AnswerId;

  QuestionAnswer({required this.QuestionId,required this.AnswerId});

  factory QuestionAnswer.fromJson(Map<String, dynamic> json) {
    return QuestionAnswer(
      QuestionId: json['QuestionId'],
      AnswerId: json['AnswerId'],
    );
  }
}



