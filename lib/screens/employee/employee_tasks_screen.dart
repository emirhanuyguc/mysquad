import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/employee.dart';
import 'package:flutter_complete_guide/providers/employees.dart';
import 'package:flutter_complete_guide/providers/reports.dart';
import 'package:flutter_complete_guide/screens/employee/report_screen.dart';
import 'package:flutter_complete_guide/screens/report_detail_screen.dart';
import 'package:flutter_complete_guide/widgets/app_drawer.dart';
import 'package:flutter_complete_guide/widgets/employee_app_drawer.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/task.dart';
import '../../providers/employee_tasks.dart';

class EmployeeTasksScreen extends StatefulWidget {
  static const routeName = '/employee-tasks-screen';
  @override
  _EmployeeTasksScreen createState() => _EmployeeTasksScreen();
}

class _EmployeeTasksScreen extends State<EmployeeTasksScreen> {
  Color _themeColor = Color.fromRGBO(39, 58, 115, 1);
  CalendarController calController;
  TextEditingController tfTitleController = TextEditingController();
  TextEditingController tfDecController = TextEditingController();
  GlobalKey<FormState> key = GlobalKey();
  List taskList = List();
  final dateFormat = new DateFormat("d EEE, MMM ''yyyy", 'tr_TR');
  final dateFormatDB = new DateFormat("yyyy-MM-dd");
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedHour = TimeOfDay.now();
  Employee _selectedEmployee;
  List<Employee> employeeList;
  List<DropdownMenuItem<Employee>> _dropdownMenuItems;

  initState() {
    // TODO: implement initState
    super.initState();
    calController = CalendarController();
    getAllReports();
    getAllTasks();
  }

  List<DropdownMenuItem<Employee>> buildDropdownMenuItems(List employees) {
    List<DropdownMenuItem<Employee>> items = List();
    for (Employee employee in employees) {
      items.add(
        DropdownMenuItem(
          value: employee,
          child: Text(employee.userName),
        ),
      );
    }
    return items;
  }

  // Returning all tasks on selected date
  Future<void> getAllTasks() async {
    await Provider.of<EmployeeTasks>(context, listen: false)
        .fetchAndSetTasks(_selectedDate);
  }

  Future<void> getAllReports() async {
    await Provider.of<Reports>(context, listen: false)
        .fetchAndSetEmployeeReports();
  }

  Future<void> selectTask(Task selectedTask) async {
    await Provider.of<Reports>(context, listen: false).setTask(selectedTask);
  }

  //Returning date
  getDiff() {
    var now = DateTime.now();
    if (dateFormat.format(_selectedDate) == dateFormat.format(now))
      return "Bugün";
    return dateFormat.format(_selectedDate).toString();
  }

  //Showing snack bar when user delete any task
  showSnackBar(context, task) {
    final snackBar = SnackBar(
      content: Text('${task.title} görevi silindi !'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

  //Background for edit task (when user swipe start to end)
  getEditBg() {
    return Container(
      padding: EdgeInsets.only(left: 10),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        Icons.edit,
        color: _themeColor,
        size: 25,
      ),
    );
  }

  //Background for delete task (when user swipe end to start)
  getDeleteBg() {
    return Container(
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.only(right: 10),
      child: Icon(
        Icons.delete,
        color: _themeColor,
        size: 25,
      ),
    );
  }

  //Returning list of all tasks on selected date

  Container getTaskList() {
    return Container(
        child: Expanded(
      child: Consumer<EmployeeTasks>(
        builder: (ctx, tasksData, _) => Padding(
          padding: EdgeInsets.all(5),
          child: ListView.builder(
              itemCount: tasksData.tasks.length,
              itemBuilder: (context, index) {
                return Container(
                  height: 140,
                  child: Card(
                    color: _themeColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                    elevation: 6,
                    margin: EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 5,
                    ),
                    child: SingleChildScrollView(
                      child: ListTile(
                          title: Text(
                            '${tasksData.tasks[index].title}\n',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          subtitle: Text(
                            '${tasksData.tasks[index].description} \nGörev Saati: ${tasksData.tasks[index].taskHour.hour}:${tasksData.tasks[index].taskHour.minute}  ',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.white),
                          ),
                          leading: tasksData.tasks[index].isCompleted
                              ? Icon(
                                  CupertinoIcons.check_mark_circled_solid,
                                  color: Color(0xff00cf8d),
                                  size: 30,
                                )
                              : Icon(
                                  CupertinoIcons.clock_solid,
                                  color: Color(0xffff9e00),
                                  size: 30,
                                ),
                          trailing: tasksData.tasks[index].isCompleted
                              ? Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 0.0),
                                  child: ElevatedButton(
                                    child: Text('Görüntüle'),
                                    onPressed: () async {
                                      Navigator.of(context).pushNamed(
                                          ReportDetailScreen.routeName,
                                          arguments: tasksData.tasks[index].id);
                                    },
                                  ),
                                )
                              : Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(5.0, 15.0, 5.0, 0.0),
                                  child: ElevatedButton(
                                    child: Text('Raporla'),
                                    onPressed: () async {
                                      await selectTask(tasksData.tasks[index]);
                                      Navigator.of(context)
                                          .pushNamed(ReportScreen.routeName);
                                    },
                                  ),
                                )),
                    ),
                  ),
                );
              }),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Container(
          padding: EdgeInsets.only(top: 10),
          child: Column(
            children: [
              TableCalendar(
                locale: 'tr_TR',
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: CalendarStyle(
                    weekdayStyle: TextStyle(
                        color: _themeColor,
                        fontWeight: FontWeight.normal,
                        fontSize: 14),
                    weekendStyle: TextStyle(
                        color: _themeColor,
                        fontWeight: FontWeight.normal,
                        fontSize: 14),
                    selectedColor: _themeColor,
                    todayColor: _themeColor,
                    todayStyle: TextStyle(fontSize: 14, color: Colors.white)),
                onDaySelected: (date, events, holiday) => {
                  setState(() {
                    _selectedDate = date;
                    print('DATE SEÇİLDİ ! $_selectedDate');
                    getAllTasks();
                  }),
                },
                builders: CalendarBuilders(
                    selectedDayBuilder: (context, date, events) => Container(
                          margin: EdgeInsets.all(5.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _themeColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            date.day.toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        )),
                daysOfWeekStyle: DaysOfWeekStyle(
                    weekendStyle: TextStyle(
                        color: _themeColor, fontWeight: FontWeight.bold),
                    weekdayStyle: TextStyle(
                        color: _themeColor, fontWeight: FontWeight.bold)),
                headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    centerHeaderTitle: true,
                    titleTextStyle: TextStyle(
                      color: _themeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: _themeColor,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: _themeColor,
                    )),
                calendarController: calController,
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                  padding: EdgeInsets.only(left: 15, right: 10, top: 10),
                  height: MediaQuery.of(context).size.height - 40,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: _themeColor,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(50),
                          topLeft: Radius.circular(30))),
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 40,
                        ),
                        Text(
                          getDiff(),
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 30),
                        ),
                        FutureBuilder(
                          future: getAllTasks(),
                          builder: (ctx, snapshot) =>
                              snapshot.connectionState ==
                                      ConnectionState.waiting
                                  ? Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : getTaskList(),
                        ),
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
      drawer: EmployeeAppDrawer(),
      appBar: AppBar(title: Text('Görevler')),
    );
  }
}
