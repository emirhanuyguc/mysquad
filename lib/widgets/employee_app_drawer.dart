import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/screens/admin/tasks_screen.dart';
import 'package:flutter_complete_guide/screens/employee/employee_tasks_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../helpers/custom_route.dart';

class EmployeeAppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('mySquad App'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.work),
            title: Text('Görevlerim'),
            onTap: () {
              Navigator.of(context).pushNamed(EmployeeTasksScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Ayarlar'),
            onTap: () {
              // Navigator.of(context)
              //   .pushReplacementNamed(UserProductsScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Çıkış Yap'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/');

              // Navigator.of(context)
              //     .pushReplacementNamed(UserProductsScreen.routeName);
              Provider.of<Auth>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
