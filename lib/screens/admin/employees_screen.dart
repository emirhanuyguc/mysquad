import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/employees.dart';
import 'package:flutter_complete_guide/widgets/employee_item.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_drawer.dart';
import 'add_employee.dart';

class EmployeesScreen extends StatelessWidget {
  static const routeName = '/employees';

  Future<void> _refreshEmployees(BuildContext context) async {
    await Provider.of<Employees>(context, listen: false).fetchAndSetEmployees();
  }

  @override
  Widget build(BuildContext context) {
    print('rebuilding...');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saha Ekibim'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(AddEmployeeScreen.routeName);
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshEmployees(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshEmployees(context),
                    child: Consumer<Employees>(
                      builder: (ctx, employeesData, _) => Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                          itemCount: employeesData.items.length,
                          itemBuilder: (_, i) => Column(
                            children: [
                              EmployeeItem(
                                employeesData.items[i].id,
                                employeesData.items[i].userName,
                                employeesData.items[i].imageUrl,
                              ),
                              Divider(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
