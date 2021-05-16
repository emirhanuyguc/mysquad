import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'employee.dart';
import '../models/http_exception.dart';

class Employees with ChangeNotifier {
  List<Employee> _items = [];
  // var _showFavoritesOnly = false;
  String authToken;
  String userId;

  Employees(this.authToken, this.userId);

  List<Employee> get items {
    return [..._items];
  }

  Employee findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetEmployees() async {
    final prefs = await SharedPreferences.getInstance();
    final companyData = json.decode(prefs.getString('userData'));
    final token = companyData['token'];
    final companyId = companyData['userId'];

    final filterString = 'orderBy="companyId"&equalTo="$companyId"';
    var url =
        'https://mysquad-1ab28-default-rtdb.firebaseio.com/users.json?auth=$token&$filterString';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      debugPrint(extractedData.toString());
      final List<Employee> loadedEmployees = [];
      extractedData.forEach((firebaseId, employeeData) {
        loadedEmployees.add(Employee(
            id: employeeData['id'],
            email: employeeData['email'],
            userName: employeeData['userName'],
            imageUrl: employeeData['imageUrl'],
            isAdmin: employeeData['isAdmin']));
      });
      _items = loadedEmployees;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addEmployee(
      String email, String password, String userName, File userImage) async {
    final url =
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyB0Kcqw4yG39NvbMgzVtm49V0R_n-lvQSY';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_logo')
          .child(responseData['localId']);

      await ref.putFile(userImage);
      final imageUrl = await ref.getDownloadURL();

      final newEmployee = Employee(
        id: responseData['localId'],
        email: email,
        userName: userName,
        imageUrl: imageUrl,
        isAdmin: false,
      );
      final prefs = await SharedPreferences.getInstance();
      final companyData = json.decode(prefs.getString('userData'));
      final token = companyData['token'];
      final companyId = companyData['userId'];
      final databaseUrl =
          'https://mysquad-1ab28-default-rtdb.firebaseio.com/users.json?auth=$token';

      final employee = await http.post(
        Uri.parse(databaseUrl),
        body: json.encode(
          {
            'id': responseData['localId'],
            'companyId': companyId,
            'userEmail': email,
            'userName': userName,
            'imageUrl': imageUrl,
            'isAdmin': false
          },
        ),
      );
      _items.add(newEmployee);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

}
