// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NewsContentAdapter extends TypeAdapter<NewsContent> {
  @override
  final int typeId = 5;

  @override
  NewsContent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NewsContent(
      contentId: fields[0] as int,
      contentType: fields[1] as String,
      contentTitle: fields[2] as String,
      contentDescription: fields[3] as String,
      creationDate: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NewsContent obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.contentId)
      ..writeByte(1)
      ..write(obj.contentType)
      ..writeByte(2)
      ..write(obj.contentTitle)
      ..writeByte(3)
      ..write(obj.contentDescription)
      ..writeByte(4)
      ..write(obj.creationDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewsContentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EmployeeAdapter extends TypeAdapter<Employee> {
  @override
  final int typeId = 0;

  @override
  Employee read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Employee(
      status: fields[0] as bool,
      emp_no: fields[1] as String?,
      emp_name: fields[2] as String?,
      emp_desg: fields[3] as String?,
      emp_grade: fields[4] as String?,
      emp_dept: fields[5] as String?,
      emp_discipline: fields[6] as String?,
      emp_location: fields[7] as String?,
      emp_unit: fields[8] as String?,
      emp_email: fields[9] as String?,
      emp_mobileNo: fields[10] as String?,
      emp_intercom: fields[11] as String?,
      emp_intercomResidence: fields[12] as String?,
      emp_company: fields[13] as String?,
      emp_DOB: fields[14] as String?,
      emp_gender: fields[15] as String?,
      emp_bloodgroup: fields[16] as String?,
      emp_DOJ: fields[17] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Employee obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.status)
      ..writeByte(1)
      ..write(obj.emp_no)
      ..writeByte(2)
      ..write(obj.emp_name)
      ..writeByte(3)
      ..write(obj.emp_desg)
      ..writeByte(4)
      ..write(obj.emp_grade)
      ..writeByte(5)
      ..write(obj.emp_dept)
      ..writeByte(6)
      ..write(obj.emp_discipline)
      ..writeByte(7)
      ..write(obj.emp_location)
      ..writeByte(8)
      ..write(obj.emp_unit)
      ..writeByte(9)
      ..write(obj.emp_email)
      ..writeByte(10)
      ..write(obj.emp_mobileNo)
      ..writeByte(11)
      ..write(obj.emp_intercom)
      ..writeByte(12)
      ..write(obj.emp_intercomResidence)
      ..writeByte(13)
      ..write(obj.emp_company)
      ..writeByte(14)
      ..write(obj.emp_DOB)
      ..writeByte(15)
      ..write(obj.emp_gender)
      ..writeByte(16)
      ..write(obj.emp_bloodgroup)
      ..writeByte(17)
      ..write(obj.emp_DOJ);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LeaveQuotaAdapter extends TypeAdapter<LeaveQuota> {
  @override
  final int typeId = 1;

  @override
  LeaveQuota read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LeaveQuota(
      Pernr: fields[0] as String,
      QuotaCL: fields[1] as String,
      QuotaEL: fields[2] as String,
      QuotaHPL: fields[3] as String,
      QuotaRH: fields[4] as String,
      QuotaCOFF: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LeaveQuota obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.Pernr)
      ..writeByte(1)
      ..write(obj.QuotaCL)
      ..writeByte(2)
      ..write(obj.QuotaEL)
      ..writeByte(3)
      ..write(obj.QuotaHPL)
      ..writeByte(4)
      ..write(obj.QuotaRH)
      ..writeByte(5)
      ..write(obj.QuotaCOFF);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaveQuotaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DocumentAdapter extends TypeAdapter<Document> {
  @override
  final int typeId = 2;

  @override
  Document read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Document(
      docId: fields[0] as String,
      docType: fields[1] as String,
      docFileName: fields[2] as String,
      docDisplayName: fields[3] as String,
      docPath: fields[4] as String,
      docContentType: fields[5] as String,
      docSize: fields[6] as String,
      docDate: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Document obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.docId)
      ..writeByte(1)
      ..write(obj.docType)
      ..writeByte(2)
      ..write(obj.docFileName)
      ..writeByte(3)
      ..write(obj.docDisplayName)
      ..writeByte(4)
      ..write(obj.docPath)
      ..writeByte(5)
      ..write(obj.docContentType)
      ..writeByte(6)
      ..write(obj.docSize)
      ..writeByte(7)
      ..write(obj.docDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HolidayListAdapter extends TypeAdapter<HolidayList> {
  @override
  final int typeId = 3;

  @override
  HolidayList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HolidayList(
      holidayDate: fields[0] as String,
      holidayName: fields[1] as String,
      holidayType: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HolidayList obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.holidayDate)
      ..writeByte(1)
      ..write(obj.holidayName)
      ..writeByte(2)
      ..write(obj.holidayType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HolidayListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ITACMasterDataAdapter extends TypeAdapter<ITACMasterData> {
  @override
  final int typeId = 4;

  @override
  ITACMasterData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ITACMasterData(
      data1: (fields[0] as List).cast<String>(),
      data2: (fields[1] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ITACMasterData obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.data1)
      ..writeByte(1)
      ..write(obj.data2);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ITACMasterDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HospCrLtrMasterDataAdapter extends TypeAdapter<HospCrLtrMasterData> {
  @override
  final int typeId = 6;

  @override
  HospCrLtrMasterData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HospCrLtrMasterData(
      hospitals: (fields[0] as List).cast<HospCrLtrHospitalMasterData>(),
      patient: (fields[1] as List).cast<HospCrLtrEmpDepMasterData>(),
    );
  }

  @override
  void write(BinaryWriter writer, HospCrLtrMasterData obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.hospitals)
      ..writeByte(1)
      ..write(obj.patient);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HospCrLtrMasterDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppNotificationAdapter extends TypeAdapter<AppNotification> {
  @override
  final int typeId = 7;

  @override
  AppNotification read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppNotification(
      notificationTitle: fields[0] as String,
      notificationBody: fields[1] as String,
      contentType: fields[2] as String,
      contentID: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AppNotification obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.notificationTitle)
      ..writeByte(1)
      ..write(obj.notificationBody)
      ..writeByte(2)
      ..write(obj.contentType)
      ..writeByte(3)
      ..write(obj.contentID);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppNotificationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EmpProfileDataAdapter extends TypeAdapter<EmpProfileData> {
  @override
  final int typeId = 8;

  @override
  EmpProfileData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmpProfileData(
      emp_no: fields[0] as String?,
      emp_name: fields[1] as String?,
      emp_desg: fields[2] as String?,
      emp_grade: fields[3] as String?,
      emp_dept: fields[4] as String?,
      emp_discipline: fields[5] as String?,
      emp_location: fields[6] as String?,
      emp_unit: fields[7] as String?,
      emp_email: fields[8] as String?,
      emp_mobileNo: fields[9] as String?,
      emp_intercom: fields[10] as String?,
      emp_intercomResidence: fields[11] as String?,
      emp_DOB: fields[12] as String?,
      emp_gender: fields[14] as String?,
      emp_bloodgroup: fields[15] as String?,
      emp_DOJ: fields[13] as String?,
      addressData: (fields[16] as List).cast<EmpAddressData>(),
      trainingData: (fields[17] as List).cast<EmpTrainingData>(),
      dependentData: (fields[18] as List).cast<EmpDependentData>(),
      nomineeData: (fields[19] as List).cast<EmpNomineeData>(),
    );
  }

  @override
  void write(BinaryWriter writer, EmpProfileData obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.emp_no)
      ..writeByte(1)
      ..write(obj.emp_name)
      ..writeByte(2)
      ..write(obj.emp_desg)
      ..writeByte(3)
      ..write(obj.emp_grade)
      ..writeByte(4)
      ..write(obj.emp_dept)
      ..writeByte(5)
      ..write(obj.emp_discipline)
      ..writeByte(6)
      ..write(obj.emp_location)
      ..writeByte(7)
      ..write(obj.emp_unit)
      ..writeByte(8)
      ..write(obj.emp_email)
      ..writeByte(9)
      ..write(obj.emp_mobileNo)
      ..writeByte(10)
      ..write(obj.emp_intercom)
      ..writeByte(11)
      ..write(obj.emp_intercomResidence)
      ..writeByte(12)
      ..write(obj.emp_DOB)
      ..writeByte(13)
      ..write(obj.emp_DOJ)
      ..writeByte(14)
      ..write(obj.emp_gender)
      ..writeByte(15)
      ..write(obj.emp_bloodgroup)
      ..writeByte(16)
      ..write(obj.addressData)
      ..writeByte(17)
      ..write(obj.trainingData)
      ..writeByte(18)
      ..write(obj.dependentData)
      ..writeByte(19)
      ..write(obj.nomineeData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmpProfileDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EmpAddressDataAdapter extends TypeAdapter<EmpAddressData> {
  @override
  final int typeId = 9;

  @override
  EmpAddressData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmpAddressData(
      addressTypeText: fields[0] as String,
      careof: fields[1] as String,
      street: fields[2] as String,
      addLine2: fields[3] as String,
      city: fields[4] as String,
      district: fields[5] as String,
      pin: fields[6] as String,
      state: fields[7] as String,
      country: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, EmpAddressData obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.addressTypeText)
      ..writeByte(1)
      ..write(obj.careof)
      ..writeByte(2)
      ..write(obj.street)
      ..writeByte(3)
      ..write(obj.addLine2)
      ..writeByte(4)
      ..write(obj.city)
      ..writeByte(5)
      ..write(obj.district)
      ..writeByte(6)
      ..write(obj.pin)
      ..writeByte(7)
      ..write(obj.state)
      ..writeByte(8)
      ..write(obj.country);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmpAddressDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EmpTrainingDataAdapter extends TypeAdapter<EmpTrainingData> {
  @override
  final int typeId = 10;

  @override
  EmpTrainingData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmpTrainingData(
      startDate: fields[0] as String,
      endDate: fields[1] as String,
      training_desc: fields[2] as String,
      TRAINING_NAME: fields[3] as String,
      MAN_DAYS: fields[4] as String,
      TRAINER_NAME: fields[5] as String,
      VENUE_DETAILS: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, EmpTrainingData obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.startDate)
      ..writeByte(1)
      ..write(obj.endDate)
      ..writeByte(2)
      ..write(obj.training_desc)
      ..writeByte(3)
      ..write(obj.TRAINING_NAME)
      ..writeByte(4)
      ..write(obj.MAN_DAYS)
      ..writeByte(5)
      ..write(obj.TRAINER_NAME)
      ..writeByte(6)
      ..write(obj.VENUE_DETAILS);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmpTrainingDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EmpDependentDataAdapter extends TypeAdapter<EmpDependentData> {
  @override
  final int typeId = 11;

  @override
  EmpDependentData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmpDependentData(
      dependentName: fields[0] as String,
      dependentGender: fields[1] as String,
      dependentDOB: fields[2] as String,
      dependentRelationship: fields[3] as String,
      dependentDate: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, EmpDependentData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.dependentName)
      ..writeByte(1)
      ..write(obj.dependentGender)
      ..writeByte(2)
      ..write(obj.dependentDOB)
      ..writeByte(3)
      ..write(obj.dependentRelationship)
      ..writeByte(4)
      ..write(obj.dependentDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmpDependentDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EmpNomineeDataAdapter extends TypeAdapter<EmpNomineeData> {
  @override
  final int typeId = 12;

  @override
  EmpNomineeData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmpNomineeData(
      benefitName: fields[0] as String,
      startDate: fields[1] as String,
      nomineeName: fields[2] as String,
      nomineeRelationship: fields[3] as String,
      nomineeShare: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, EmpNomineeData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.benefitName)
      ..writeByte(1)
      ..write(obj.startDate)
      ..writeByte(2)
      ..write(obj.nomineeName)
      ..writeByte(3)
      ..write(obj.nomineeRelationship)
      ..writeByte(4)
      ..write(obj.nomineeShare);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmpNomineeDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BioPunchData _$BioPunchDataFromJson(Map<String, dynamic> json) => BioPunchData(
      date: json['date'] as String,
      punchDate: json['punchDate'] as String,
      punchTime: json['punchTime'] as String,
      deviceName: json['deviceName'] as String,
    );

Map<String, dynamic> _$BioPunchDataToJson(BioPunchData instance) =>
    <String, dynamic>{
      'date': instance.date,
      'punchDate': instance.punchDate,
      'punchTime': instance.punchTime,
      'deviceName': instance.deviceName,
    };

AttendanceData _$AttendanceDataFromJson(Map<String, dynamic> json) =>
    AttendanceData(
      Pernr: json['Pernr'] as String,
      Begda: json['Begda'] as String,
      Endda: json['Endda'] as String,
      absent_count: json['absent_count'] as int,
      first_abs_count: json['first_abs_count'] as int,
      second_abs_count: json['second_abs_count'] as int,
      in_miss_count: json['in_miss_count'] as int,
      out_miss_count: json['out_miss_count'] as int,
      in_late_count: json['in_late_count'] as int,
      out_early_count: json['out_early_count'] as int,
      in_relax_count: json['in_relax_count'] as int,
      out_relax_count: json['out_relax_count'] as int,
      AttndData: (json['AttndData'] as List<dynamic>)
          .map((e) => AttendanceRecords.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AttendanceDataToJson(AttendanceData instance) =>
    <String, dynamic>{
      'Pernr': instance.Pernr,
      'Begda': instance.Begda,
      'Endda': instance.Endda,
      'absent_count': instance.absent_count,
      'first_abs_count': instance.first_abs_count,
      'second_abs_count': instance.second_abs_count,
      'in_miss_count': instance.in_miss_count,
      'out_miss_count': instance.out_miss_count,
      'in_late_count': instance.in_late_count,
      'out_early_count': instance.out_early_count,
      'in_relax_count': instance.in_relax_count,
      'out_relax_count': instance.out_relax_count,
      'AttndData': instance.AttndData,
    };

AttendanceRecords _$AttendanceRecordsFromJson(Map<String, dynamic> json) =>
    AttendanceRecords(
      Pernr: json['Pernr'] as String,
      Begda: json['Begda'] as String,
      Endda: json['Endda'] as String,
      Shift: json['Shift'] as String,
      ShiftDt: json['ShiftDt'] as String,
      Attendance: json['Attendance'] as String,
      InDate: json['InDate'] as String,
      InTime: json['InTime'] as String,
      OutDate: json['OutDate'] as String,
      OutTime: json['OutTime'] as String,
      InTimeRelax: json['InTimeRelax'] as String,
      OutTimeRelax: json['OutTimeRelax'] as String,
    );

Map<String, dynamic> _$AttendanceRecordsToJson(AttendanceRecords instance) =>
    <String, dynamic>{
      'Pernr': instance.Pernr,
      'Begda': instance.Begda,
      'Endda': instance.Endda,
      'Shift': instance.Shift,
      'ShiftDt': instance.ShiftDt,
      'Attendance': instance.Attendance,
      'InDate': instance.InDate,
      'InTime': instance.InTime,
      'OutDate': instance.OutDate,
      'OutTime': instance.OutTime,
      'InTimeRelax': instance.InTimeRelax,
      'OutTimeRelax': instance.OutTimeRelax,
    };

QuizData _$QuizDataFromJson(Map<String, dynamic> json) => QuizData(
      QuizID: json['QuizID'] as int,
      title: json['title'] as String,
      StartTime: json['StartTime'] as String,
      EndTime: json['EndTime'] as String,
      timeDuration: json['timeDuration'] as int,
      noOfQns: json['noOfQns'] as int,
      Questions: (json['Questions'] as List<dynamic>?)
          ?.map((e) => QuestionData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$QuizDataToJson(QuizData instance) => <String, dynamic>{
      'QuizID': instance.QuizID,
      'title': instance.title,
      'StartTime': instance.StartTime,
      'EndTime': instance.EndTime,
      'timeDuration': instance.timeDuration,
      'noOfQns': instance.noOfQns,
      'Questions': instance.Questions,
    };

QuestionData _$QuestionDataFromJson(Map<String, dynamic> json) => QuestionData(
      QuestionId: json['QuestionId'] as int,
      QuestionText: json['QuestionText'] as String,
      AnswerId: json['AnswerId'] as int,
      AnswerChoices: (json['AnswerChoices'] as List<dynamic>)
          .map((e) => AnswerChoiceData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$QuestionDataToJson(QuestionData instance) =>
    <String, dynamic>{
      'QuestionId': instance.QuestionId,
      'QuestionText': instance.QuestionText,
      'AnswerId': instance.AnswerId,
      'AnswerChoices': instance.AnswerChoices,
    };

AnswerChoiceData _$AnswerChoiceDataFromJson(Map<String, dynamic> json) =>
    AnswerChoiceData(
      AnswerChoiceID: json['AnswerChoiceID'] as int,
      choiceNo: json['choiceNo'] as int,
      AnswerText: json['AnswerText'] as String,
    );

Map<String, dynamic> _$AnswerChoiceDataToJson(AnswerChoiceData instance) =>
    <String, dynamic>{
      'AnswerChoiceID': instance.AnswerChoiceID,
      'choiceNo': instance.choiceNo,
      'AnswerText': instance.AnswerText,
    };
