
class NewsContent{
  final int contentId;
  final String contentType;
  final String contentTitle;
  final String contentDescription;
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

class NewsAttachment
{
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
class Employee{
  final bool status;
  final String? emp_no;
  final String? emp_name;
  final String? emp_desg;
  final String? emp_grade;
  final String? emp_dept;
  final String? emp_discipline;
  final String? emp_location;
  final String? emp_unit;
  final String? emp_email;
  final String? emp_mobileNo;
  final String? emp_intercom;
  final String? emp_intercomResidence;
  final String? emp_company;
  final String? emp_DOB;
  final String? emp_gender;
  final String? emp_bloodgroup;

  Employee({required this.status,required this.emp_no, required this.emp_name, required this.emp_desg, required this.emp_grade,
            required this.emp_dept,required this.emp_discipline,required this.emp_location,
    required this.emp_unit,required this.emp_email,required this.emp_mobileNo,
  required this.emp_intercom,required this.emp_intercomResidence,required this.emp_company,
  required this.emp_DOB,required this.emp_gender,required this.emp_bloodgroup});

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
    );
  }
}
class LeaveQuota{
  final String Pernr;
  final String QuotaCL;
  final String QuotaEL;
  final String QuotaHPL;
  final String QuotaRH;
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

class Document{
  final String docId;
  final String docType;
  final String docFileName;
  final String docDisplayName;
  final String docPath;
  final String docContentType;
  final String docSize;
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
class HolidayList{
  final String holidayDate;
  final String holidayName;
  final String holidayType;

  HolidayList({required this.holidayDate,required this.holidayName, required this.holidayType});

  factory HolidayList.fromJson(Map<String, dynamic> json) {
    return HolidayList(
      holidayDate: json['holidayDate'],
      holidayName: json['holidayName'],
      holidayType: json['holidayType'],
    );
  }
}


