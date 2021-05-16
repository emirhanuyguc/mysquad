import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Task {
  final String id;
  final String companyId;
  final String employeeId;
  final String employeeName;
  final String title;
  final String description;
  final DateTime taskDate;
  final TimeOfDay taskHour;
  bool isCompleted;

  Task(
      {@required this.id,
      @required this.companyId,
      @required this.employeeId,
      @required this.employeeName,
      @required this.title,
      @required this.description,
      @required this.taskDate,
      @required this.taskHour,
      @required this.isCompleted});
}
