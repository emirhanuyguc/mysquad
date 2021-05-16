import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/user_image_picker.dart';
import '../../providers/employees.dart';

class AddTaskScreen extends StatefulWidget {
  static const routeName = '/add-task';
  @override
  _AddTaskScreen createState() => _AddTaskScreen();
}

class _AddTaskScreen extends State<AddTaskScreen> {
  final _passwordController = TextEditingController();
  final _titleController = TextEditingController();
  File _userImageFile;
  final GlobalKey<FormState> _formKey = GlobalKey();
  Map<String, String> _taskData = {
    'title': '',
    'description': '',
    'taskDate': '',
    'taskHour': ''
  };
  var _isLoading = false;
  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Bir Hata Oluştu!'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Tamam'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      /*await Provider.of<Employees>(context, listen: false).addEmployee(
          _employeeData['email'],
          _employeeData['password'],
          _employeeData['userName'],
          _userImageFile);*/
    } on HttpException catch (error) {
      var errorMessage = 'Kimlik doğrulama başarısız!';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'Bu e-mail adresi zaten kullanımda.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'Geçerli bir e-mail adresi giriniz.';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'Bu şifre çok zayıf.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Bu e-postaya sahip bir kullanıcı bulunamadı.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Geçersiz şifre.';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage =
          'Sizi doğrulayamadık. Lütfen daha sonra tekrar deneyiniz.';
      _showErrorDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ekip Üyesi Ekle '),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              decoration: InputDecoration(labelText: 'Başlık'),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Başlık Giriniz !';
                                }
                              },
                              onSaved: (value) {
                                _taskData['title'] = value;
                              },
                            ),
                            TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Açıklama'),
                              keyboardType: TextInputType.text,
                              onSaved: (value) {
                                _taskData['description'] = value;
                              },
                            ),
                            ListTile(
                              title: Text("Görev Tarihi Seçiniz"),
                              onTap: () async {
                                DateTime picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate:
                                        DateTime(DateTime.now().year - 5),
                                    lastDate:
                                        DateTime(DateTime.now().year + 5));
                                if (picked != null) {
                                  setState(() {
                                    _taskData['taskDate'] = picked as String;
                                  });
                                }
                              },
                            ),
                            ListTile(
                              title: Text("Görev Tarihi Seçiniz"),
                              onTap: () async {
                                TimeOfDay picked = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now());

                                if (picked != null) {
                                  setState(() {
                                    _taskData['taskDate'] = picked as String;
                                  });
                                }
                              },
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.fromLTRB(0.00, 20.00, 0.00, 0.00),
                              child: RaisedButton(
                                child: Text('Görev Oluştur'),
                                onPressed: _submit,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 45.0, vertical: 10.0),
                                color: Theme.of(context).primaryColor,
                                textColor: Theme.of(context)
                                    .primaryTextTheme
                                    .button
                                    .color,
                              ),
                            ),
                            if (_isLoading) CircularProgressIndicator()
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
