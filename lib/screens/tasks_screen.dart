import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:my_task_planner/constants.dart';
import 'package:my_task_planner/models/task.dart';
import 'package:my_task_planner/screens/add_new_task_screen.dart';
import 'package:my_task_planner/services/database_service.dart';
import 'package:my_task_planner/services/notification_service.dart';
import 'package:my_task_planner/utils/date_util.dart';
import 'package:my_task_planner/utils/dialog_util.dart';
import 'package:my_task_planner/utils/trans_util.dart';
import 'package:my_task_planner/widgets/clock.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class TasksScreen extends StatefulWidget {
  static const ROUTE_NAME = "/TasksScreen";
  const TasksScreen({Key key}) : super(key: key);

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  static const TAG = "TasksScreen: ";
  final _dbService = DBService();
  List<Task> _tasksList = [];
  DateTime _dateTime;
  var _isAm = false;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dateTime = DateTime.now();
    print("${_dateTime.toString()}");
    // _lastPickedDateTime = _dateTime;
    _isAm = MyDateUtil.isAmPeriod(_dateTime);
    _fetchData();
  }

  set isLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  void _fetchData() async {
    isLoading = true;
    _tasksList = await _dbService.getTasksOn(_dateTime);
    isLoading = false;
  }

  void _addNewTask(int hour24Format) async {
    isLoading = true;
    // the result that returned from the AddNewTaskScreen as a List<Task>
    final addedTasks = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (builder) => AddNewTaskScreen(hour24Format: hour24Format),
      ),
    ) as List<Task>;
    isLoading = false;
    // ignore adding task in case the user closed the screen without picking any icon
    if (addedTasks == null || addedTasks.isEmpty) return;
    // the _tasksList represent the tasks for the current day only
    // so add the first Task element to the _tasksList and check
    _tasksList.add(addedTasks.elementAt(0));
    setState(() {});
  }

  void _deleteTask(Task task) async {
    setState(() {
      _tasksList.removeWhere((element) => element.id == task.id);
    });
    isLoading = true;
    final deleted = await _dbService.deleteTask(task);
    // show error message in case the task couldn't be deleted
    if (!deleted) {
      DialogUtil.showToast(TransUtil.trans("error_deleting_task"));
      _tasksList.add(task);
      isLoading = false;
      return;
    }
    // if the task deleted cancel the notification that associated with it as well
    final notificationId = MyDateUtil.getTaskNotificationId(task.date, task.hour);
    NotificationService.deleteNotificationById(notificationId);
    isLoading = false;
  }

  void _pickNewDate() async {
    final newDate = await DialogUtil.showDatePickerDialog(context, _dateTime);
    // ignore if the user closed the dialog without selecting or has selected the same date
    if (newDate == null || newDate == _dateTime) return;

    // update the selected date and re fetch data according to the new date
    final newDateWithHourRespect = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
      DateTime.now().hour,
    );
    _dateTime = newDateWithHourRespect;
    _fetchData();
  }

  void _markAsComplete(String id) async {
    print("completed $id");
    final task = _tasksList.firstWhere((element) => element.id == id);
    setState(() {
      task.completed = true;
    });

    final result = await _dbService.markTaskAsCompleted(id);
    if (result == null) {
      setState(() {
        task.completed = false;
      });
      // DialogUtil.showToast(TransUtil.trans("error_updating_todo_status"));
      DialogUtil.showToast(TransUtil.trans("error_occurerd_check_internet_connection"));
    }
  }

  void _showTaskDetails(int hour24Format) {
    final task = getTaskAt(_tasksList, hour24Format);
    if (task == null) {
      print("$TAG showTaskDetails: clicked hour: $hour24Format");
      DialogUtil.showToast("Couldn't retreive task details");
      return;
    }
    DialogUtil.showTaskInfoDialog(
      context,
      task,
      onDeleteTap: (task) => _deleteTask(task),
      onMarkAsCompletedTap: (task) => _markAsComplete(task.id),
    );
  }

  void _onEmptyClockTap(int hour24Format) {
    if (_isLoading)
      DialogUtil.showToast(TransUtil.trans("msg_please_wait_till_updating_data"));
    else
      _addNewTask(hour24Format);
  }

  List<Task> get _filteredTasksList {
    if (_tasksList == null) return [];
    if (_isAm)
      return _tasksList.where((element) => element.hour < 12 && element.hour >= 0).toList();
    else
      return _tasksList.where((element) => element.hour >= 12).toList();
  }

  int get _finishedTasksCount {
    int count = 0;
    _tasksList.forEach((element) {
      if (element.completed) count++;
    });
    return count;
  }

  double get _finishedTasksPercentage {
    if (_finishedTasksCount == 0) return 0.0;
    final percent = _finishedTasksCount * 100 / _tasksList.length;
    final rounded = num.parse(percent.toStringAsFixed(2));
    print("percent: $percent");
    return percent.isNaN ? 0.0 : rounded;
  }

  @override
  Widget build(BuildContext context) {
    print("_filteredTasksList count: ${_filteredTasksList.length}");
    print("_finishedTasksCount: $_finishedTasksCount");
    print("_finishedTasksPercentage: $_finishedTasksPercentage");
    return Scaffold(
      appBar: AppBar(
        title: Text(
          TransUtil.trans("title_tasks_screen"),
        ),
        actions: [
          IconButton(
            onPressed: _pickNewDate,
            icon: Icon(
              Icons.calendar_today_outlined,
            ),
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              // LinearPercentIndicator container
              width: double.infinity,
              margin: const EdgeInsets.all(marginStandard),
              padding: const EdgeInsets.all(marginStandard),
              child: Column(
                children: [
                  Text("${TransUtil.trans("label_today_total_tasks")} ${_tasksList.length}"),
                  Center(
                    child: LinearPercentIndicator(
                      animation: true,
                      lineHeight: 20.0,
                      animationDuration: 1000,
                      percent: _finishedTasksPercentage / 100,
                      center: Text(
                        "${_finishedTasksPercentage.toString()} %",
                        textAlign: TextAlign.center,
                      ),
                      linearStrokeCap: LinearStrokeCap.roundAll,
                      progressColor: colorPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            TasksClock(
              isAm: _isAm,
              tasksList: _filteredTasksList,
              selectedDate: _dateTime,
              onEmptyClockTap: _onEmptyClockTap,
              onExistIconTap: _showTaskDetails,
            ),
            Spacer(),
            Container(
              height: 50,
              child: Visibility(
                visible: _isLoading,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            SizedBox(
              height: marginLarge,
            ),
            FlutterSwitch(
              width: 125.0,
              height: 55.0,
              valueFontSize: 25.0,
              toggleSize: 45.0,
              value: _isAm,
              borderRadius: 30.0,
              padding: 8.0,
              showOnOff: true,
              activeText: "AM",
              inactiveText: "PM",
              activeColor: Colors.amber[300],
              inactiveColor: Colors.black54,
              onToggle: (val) {
                print("val: $val");
                print("isAm: $_isAm");
                setState(() {
                  _isAm = !_isAm;
                });
              },
              inactiveIcon: Icon(
                Icons.mode_night_outlined,
                color: Colors.black54,
              ),
              activeIcon: Icon(
                Icons.wb_sunny,
                color: Colors.amber[300],
              ),
            ),
            SizedBox(
              height: marginLarge,
            ),
          ],
        ),
      ),
    );
  }
}
