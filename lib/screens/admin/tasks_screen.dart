import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/employee.dart';
import 'package:flutter_complete_guide/providers/employees.dart';
import 'package:flutter_complete_guide/widgets/app_drawer.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/task.dart';
import '../../providers/tasks.dart';
import '../report_detail_screen.dart';

class TasksScreen extends StatefulWidget {
  static const routeName = '/tasks-screen';
  @override
  _TasksScreen createState() => _TasksScreen();
}

class _TasksScreen extends State<TasksScreen> {
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
    getAllTasks();
    getEmployees();
    _dropdownMenuItems = buildDropdownMenuItems(employeeList);
    _selectedEmployee = _dropdownMenuItems[0].value;
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
    await Provider.of<Tasks>(context, listen: false)
        .fetchAndSetTasks(_selectedDate);
  }

  Future<void> getEmployees() async {
    this.employeeList = Provider.of<Employees>(context, listen: false).items;
  }

  Future<void> refreshTasks(BuildContext context) async {
    await Provider.of<Tasks>(context, listen: false)
        .fetchAndSetTasks(_selectedDate);
    setState(() {});
  }

  //Returning date
  getDiff() {
    var now = DateTime.now();
    if (dateFormat.format(_selectedDate) == dateFormat.format(now))
      return "Bugün";
    return dateFormat.format(_selectedDate).toString();
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

  void _showDeleteDialog(Task task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text('Görevi silmek istediğinizden emin misiniz ?'),
        actions: <Widget>[
          FlatButton(
            child: Text('İptal'),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {});
            },
          ),
          FlatButton(
            child: Text('Evet'),
            onPressed: () {
              deleteTask(task);
              showSnackBar(context, task);
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> addTask(String employeeId, String title, String employeeName,
      String description, DateTime taskDate, TimeOfDay taskHour) async {
    try {
      await Provider.of<Tasks>(context, listen: false).addTask(
          employeeId, title, employeeName, description, taskDate, taskHour);
    } catch (error) {
      const errorMessage = 'Task olusturulamadi.';
      _showErrorDialog(errorMessage);
    }
  }

  //Removing task from database and list
  Future<void> deleteTask(Task task) async {
    try {
      await Provider.of<Tasks>(context, listen: false).deleteTask(task);
    } catch (error) {
      final errorMessage = 'Gorev Silinemedi!';
      _showErrorDialog(errorMessage);
    }
  }

  Future<void> updateTask(Task newTask) async {
    try {
      await Provider.of<Tasks>(context, listen: false).updateTask(newTask);
    } catch (error) {
      final errorMessage = 'Gorev Yenilenemedi!';
      _showErrorDialog(errorMessage);
    }
  }

  // Opening dialog box for new task or edit task

  Future<void> showTaskDialog(BuildContext context, Task task) async {
    bool isCompleted = task != null ? task.isCompleted : false;
    tfTitleController.text = task != null ? task.title : tfTitleController.text;
    tfDecController.text =
        task != null ? task.description : tfDecController.text;
    return showDialog(
        context: context,
        barrierDismissible: task == null,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              content: Container(
                child: Form(
                  key: key,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Çalışan Seçiniz"),
                      SizedBox(
                        height: 10.0,
                      ),
                      DropdownButton(
                        value: _selectedEmployee,
                        items: _dropdownMenuItems,
                        onChanged: (value) => {
                          setState(() {
                            _selectedEmployee = value;
                          })
                        },
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        controller: tfTitleController,
                        validator: (value) {
                          return value.isEmpty ? "Required *" : null;
                        },
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                            hintText: "Başlık",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                              color: _themeColor,
                            ))),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SingleChildScrollView(
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: 100,
                          ),
                          child: TextFormField(
                            controller: tfDecController,
                            keyboardType: TextInputType.multiline,
                            minLines: 2,
                            maxLines: null,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                                hintText: "Açıklama",
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                  color: _themeColor,
                                ))),
                          ),
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          CupertinoIcons.clock_solid,
                          color: _themeColor,
                          size: 20,
                        ),
                        title: Text(
                          "Görev Saati Seçiniz",
                        ),
                        onTap: () async {
                          TimeOfDay picked = await showTimePicker(
                              context: context, initialTime: TimeOfDay.now());
                          if (picked != null) {
                            setState(() {
                              this._selectedHour = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Container(
                  padding: EdgeInsets.only(right: 10),
                  child: FlatButton(
                    color: _themeColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    textColor: Colors.white,
                    child: Text('Kaydet'),
                    onPressed: () async {
                      if (key.currentState.validate()) {
                        if (task == null) {
                          Task newTask = Task(
                            title: tfTitleController.text,
                            description: tfDecController.text,
                            employeeName: _selectedEmployee.userName,
                            isCompleted: isCompleted,
                            taskDate: _selectedDate,
                            taskHour: _selectedHour,
                          );
                          tfTitleController.text = '';
                          tfDecController.text = '';
                          addTask(
                                  _selectedEmployee.id,
                                  newTask.title,
                                  newTask.employeeName,
                                  newTask.description,
                                  newTask.taskDate,
                                  newTask.taskHour)
                              .then((value) => refreshTasks(context));
                        } else {
                          Task newTask = Task(
                            id: task.id,
                            companyId: task.companyId,
                            employeeId: task.employeeId,
                            employeeName: task
                                .employeeName, // sonradan eklendi, çalışmazsa sil !!
                            title: tfTitleController.text,
                            description: tfDecController.text,
                            isCompleted: isCompleted,
                            taskDate: _selectedDate,
                            taskHour: _selectedHour,
                          );
                          tfTitleController.text = '';
                          tfDecController.text = '';
                          updateTask(newTask)
                              .then((value) => refreshTasks(context));
                        }
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                )
              ],
            );
          });
        });
  }

  Container getTaskList() {
    return Container(
        child: Expanded(
      child: Consumer<Tasks>(
        builder: (ctx, tasksData, _) => Padding(
          padding: EdgeInsets.all(5),
          child: ListView.builder(
              itemCount: tasksData.tasks.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: UniqueKey(),
                  onDismissed: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      Task task = tasksData.tasks[index];
                      _showDeleteDialog(task);
                    } else {
                      Task task = tasksData.tasks[index];
                      int taskIndex = tasksData.tasks.indexOf(task);
                      await showTaskDialog(context, task);
                      setState(() {});
                    }
                  },
                  secondaryBackground: getDeleteBg(),
                  background: getEditBg(),
                  child: Container(
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
                              '${tasksData.tasks[index].description} \nGörevli: ${tasksData.tasks[index].employeeName} \nGörev Saati: ${tasksData.tasks[index].taskHour.hour}:${tasksData.tasks[index].taskHour.minute}',
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
                                    padding: EdgeInsets.fromLTRB(
                                        5.0, 10.0, 5.0, 0.0),
                                    child: ElevatedButton(
                                      child: Text('Görüntüle'),
                                      onPressed: () async {
                                        Navigator.of(context).pushNamed(
                                            ReportDetailScreen.routeName,
                                            arguments:
                                                tasksData.tasks[index].id);
                                      },
                                    ),
                                  )
                                : null),
                      ),
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
        drawer: AppDrawer(),
        appBar: AppBar(title: Text('Görevler')),
        floatingActionButton: Container(
          padding: EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.white12,
                blurRadius: 30,
              ),
            ],
          ),
          child: RawMaterialButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: () async {
              await showTaskDialog(context, null);
              setState(() {});
            },
            child: Icon(
              CupertinoIcons.add,
              color: _themeColor,
            ),
          ),
        ));
  }
}
