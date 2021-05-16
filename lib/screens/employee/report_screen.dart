import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/helpers/location_helper.dart';
import 'package:flutter_complete_guide/providers/employee_tasks.dart';
import 'package:flutter_complete_guide/providers/reports.dart';
import 'package:flutter_complete_guide/providers/tasks.dart';
import 'package:flutter_complete_guide/screens/employee/employee_tasks_screen.dart';
import 'package:provider/provider.dart';

import '../../widgets/image_input.dart';
import '../../widgets/location_input.dart';
import '../../models/report.dart';

class ReportScreen extends StatefulWidget {
  static const routeName = '/report-screen';

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _titleController = TextEditingController();
  File _pickedImage;
  ReportLocation _pickedLocation;
  var _isLoading = false;

  void _selectImage(File pickedImage) {
    _pickedImage = pickedImage;
  }

  void _selectPlace(double lat, double lng) {
    _pickedLocation = ReportLocation(latitude: lat, longitude: lng);
  }

  // ignore: missing_return
  Future<void> _sendReport() {
    if (_titleController.text.isEmpty ||
        _pickedImage == null ||
        _pickedLocation == null) {
      return Future.value();
    }
    setState(() {
      _isLoading = true;
    });
    try {
      Provider.of<Reports>(context, listen: false)
          .sendReport(_titleController.text, _pickedImage, _pickedLocation)
          .then((_) => {
                Navigator.of(context)
                    .pushNamed(EmployeeTasksScreen.routeName)
                    .then((value) => setState(() {
                          _isLoading = false;
                        }))
              });
    } catch (error) {
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Görevi Raporla'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: <Widget>[
                          TextField(
                            keyboardType: TextInputType.multiline,
                            minLines: 2,
                            maxLines: 5,
                            decoration: InputDecoration(labelText: 'Açıklama'),
                            controller: _titleController,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ImageInput(_selectImage),
                          SizedBox(
                            height: 10,
                          ),
                          LocationInput(_selectPlace),
                        ],
                      ),
                    ),
                  ),
                ),
                FutureBuilder(
                  future: _sendReport(),
                  builder: (context, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : RaisedButton.icon(
                              icon: Icon(Icons.add),
                              label: Text('Raporu Gönder'),
                              onPressed: _sendReport,
                              elevation: 0,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              color: Theme.of(context).accentColor,
                            ),
                ),
              ],
            ),
    );
  }
}
