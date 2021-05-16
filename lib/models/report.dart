import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ReportLocation {
  final double latitude;
  final double longitude;
  final String address;

  const ReportLocation({
    @required this.latitude,
    @required this.longitude,
    @required this.address,
  });
}

class Report {
  final String companyId;
  final String employeeId;
  final String employeeName;
  final String taskId;
  final String reportDescription;
  final String reportImageUrl;
  final ReportLocation location;
  final DateTime reportDate;
  final TimeOfDay reportHour;

  Report(
      {@required this.companyId,
      @required this.employeeId,
      @required this.employeeName,
      @required this.taskId,
      @required this.reportDescription,
      @required this.reportImageUrl,
      @required this.location,
      @required this.reportDate,
      @required this.reportHour});
}
