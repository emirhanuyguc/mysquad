import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Employee {
  final String id;
  final String email;
  final String userName;
  final String imageUrl;
  bool isAdmin;

  Employee({
    @required this.id,
    @required this.email,
    @required this.userName,
    @required this.imageUrl,
    this.isAdmin = false,
  });
}
