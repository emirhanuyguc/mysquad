import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/employee_locations.dart';
import 'package:flutter_complete_guide/providers/employee_tasks.dart';
import 'package:flutter_complete_guide/providers/employees.dart';
import 'package:flutter_complete_guide/providers/reports.dart';
import 'package:flutter_complete_guide/providers/tasks.dart';
import 'package:flutter_complete_guide/screens/admin/add_employee.dart';
import 'package:flutter_complete_guide/screens/admin/add_task.dart';
import 'package:flutter_complete_guide/screens/admin/employees_screen.dart';
import 'package:flutter_complete_guide/screens/admin/tabs_screen.dart';
import 'package:flutter_complete_guide/screens/admin/tasks_screen.dart';
import 'package:flutter_complete_guide/screens/employee/employee_tasks_screen.dart';
import 'package:flutter_complete_guide/screens/employee/report_screen.dart';
import 'package:flutter_complete_guide/screens/report_detail_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import './screens/splash_screen.dart';
import './providers/auth.dart';
import './screens/auth_screen.dart';
import './helpers/custom_route.dart';
import 'package:firebase_core/firebase_core.dart';
import './screens/admin/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProvider.value(
          value: Tasks(),
        ),
        ChangeNotifierProvider.value(
          value: EmployeeTasks(),
        ),
        ChangeNotifierProvider.value(
          value: Reports(),
        ),
        ChangeNotifierProvider.value(
          value: EmployeeLocations(),
        ),
        ChangeNotifierProxyProvider<Auth, Employees>(
          update: (ctx, auth, previousEmployees) => Employees(
            auth.token,
            auth.userId,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('en', 'EN'),
            const Locale('tr', 'TR'), // English, no country code
          ],
          locale: const Locale('tr', 'TR'),
          debugShowCheckedModeBanner: false,
          title: 'mySquad',
          theme: ThemeData(
            primaryColor: Color.fromRGBO(39, 58, 115, 1),
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CustomPageTransitionBuilder(),
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
              },
            ),
          ),
          home: auth.isAuth && auth.isAdmin
              ? TabsScreen()
              : auth.isAuth && !auth.isAdmin
                  ? EmployeeTasksScreen()
                  : FutureBuilder(
                      future: auth.tryAutoLogin(),
                      builder: (ctx, authResultSnapshot) =>
                          authResultSnapshot.connectionState ==
                                  ConnectionState.waiting
                              ? SplashScreen()
                              : AuthScreen(),
                    ),
          routes: {
            AddEmployeeScreen.routeName: (ctx) => AddEmployeeScreen(),
            MapScreen.routeName: (ctx) => MapScreen(),
            TasksScreen.routeName: (ctx) => TasksScreen(),
            AddTaskScreen.routeName: (ctx) => AddTaskScreen(),
            ReportScreen.routeName: (ctx) => ReportScreen(),
            EmployeeTasksScreen.routeName: (ctx) => EmployeeTasksScreen(),
            TabsScreen.routeName: (ctx) => TabsScreen(),
            ReportDetailScreen.routeName: (ctx) => ReportDetailScreen()
          },
        ),
      ),
    );
  }
}
