import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_task_planner/constants.dart';
import 'package:my_task_planner/models/skill.dart';
import 'package:my_task_planner/models/task.dart';
import 'package:my_task_planner/models/todo.dart';
import 'package:my_task_planner/widgets/dialog_add_new_skill.dart';
import 'package:my_task_planner/widgets/dialog_add_new_todo.dart';
import 'package:my_task_planner/widgets/dialog_reset_password.dart';
import 'package:my_task_planner/widgets/dialog_task_info.dart';
import 'package:my_task_planner/widgets/dialog_todo_details.dart';

class DialogUtil {
  static Future<void> showResetPasswordDialog(BuildContext context, String email) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ResetpasswordDialog(
            email: email,
          ),
        );
      },
    );
  }

  static Future<void> showTaskInfoDialog(BuildContext context, Task task,
      {ValueSetter<Task> onDeleteTap, ValueSetter<Task> onMarkAsCompletedTap}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: TaskInfoDialog(
            task: task,
            onDeleteTap: onDeleteTap,
            onMarkAsCompletedTap: onMarkAsCompletedTap,
          ),
        );
      },
    );
  }

  static Future<DateTime> showDatePickerDialog(BuildContext context, DateTime initialDate) {
    return showDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: initialDate,
          firstDate: DateTime(initialDate.year - 1, 1, 1),
          lastDate: DateTime(initialDate.year + 1, 1, 1),
        );
      },
    );
  }

  static Future<Todo> showNewTodoDialog(BuildContext context, int importance) {
    return showDialog<Todo>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: AddNewTodoDialog(
            importanceLevel: importance,
          ),
        );
      },
    );
  }

  static Future<Skill> showNewSkillDialog(BuildContext context) {
    return showDialog<Skill>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: AddNewSkillDialog(),
        );
      },
    );
  }

  static Future<void> showTodoDetailsDialog(BuildContext context, Todo todo,
      {ValueSetter<String> onMarkAsCompleted, ValueSetter<String> onDeleteTap}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: TodoDetailsDialog(
            todo: todo,
            onDeleteTap: onDeleteTap,
            onMarkAsCompleted: onMarkAsCompleted,
          ),
        );
      },
    );
  }

  static Future<bool> showToast(String message,
      {Toast length = Toast.LENGTH_SHORT, ToastGravity gravity = ToastGravity.BOTTOM}) {
    return Fluttertoast.showToast(
      msg: message,
      toastLength: length,
      gravity: gravity,
      backgroundColor: colorPrimaryLight,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }
}
