import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';

import '../models/task.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class EmployeeTasks with ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks {
    return [..._tasks];
  }

  // var _showFavoritesOnly = false;
  final dateFormat = new DateFormat("yyyy-MM-dd");
  final timeFormat = new DateFormat("HH:mm");

  Future<void> fetchAndSetTasks(DateTime selectedDate) async {
    final prefs = await SharedPreferences.getInstance();
    final companyData = json.decode(prefs.getString('userData'));
    final token = companyData['token'];
    final userId = companyData['userId'];

    final filterString = 'orderBy="employeeId"&equalTo="$userId"';
    var url =
        'https://mysquad-1ab28-default-rtdb.firebaseio.com/tasks.json?auth=$token&$filterString';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }

      debugPrint(extractedData.toString());
      final List<Task> loadedTasks = [];
      extractedData.forEach((firebaseId, taskData) {
        if (taskData['taskDate'] == dateFormat.format(selectedDate)) {
          loadedTasks.add(Task(
              id: firebaseId,
              companyId: taskData['companyId'],
              employeeId: taskData['employeeId'],
              title: taskData['title'],
              description: taskData['description'],
              taskDate: DateTime.parse(taskData['taskDate']),
              taskHour: TimeOfDay(
                  hour: int.parse(taskData['taskHour'].split(":")[0]),
                  minute: int.parse(taskData['taskHour'].split(":")[1])),
              isCompleted: taskData['isCompleted']));
        }
      });
      loadedTasks.sort(
          (a, b) => a.taskHour.toString().compareTo(b.taskHour.toString()));
      _tasks = loadedTasks;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }
}
