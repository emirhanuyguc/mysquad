import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;
  File _companyLogo;
  bool _isAdmin = false;

  bool get isAuth {
    return token != null;
  }

  bool get isAdmin {
    return _isAdmin != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> signup(String email, String password, String companyName,
      File companyLogo) async {
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
          .child('company_logo')
          .child(responseData['localId']);

      await ref.putFile(companyLogo);
      final imageUrl = await ref.getDownloadURL();

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      final databaseUrl =
          'https://mysquad-1ab28-default-rtdb.firebaseio.com/companies.json?auth=$_token';
      final companyData = await http.post(
        Uri.parse(databaseUrl),
        body: json.encode(
          {'id': _userId, 'companyName': companyName, 'imageUrl': imageUrl},
        ),
      );

      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> login(String email, String password) async {
    final url =
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyB0Kcqw4yG39NvbMgzVtm49V0R_n-lvQSY';
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

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );

      final filterString = 'orderBy="id"&equalTo="$_userId"';
      final companyUrl =
          'https://mysquad-1ab28-default-rtdb.firebaseio.com/companies.json?auth=$_token&$filterString';
      final adminResponse = await http.get(Uri.parse(companyUrl));
      final extractedData =
          json.decode(adminResponse.body) as Map<String, dynamic>;
      if (extractedData == null) {
        _isAdmin = false;
      }

      extractedData.forEach((firebaseId, responseUser) async {
        if (responseUser['id'] == _userId) {
          debugPrint(responseUser['id']);
          debugPrint('isAdmin true dönmeli !');
          _isAdmin = true;
        } else {
          debugPrint('isAdmin false dönmeli !');
          _isAdmin = false;
        }
      });

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String(),
          'isAdmin': _isAdmin
        },
      );
      prefs.setString('userData', userData);
      _autoLogout();
      notifyListeners();
    } catch (error) {
      debugPrint(error);
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.now().add(
      Duration(days: 7),
    );

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _isAdmin = extractedUserData['isAdmin'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    _isAdmin = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData');
    prefs.clear();
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
