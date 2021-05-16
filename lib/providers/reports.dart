import 'dart:convert';
import 'dart:io';
import 'package:flutter_complete_guide/helpers/location_helper.dart';
import 'package:flutter_complete_guide/models/task.dart' as EmployeeTask;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

import '../models/report.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Reports with ChangeNotifier {
  List<Report> _reports = [];
  EmployeeTask.Task _selectedTask;
  LocationHelper _locationHelper;

  List<Report> get reports {
    return [..._reports];
  }

  Report findByTaskId(String taskId) {
    debugPrint(_reports.toString());
    return _reports.firstWhere((report) => report.taskId == taskId);
  }

  Future<void> setTask(EmployeeTask.Task selectedTask) async {
    _selectedTask = selectedTask;
  }

  // var _showFavoritesOnly = false;
  final dateFormat = new DateFormat("yyyy-MM-dd");
  final timeFormat = new DateFormat("HH:mm");

  // bu employee'ye ait raporlar fetch edilecek
  // bunun bir de company'e ait hali olacak !!!
  Future<void> fetchAndSetEmployeeReports() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = json.decode(prefs.getString('userData'));
    final token = userData['token'];
    final employeeId = userData['userId'];

    final filterString = 'orderBy="employeeId"&equalTo="$employeeId"';
    var url =
        'https://mysquad-1ab28-default-rtdb.firebaseio.com/reports.json?auth=$token&$filterString';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }

      debugPrint(extractedData.toString());
      final List<Report> loadedReports = [];
      extractedData.forEach((firebaseId, reportData) {
        if (reportData['employeeId'] == employeeId) {
          loadedReports.add(Report(
            companyId: reportData['companyId'],
            employeeId: reportData['employeeId'],
            employeeName: reportData['employeeName'],
            taskId: reportData['taskId'],
            reportDate: DateTime.parse(reportData['reportDate']),
            reportDescription: reportData['reportDescription'],
            reportHour: TimeOfDay(
                hour: int.parse(reportData['reportHour'].split(":")[0]),
                minute: int.parse(reportData['reportHour'].split(":")[1])),
            reportImageUrl: reportData['reportImageUrl'],
            location: new ReportLocation(
                latitude: reportData['reportLat'],
                longitude: reportData['reportLong'],
                address: reportData['reportAdress']),
          ));
        }
      });
      debugPrint(loadedReports.toString());
      _reports = loadedReports;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> sendReport(
    String description,
    File pickedImage,
    ReportLocation pickedLocation,
  ) async {
    debugPrint(description);
    debugPrint(_selectedTask.id);
    final prefs = await SharedPreferences.getInstance();
    final userData = json.decode(prefs.getString('userData'));
    final token = userData['token'];
    final userId = userData['userId'];
    var nowDate = DateTime.now();
    var nowHour = TimeOfDay.now();
    final _reportDate = dateFormat.format(nowDate);
    final _reportHour = (nowHour.hour + 3).toString() +
        ':' +
        nowHour.minute.toString().padLeft(2, '0');
    final reportAdress = await LocationHelper.getPlaceAddress(
        pickedLocation.latitude, pickedLocation.longitude);
    debugPrint(reportAdress);
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('company_logo')
          .child(_selectedTask.id);

      await ref.putFile(pickedImage);

      final imageUrl = await ref.getDownloadURL();
      final databaseUrl =
          'https://mysquad-1ab28-default-rtdb.firebaseio.com/reports.json?auth=$token';

      final response = await http.post(
        Uri.parse(databaseUrl),
        body: json.encode(
          {
            'companyId': _selectedTask.companyId,
            'employeeId': userId,
            'taskId': _selectedTask.id,
            'employeeName': _selectedTask.employeeName,
            'reportDescription': description,
            'reportImageUrl': imageUrl,
            'reportLat': pickedLocation.latitude,
            'reportLong': pickedLocation.longitude,
            'reportAdress': reportAdress,
            'reportDate': _reportDate,
            'reportHour': _reportHour
          },
        ),
      );

      final taskUrl =
          'https://mysquad-1ab28-default-rtdb.firebaseio.com/tasks/${_selectedTask.id}.json?auth=$token';
      final taskResponse = await http.patch(Uri.parse(taskUrl),
          body: json.encode({'isCompleted': true}));

      debugPrint(response.body.toString());
      final newReport = Report(
          companyId: _selectedTask.companyId,
          employeeId: userId,
          taskId: _selectedTask.id,
          employeeName: _selectedTask.employeeName,
          reportDescription: description,
          reportImageUrl: imageUrl,
          location: pickedLocation,
          reportDate: nowDate,
          reportHour: nowHour);
      _reports.add(newReport);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
