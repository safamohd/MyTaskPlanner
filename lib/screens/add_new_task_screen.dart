import 'package:flutter/material.dart';
import 'package:my_task_planner/constants.dart';
import 'package:my_task_planner/models/task.dart';
import 'package:my_task_planner/screens/tasks_screen.dart';
import 'package:my_task_planner/services/database_service.dart';
import 'package:my_task_planner/services/notification_service.dart';
import 'package:my_task_planner/utils/date_util.dart';
import 'package:my_task_planner/utils/dialog_util.dart';
import 'package:my_task_planner/utils/json_data.dart';
import 'package:my_task_planner/utils/trans_util.dart';
import 'package:my_task_planner/widgets/input_standard.dart';

enum RepeatTask { None, Daily, Weekly, Monthly, Yearly }

class AddNewTaskScreen extends StatefulWidget {
  static const ROUTE_NAME = "AddNewTaskScreen";
  final int hour24Format;
  const AddNewTaskScreen({Key key, @required this.hour24Format})
      : super(key: key);

  @override
  State<AddNewTaskScreen> createState() => _AddNewTaskScreenState();
}

class _AddNewTaskScreenState extends State<AddNewTaskScreen> {
  final Map<RepeatTask, dynamic> _checkBoxLabel = {
    RepeatTask.None: TransUtil.trans('label_repeat_none'),
    RepeatTask.Daily: TransUtil.trans("label_repeat_daily_untill"),
    RepeatTask.Weekly: TransUtil.trans("label_repeat_weekly_untill"),
    RepeatTask.Monthly: TransUtil.trans("label_repeat_monthly_untill"),
    RepeatTask.Yearly: TransUtil.trans("label_repeat_yearly_untill"),
  };

  final _dbService = DBService();

  var repeatTaskType = RepeatTask.None;
  var imageId = "";
  var noteOptional = "";
  var isRepeatedTask = false;
  var _isLoading = false;
  List<Task> result = [];
  DateTime _endDateTime;

  int get hour24Format => widget.hour24Format;
  bool get pickedImage => imageId.isNotEmpty;

  /// returns the _endDateTime in formatted pattern if it has value and the repeatTaskType not equals RepeatTask.None
  /// to append the checkBoxTile title so it would be clear to the user at which date will be repeated
  String get _formattedEndDate =>
      _endDateTime == null || repeatTaskType == RepeatTask.None
          ? ""
          : MyDateUtil.toStringDate(_endDateTime);

  set isLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  /// updates the repeatTaskType value depending on the selected radio item
  /// and calls the pickEndDate to show the datePicked dialog if the value not equals to RepeatTask.None
  void updateRepeatType(RepeatTask repeatTask) {
    setState(() {
      repeatTaskType = repeatTask;
      if (repeatTask != RepeatTask.None)
        pickEndDate();
      else
        _endDateTime = null;
    });
  }

  /// updates the isRepeatedTask value so the radio group can decide whether to show or hide
  /// if the value is equals to false make sure to update the repeatTaskType to RepeatTask.None as well
  void setRepeatedTask(bool repeated) {
    setState(() {
      if (repeated == false) repeatTaskType = RepeatTask.None;
      isRepeatedTask = repeated;
    });
  }

  /// shows a datePicker to the user to pick the _endDateTime if the task is repeated
  void pickEndDate() async {
    DialogUtil.showToast(TransUtil.trans("message_please_pick_end_date"));
    _endDateTime =
        await DialogUtil.showDatePickerDialog(context, DateTime.now());
    // check whether the user closed the date picker without picking anu date and ignore if so
    if (_endDateTime == null) {
      DialogUtil.showToast(TransUtil.trans("message_picking_date_ignored"));
      setRepeatedTask(false);
      return;
    }
    // check whether the picked date is before the DateTime.now and ignore if so
    if (_endDateTime.compareTo(DateTime.now()) <= 0) {
      DialogUtil.showToast(TransUtil.trans("error_end_time_must_be_after_now"));
      updateRepeatType(RepeatTask.None);
      return;
    }
    // everything is ok update UI
    setState(() {});
  }

  /// returns a dateTime with added offset depending on the repeatTask value
  DateTime addOffset(DateTime dateTime, RepeatTask repeatTask) {
    DateTime temp = DateTime.utc(dateTime.year, dateTime.month, dateTime.day);
    switch (repeatTask) {
      case RepeatTask.Daily:
        temp = DateTime(dateTime.year, dateTime.month, dateTime.day + 1);
        break;
      case RepeatTask.Weekly:
        temp = DateTime(dateTime.year, dateTime.month, dateTime.day + 7);
        break;
      case RepeatTask.Monthly:
        temp = DateTime(dateTime.year, dateTime.month + 1, dateTime.day);
        break;
      case RepeatTask.Yearly:
        temp = DateTime(dateTime.year + 1, dateTime.month, dateTime.day);
        break;
      default:
        break;
    }
    return temp;
  }

