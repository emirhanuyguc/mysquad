import 'dart:convert';
import 'dart:io';
import 'package:flutter_complete_guide/helpers/location_helper.dart';
import 'package:flutter_complete_guide/models/task.dart' as EmployeeTask;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_complete_guide/widgets/interactive_maps_marker.dart';
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
  List<MarkerItem> markersList = List();

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
    final _reportHour = (nowHour.hour).toString() +
        ':' +
        nowHour.minute.toString().padLeft(2, '0');
    final reportAdress = await LocationHelper.getPlaceAddress(
        pickedLocation.latitude, pickedLocation.longitude);
    debugPrint(reportAdress);
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('reports')
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
      updateLocation(
          newReport.companyId,
          newReport.employeeId,
          newReport.employeeName,
          newReport.location.latitude,
          newReport.location.longitude,
          newReport.reportDescription,
          newReport.reportImageUrl);
      _reports.add(newReport);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateLocation(
      String companyId,
      String employeeId,
      String employeeName,
      double latitude,
      double longitude,
      String description,
      String imageUrl) async {
    await fetchUserLocations(companyId);
    final markerIndex =
        markersList.indexWhere((marker) => marker.employeeId == employeeId);
    debugPrint('UPDATE lOCATION!');

    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = json.decode(prefs.getString('userData'));
      final token = userData['token'];
      // Sonucta user giris yaptıgında bu datalar onlara donusecek... Bu data kullanıcı panelinde kullanılacak.
      //
      if (markerIndex != -1) {
        debugPrint('markerIndex: $markerIndex');
        debugPrint('MARKER INDEX NULL DEĞİL');
        final newMarkerItem = MarkerItem(
            id: markersList[markerIndex].id,
            employeeName: employeeName,
            latitude: latitude,
            longitude: longitude,
            description: description,
            imageUrl: imageUrl);
        final filterString = 'orderBy="employeeId"&equalTo="$employeeId"';
        var idUrl =
            'https://mysquad-1ab28-default-rtdb.firebaseio.com/employeeLocations.json?auth=$token&$filterString';

        final idResponse = await http.get(Uri.parse(idUrl));
        final firebaseId = json.decode(idResponse.body)["name"];
        debugPrint('RESPONSE BODY : ${idResponse.body}');
        debugPrint('Firebase ID: $firebaseId');
        if (firebaseId == null) {
          return;
        }
        final url =
            'https://mysquad-1ab28-default-rtdb.firebaseio.com/employeeLocations/$firebaseId.json?auth=$token';
        final response = await http.patch(Uri.parse(url),
            body: json.encode({
              'companyId': companyId,
              'employeeId': newMarkerItem.employeeId,
              'employeeName': newMarkerItem.employeeName,
              'description': newMarkerItem.description,
              'imageUrl': newMarkerItem.imageUrl,
              'latitude': newMarkerItem.latitude,
              'longitude': newMarkerItem.longitude
            }));

        markersList[markerIndex] = newMarkerItem;
      } else {
        debugPrint('MARKER INDEX NULL');
        List idList = [];
        markersList.forEach((marker) {
          idList.add(marker.id);
        });

        int lastIndex;
        if (idList.isEmpty) {
          lastIndex = 1;
        } else {
          lastIndex = idList.reduce((curr, next) => curr > next ? curr : next);
          lastIndex = lastIndex + 1;
        }

        debugPrint('Last Index: $lastIndex');
        if (lastIndex == null) {}
        final newMarkerItem = MarkerItem(
            id: lastIndex,
            employeeName: employeeName,
            latitude: latitude,
            longitude: longitude,
            description: description,
            imageUrl: imageUrl);
        final databaseUrl =
            'https://mysquad-1ab28-default-rtdb.firebaseio.com/employeeLocations.json?auth=$token';

        final employeeLocation = await http.post(
          Uri.parse(databaseUrl),
          body: json.encode(
            {
              'companyId': companyId,
              'employeeId': employeeId,
              'employeeName': employeeName,
              'description': description,
              'latitude': latitude,
              'longitude': longitude,
              'imageUrl': imageUrl
            },
          ),
        );
        markersList.add(newMarkerItem);
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchLocations() async {
    debugPrint('Fetch locations çağrıldı !');
    final prefs = await SharedPreferences.getInstance();
    final userData = json.decode(prefs.getString('userData'));
    final token = userData['token'];
    final companyId = userData[
        'userId']; // Sonuçta admin panelinde çağırılacak, companyId dönecek !!

    debugPrint('companyId: $companyId');

    final filterString = 'orderBy="companyId"&equalTo="$companyId"';
    var url =
        'https://mysquad-1ab28-default-rtdb.firebaseio.com/employeeLocations.json?auth=$token&$filterString';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }

      debugPrint(response.body.toString());
      final List<MarkerItem> loadedLocations = [];
      int i = 1;
      extractedData.forEach((firebaseId, locationData) {
        debugPrint(extractedData.toString());
        loadedLocations.add(MarkerItem(
            id: i,
            employeeId: locationData['employeeId'],
            employeeName: locationData['employeeName'],
            imageUrl: locationData['imageUrl'],
            latitude: locationData['latitude'],
            longitude: locationData['longitude'],
            description: locationData['description']));
        i++;
      });
      debugPrint("Loaded Locations !!!");
      debugPrint(loadedLocations.toString());
      markersList = loadedLocations;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> fetchUserLocations(String companyId) async {
    debugPrint('Fetch locations çağrıldı !');
    final prefs = await SharedPreferences.getInstance();
    final userData = json.decode(prefs.getString('userData'));
    final token = userData['token'];

    debugPrint('companyId: $companyId');

    final filterString = 'orderBy="companyId"&equalTo="$companyId"';
    var url =
        'https://mysquad-1ab28-default-rtdb.firebaseio.com/employeeLocations.json?auth=$token&$filterString';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }

      debugPrint(response.body.toString());
      final List<MarkerItem> loadedLocations = [];
      int i = 1;
      extractedData.forEach((firebaseId, locationData) {
        debugPrint(extractedData.toString());
        loadedLocations.add(MarkerItem(
            id: i,
            employeeId: locationData['employeeId'],
            employeeName: locationData['employeeName'],
            imageUrl: locationData['imageUrl'],
            latitude: locationData['latitude'],
            longitude: locationData['longitude'],
            description: locationData['description']));
        i++;
      });
      debugPrint("Loaded Locations !!!");
      debugPrint(loadedLocations.toString());
      markersList = loadedLocations;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }
}
