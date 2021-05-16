import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/screens/admin/map_screen.dart';
import 'package:flutter_complete_guide/screens/admin/tasks_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/app_drawer.dart';
import 'employees_screen.dart';
import '../../providers/auth.dart';

class TabsScreen extends StatefulWidget {
  TabsScreen();
  static const routeName = '/tabs-screen';
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  List<Map<String, Object>> _pages;
  int _selectedPageIndex = 0;
  Auth auth;

  @override
  void initState() {
    _pages = [
      {
        'page': EmployeesScreen(),
        'title': 'Ekibim',
      },
      {
        'page': MapScreen(),
        'title': 'Sahada Görüntüle',
      },
    ];
    super.initState();
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedPageIndex]['page'],
      drawer: AppDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        backgroundColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.white,
        selectedItemColor: Theme.of(context).accentColor,
        currentIndex: _selectedPageIndex,
        // type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.people),
            title: Text('Ekibim'),
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.map),
            title: Text('Sahada Görüntüle'),
          ),
        ],
      ),
    );
  }
}