  /// handles adding all the tasks if the repeat is enabled
  void pushAllTasksToServer() async {
    var currentDate = DateTime.now();
    print("DateTime: $currentDate");

    if (_endDateTime == null) {
      DialogUtil.showToast(
          TransUtil.trans("error_no_tasks_addedـmissing_end_date"));
      return;
    }
    isLoading = true;

    // push all tasks to database in the range between currentDate and _endDateTime
    while (currentDate.compareTo(_endDateTime) <= 0) {
      print("pushAllTasksToServer DateTime: $currentDate");
      // add the task at the currentDate
      await addNewTask(currentDate);
      currentDate = addOffset(currentDate, repeatTaskType);
    }
    isLoading = false;
    Navigator.of(context).pop(result);
  }

  /// handles adding new task at specific dateTime and schedule notification for it
  Future<void> addNewTask(DateTime dateTime) async {
    final now = DateTime.now();
    Task task = Task(
      imageId: imageId,
      description: noteOptional,
      hour: hour24Format,
      date: MyDateUtil.toStringDate(dateTime),
    );

    // set the notification time to notify before 15 minutes of the task
    final notificationTime = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      hour24Format,
    ).subtract(Duration(minutes: 15));

    // schedule notification before 15 minutes of this task
    if (notificationTime.isAfter(now)) {
      final notificationId =
          MyDateUtil.getTaskNotificationId(task.date, task.hour);
      NotificationService.scheduleNotification(
        id: notificationId,
        title: "Coming task !",
        payload: TasksScreen.ROUTE_NAME,
        body: task.description != null && task.description.isNotEmpty
            ? task.description + " starts after 15 minuts from now !"
            : "Don't forget your task after 15 minutes, click for more details",
        dateTime: notificationTime,
      );
    }

    await _dbService.addNewTask(task);
    result.add(task);
  }

  /// triggered when submitting the form only if the imageId is not null
  void onSubmit() async {
    if (repeatTaskType == RepeatTask.None) {
      isLoading = true;
      await addNewTask(DateTime.now());
      isLoading = false;
      Navigator.of(context).pop(result);
      return;
    }
    pushAllTasksToServer();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          TransUtil.trans("title_add_new_task"),
        ),
        actions: [
          IconButton(
            onPressed: !pickedImage || _isLoading ? null : onSubmit,
            icon: Icon(
              Icons.done,
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(marginStandard),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder<Object>(
                // images grid view
                future: JsonDataParser.getTasksIcons(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (!snapshot.hasData || snapshot.hasError) {
                    return Center(
                      child: Text("Error loading data !"),
                    );
                  }
                  final Map<String, dynamic> iconsList = snapshot.data;
                  final keys = iconsList.keys;
                  print("first ${iconsList[keys.first]}");
                  // return Container();
                  return Container(
                    height: size.height * 0.5,
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: iconsList.entries.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: marginStandard,
                        crossAxisSpacing: marginStandard,
                      ),
                      itemBuilder: (ctx, index) {
                        return InkWell(
                          onTap: () {
                            imageId = keys.elementAt(index);
                            setState(() {});
                          },
                          child: Container(
                            // height: 45,
                            // width: 45,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1.0,
                                color: imageId == keys.elementAt(index)
                                    ? colorPrimary
                                    : Colors.transparent,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(radiusStandard),
                              ),
                            ),
                            padding: const EdgeInsets.all(marginSmall),
                            child: Image.asset(
                              iconsList[keys.elementAt(index)],
                              // iconsList[keys.first],
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              Visibility(
                visible: _isLoading,
                child: Container(
                  margin: const EdgeInsets.all(marginStandard),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              SizedBox(
                height: marginLarge,
              ),
              StandardInput(
                // optional note input
                hintText: TransUtil.trans("hint_add_note_optional"),
                onChanged: (val) => noteOptional = val,
                color: colorPrimary,
              ),
              CheckboxListTile(
                title: Text(
                    "${_checkBoxLabel[repeatTaskType]} $_formattedEndDate"),
                value: isRepeatedTask,
                onChanged: setRepeatedTask,
              ),
              Visibility(
                visible: isRepeatedTask,
                child: Column(
                  children: [
                    // RadioListTile<RepeatTask>(
                    //   title: Text(TransUtil.trans("label_repeat_none")),
                    //   value: RepeatTask.None,
                    //   groupValue: repeatTaskType,
                    //   onChanged: updateRepeat,
                    // ),
                    RadioListTile<RepeatTask>(
                      title: Text(TransUtil.trans("label_repeat_daily")),
                      value: RepeatTask.Daily,
                      groupValue: repeatTaskType,
                      onChanged: updateRepeatType,
                    ),
                    RadioListTile<RepeatTask>(
                      title: Text(TransUtil.trans("label_repeat_weekly")),
                      value: RepeatTask.Weekly,
                      groupValue: repeatTaskType,
                      onChanged: updateRepeatType,
                    ),
                    RadioListTile<RepeatTask>(
                      title: Text(TransUtil.trans("label_repeat_monthly")),
                      value: RepeatTask.Monthly,
                      groupValue: repeatTaskType,
                      onChanged: updateRepeatType,
                    ),
                    RadioListTile<RepeatTask>(
                      title: Text(TransUtil.trans("label_repeat_yearly")),
                      value: RepeatTask.Yearly,
                      groupValue: repeatTaskType,
                      onChanged: updateRepeatType,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
