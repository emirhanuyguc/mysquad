import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';

import '../models/task.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Tasks with ChangeNotifier {
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
    final companyId = companyData['userId'];

    final filterString = 'orderBy="companyId"&equalTo="$companyId"';
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
              employeeName: taskData['employeeName'],
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

  Future<void> addTask(String employeeId, String title, String employeeName,
      String description, DateTime taskDate, TimeOfDay taskHour) async {
    final prefs = await SharedPreferences.getInstance();
    final companyData = json.decode(prefs.getString('userData'));
    final token = companyData['token'];
    final companyId = companyData['userId'];
    final _taskDate = dateFormat.format(taskDate);
    final _taskHour = taskHour.hour.toString() +
        ':' +
        taskHour.minute.toString().padLeft(2, '0');
    try {
      final databaseUrl =
          'https://mysquad-1ab28-default-rtdb.firebaseio.com/tasks.json?auth=$token';

      final response = await http.post(
        Uri.parse(databaseUrl),
        body: json.encode(
          {
            'companyId': companyId,
            'employeeId': employeeId,
            'title': title,
            'employeeName': employeeName,
            'description': description,
            'taskDate': _taskDate,
            'taskHour': _taskHour,
            'isCompleted': false
          },
        ),
      );
      final newTask = Task(
          id: json.decode(response.body)['name'],
          companyId: companyData['localId'],
          employeeId: employeeId,
          employeeName: employeeName,
          title: title,
          description: description,
          taskDate: taskDate,
          taskHour: taskHour,
          isCompleted: false);
      _tasks.add(newTask);
      _tasks.sort(
          (a, b) => a.taskHour.toString().compareTo(b.taskHour.toString()));
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateTask(Task newTask) async {
    print('UPDATE TASK GELDİ PROVIDER!');
    final prefs = await SharedPreferences.getInstance();
    final companyData = json.decode(prefs.getString('userData'));
    final token = companyData['token'];
    final _taskDate = dateFormat.format(newTask.taskDate);
    final _taskHour = newTask.taskHour.hour.toString() +
        ':' +
        newTask.taskHour.minute.toString();
    final taskIndex = _tasks.indexWhere((task) => task.id == newTask.id);
    print(newTask.id);
    print(taskIndex);
    _tasks.forEach((task) {
      print(task.id);
    });
    try {
      final url =
          'https://mysquad-1ab28-default-rtdb.firebaseio.com/tasks/${newTask.id}.json?auth=$token';
      final response = await http.patch(Uri.parse(url),
          body: json.encode({
            'companyId': newTask.companyId,
            'employeeId': newTask.employeeId,
            'employeeName': newTask.employeeName,
            'title': newTask.title,
            'description': newTask.description,
            'taskDate': _taskDate,
            'taskHour': _taskHour,
            'isCompleted': false
          }));
      _tasks[taskIndex] = newTask;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> deleteTask(Task toBeDeletedTask) async {
    final prefs = await SharedPreferences.getInstance();
    final companyData = json.decode(prefs.getString('userData'));
    final token = companyData['token'];
    final url =
        'https://mysquad-1ab28-default-rtdb.firebaseio.com/tasks/${toBeDeletedTask.id}.json?auth=$token';
    final existingTaskIndex =
        _tasks.indexWhere((task) => task.id == toBeDeletedTask.id);
    var existingTask = _tasks[existingTaskIndex];
    _tasks.removeAt(existingTaskIndex);
    notifyListeners();
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode >= 400) {
      _tasks.insert(existingTaskIndex, existingTask);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingTask = null;
  }
}
