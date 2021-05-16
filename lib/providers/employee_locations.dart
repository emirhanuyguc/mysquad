import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_complete_guide/models/markerModel.dart';
import 'package:flutter_complete_guide/widgets/interactive_maps_marker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EmployeeLocations with ChangeNotifier {
  EmployeeLocations();

  List<MarkerItem> markersList = List()
    ..add(MarkerItem(
        id: 1,
        employeeName: "Employee1",
        latitude: 31.4673274,
        longitude: 74.2637687,
        description: "Aciklama employee 1"))
    ..add(MarkerItem(
        id: 2,
        employeeName: "Employee2",
        latitude: 31.4718461,
        longitude: 74.3531591,
        description: "Aciklama employee 2"))
    ..add(MarkerItem(
        id: 3,
        employeeName: "Employee3",
        latitude: 31.5325107,
        longitude: 74.3610325,
        description: "Aciklama employee 3"))
    ..add(MarkerItem(
        id: 4,
        employeeName: "Employee4",
        latitude: 31.4668809,
        longitude: 74.31354,
        description: "Aciklama employee 4"));

  //Employee task raporunu bitirdiğinde çalışacak fonksiyon...
  Future<void> updateLocation(
      String employeeId,
      String employeeName,
      double latitude,
      double longtitude,
      String description,
      String imageUrl) async {
    if (markersList.any((marker) => marker.employeeId == employeeId)) {
      markersList.forEach((marker) {
        if (marker.employeeId == employeeId) {
          // Firebase Patch Request
          // markersList güncelle..
        }
      });
    } else {
      // Firebase Post request
      // son id sayısından 1 fazlasını ekle !
      final newMarkerItem = MarkerItem(
          id: 5,
          employeeName: employeeName,
          latitude: latitude,
          longitude: longtitude,
          description: description,
          imageUrl: imageUrl);
      markersList.add(newMarkerItem);
    }

    try {
      final newEmployeeLocation = MarkerItem(
          id: 1,
          employeeName: employeeName,
          latitude: latitude,
          longitude: longtitude,
          imageUrl: imageUrl);

      final prefs = await SharedPreferences.getInstance();
      final userData = json.decode(prefs.getString('userData'));
      final token = userData['token'];
      final companyId = userData['userId'];
      // Sonucta user giris yaptıgında bu datalar onlara donusecek... Bu data kullanıcı panelinde kullanılacak.
      //
      final databaseUrl =
          'https://mysquad-1ab28-default-rtdb.firebaseio.com/employeeLocations.json?auth=$token';

      final employee = await http.post(
        Uri.parse(databaseUrl),
        body: json.encode(
          {
            'userId': employeeId,
            'userName': employeeName,
            'latitude': latitude,
            'longtitude': longtitude,
            'imageUrl': imageUrl
          },
        ),
      );

      markersList.add(newEmployeeLocation);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
