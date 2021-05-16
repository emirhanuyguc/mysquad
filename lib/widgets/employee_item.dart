import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/employee.dart';
import '../providers/employees.dart';

class EmployeeItem extends StatelessWidget {
  final String id;
  final String userName;
  final String imageUrl;

  EmployeeItem(this.id, this.userName, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return ListTile(
      title: Text(userName ?? 'kullanıcı'),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {},
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {},
              color: Theme.of(context).errorColor,
            ),
          ],
        ),
      ),
    );
  }
}
