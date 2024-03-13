import 'package:flutter/material.dart';
import 'package:my_task_planner/constants.dart';
import 'package:my_task_planner/models/task.dart';
import 'package:my_task_planner/utils/json_data.dart';
import 'package:my_task_planner/utils/trans_util.dart';
import 'package:my_task_planner/widgets/button_standard.dart';

class TaskInfoDialog extends StatelessWidget {
  final Task task;
  final ValueSetter<Task> onDeleteTap;
  final ValueSetter<Task> onMarkAsCompletedTap;
  const TaskInfoDialog({Key key, @required this.task, this.onDeleteTap, this.onMarkAsCompletedTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.all(marginStandard),
      decoration: BoxDecoration(
        color: colorPrimaryLight,
        borderRadius: BorderRadius.circular(radiusStandard),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(
                Icons.close_rounded,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(
            height: marginStandard,
          ),
          FutureBuilder(
            future: JsonDataParser.getTaskIconPath(task?.imageId),
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
                child: Image.asset(
                  path,
                  width: size.width * 0.4,
                ),
              );
            },
          ),
          SizedBox(
            height: marginStandard,
          ),
          Text(task.date + " " + task.hour.toString() + ":00"),
          SizedBox(
            height: marginStandard,
          ),
          Text(task.description ?? ""),
          Visibility(
            visible: !task.completed,
            child: Column(
              children: [
                StandardButton(
                  text: TransUtil.trans("btn_mark_as_completed"),
                  activeColor: colorPrimary,
                  inactiveColor: colorPrimaryDark,
                  onButtonPressed: () {
                    onMarkAsCompletedTap(task);
                    Navigator.of(context).pop();
                  },
                ),
                SizedBox(
                  height: marginStandard,
                ),
              ],
            ),
          ),
          StandardButton(
            text: TransUtil.trans("btn_delete"),
            activeColor: Colors.red.shade400,
            inactiveColor: Colors.red.shade200,
            onButtonPressed: () {
              onDeleteTap(task);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
