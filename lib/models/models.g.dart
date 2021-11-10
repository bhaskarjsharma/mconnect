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
