import 'package:flutter/material.dart';
import 'package:flutter_analog_clock/flutter_analog_clock.dart';
import 'package:my_task_planner/constants.dart';
import 'package:my_task_planner/models/task.dart';
import 'package:my_task_planner/utils/date_util.dart';
import 'package:my_task_planner/utils/dialog_util.dart';
import 'package:my_task_planner/utils/json_data.dart';
import 'package:my_task_planner/utils/trans_util.dart';

class TasksClock extends StatelessWidget {
  final ValueSetter<int> onEmptyClockTap;
  final ValueSetter<int> onExistIconTap;
  final DateTime selectedDate;
  final List<Task> tasksList;
  final bool isAm;
  const TasksClock(
      {Key key,
      @required this.tasksList,
      this.onEmptyClockTap,
      @required this.isAm,
      this.onExistIconTap,
      @required this.selectedDate})
      : super(key: key);

  /// returns the task icon if exist or empty contianer otherwise
  Widget _buildContainer(int hour12Format) {
    // our clock support 12 hours format so get the 24 hours format according to the isAm value
    // so we can filter the tasks and display them on the clock
    final hourIn24Format = MyDateUtil.getHourFrom12Format(hour12Format, isAm);
    print("_buildContainer: hourIn24Format $hourIn24Format");
    // get the task at the specifed hour[hour12Format]
    final currentTask = getTaskAt(tasksList, hourIn24Format);
    // return empty container in case the task is null or filled container with task icon otherwise
    return currentTask == null
        ? _buildEmptyContainer(hourIn24Format)
        : _buildTaskContainer(currentTask, hourIn24Format);
  }

  Widget _buildEmptyContainer(int hourIn24Format) {
    // print("buildEmptyContainer: hourIn24Format: $hourIn24Format AM: $isAm");
    return InkWell(
      onTap: _pastDate
          ? () => DialogUtil.showToast(TransUtil.trans("error_cant_add_task_in_past"))
          : () => onEmptyClockTap(hourIn24Format),
      borderRadius: BorderRadius.all(
        Radius.circular(radiusStandard),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 1.0,
            color: _pastDate ? Colors.grey : colorPrimary,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(radiusStandard),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskContainer(Task currentTask, int hourIn24Format) {
    // print("buildTaskContainer: hourIn24Format: $hourIn24Format AM: $isAm");
    return InkWell(
      onTap: () => onExistIconTap(hourIn24Format),
      borderRadius: BorderRadius.all(
        Radius.circular(radiusStandard),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 1.0,
            color: getBorderColorForTask(currentTask),
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(radiusStandard),
          ),
        ),
        child: currentTask == null
            ? SizedBox()
            : FutureBuilder(
                future: JsonDataParser.getTaskIconPath(currentTask.imageId),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (!snapshot.hasData || snapshot.hasError) {
                    return Center(child: Icon(Icons.error_outline_rounded));
                  }
                  final path = snapshot.data;
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(path),
                    ),
                  );
                },
              ),
      ),
    );
  }

  bool get _pastDate {
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year && selectedDate.month == now.month && selectedDate.day == now.day;
    if (isToday) return false;
    return selectedDate.isBefore(now);
  }

  Color getBorderColorForTask(Task task) {
    if (_pastDate) return Colors.grey;
    if (task == null)
      return colorPrimary;
    else if (task.completed)
      return Colors.green;
    else
      return Colors.amber;
  }

  @override
  Widget build(BuildContext context) {
    print("Clock: count ${tasksList.length}");
    final size = MediaQuery.of(context).size;
    final clockOffset = size.width * 0.20;
    final width = size.width;
    return Container(
      width: width,
      height: width,
      child: Stack(
        children: [
          Positioned(
            top: clockOffset,
            bottom: clockOffset,
            right: clockOffset,
            left: clockOffset,
            child: FlutterAnalogClock(
              dateTime: DateTime.now(),
              dialPlateColor: colorPrimary,
              hourHandColor: colorPrimaryLight,
              minuteHandColor: colorPrimaryLight,
              secondHandColor: colorPrimaryLight,
              numberColor: Colors.black,
              borderColor: Colors.black,
              tickColor: Colors.black,
              centerPointColor: Colors.black,
              showBorder: true,
              showTicks: true,
              showMinuteHand: true,
              showSecondHand: true,
              showNumber: true,
              borderWidth: 8.0,
              // hourNumberScale: .10,
              hourNumbers: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'],
              isLive: true,
              // width: 200.0,
              // height: 200.0,
              decoration: const BoxDecoration(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: marginLarge * 2,
                  ),
                  Text(
                    MyDateUtil.toStringDate(selectedDate),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            // 12 o'clock
            top: width * 0.03,
            left: width * 0.45,
            right: width * 0.45,
            height: width * 0.10, // width - (leftOffset + rightOffset)
            child: Container(
              child: _buildContainer(12),
            ),
          ),
          Positioned(
            // 1 o'clock
            top: width * 0.07,
            left: width * 0.65,
            right: width * 0.25,
            height: width * 0.10, // width - (leftOffset + rightOffset)
            child: _buildContainer(1),
          ),
          Positioned(
            // 2 o'clock
            top: width * 0.20,
            left: width * 0.80,
            right: width * 0.10,
            height: width * 0.10, // width - (leftOffset + rightOffset)
            child: _buildContainer(2),
          ),
          Positioned(
            // 3 o'clock
            top: width * 0.45,
            left: width * 0.87,
            right: width * 0.03,
            height: width * 0.10, // width - (leftOffset + rightOffset)
            child: _buildContainer(3),
          ),
          Positioned(
            // 4 o'clock
            bottom: width * 0.20,
            left: width * 0.80,
            right: width * 0.10,
            height: width * 0.10, // width - (leftOffset + rightOffset)
            child: _buildContainer(4),
          ),
          Positioned(
            // 5 o'clock
            bottom: width * 0.07,
            left: width * 0.65,
            right: width * 0.25,
            height: width * 0.10, // width - (leftOffset + rightOffset)
            child: _buildContainer(5),
          ),
          Positioned(
            // 6 o'clock
            bottom: width * 0.03,
            left: width * 0.45,
            right: width * 0.45,
            height: width * 0.10, // width - (leftOffset + rightOffset)
            child: _buildContainer(6),
          ),
          Positioned(
            // 7 o'clock
            bottom: width * 0.07,
            right: width * 0.65,
            left: width * 0.25,
            height: width * 0.10, // width - (leftOffset + rightOffset)
            child: _buildContainer(7),
          ),
          Positioned(
            // 8 o'clock
            bottom: width * 0.20,
            right: width * 0.80,
            left: width * 0.10,
            height: width * 0.10, // width - (leftOffset + rightOffset)
            child: _buildContainer(8),
          ),
          Positioned(
            // 9 o'clock
            top: width * 0.45,
            right: width * 0.87,
            left: width * 0.03,
            height: width * 0.10, // width - (leftOffset + rightOffset)
            child: _buildContainer(9),
          ),
          Positioned(
            // 10 o'clock
            top: width * 0.20,
            right: width * 0.80,
            left: width * 0.10,
            height: width * 0.10, // width - (leftOffset + rightOffset)
            child: _buildContainer(10),
          ),
          Positioned(
            // 11 o'clock
            top: width * 0.07,
            right: width * 0.65,
            left: width * 0.25,
            height: width * 0.10, // width - (leftOffset + rightOffset)
            child: _buildContainer(11),
          ),
        ],
      ),
    );
  }
}
