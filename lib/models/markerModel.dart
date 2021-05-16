import 'package:flutter/cupertino.dart';

class MarkerModel {
  int index;
  String id;
  String name;
  String description;
  String latitude;
  String longitude;
  String image;

  MarkerModel(
      {@required this.index,
      @required this.id,
      @required this.name,
      @required this.description,
      @required this.latitude,
      @required this.longitude,
      @required this.image});

// you can use this model with your backend as well :

/*  factory MarkersModel.fromJson(Map<String, dynamic> json) => MarkersModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      image: json["image"]);
*/
}
