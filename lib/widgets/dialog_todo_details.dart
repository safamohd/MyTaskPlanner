import 'package:flutter/material.dart';
import 'package:my_task_planner/constants.dart';
import 'package:my_task_planner/models/todo.dart';
import 'package:my_task_planner/utils/date_util.dart';
import 'package:my_task_planner/utils/trans_util.dart';
import 'package:my_task_planner/widgets/button_standard.dart';

class TodoDetailsDialog extends StatelessWidget {
  final Todo todo;
  final ValueSetter<String> onMarkAsCompleted;
  final ValueSetter<String> onDeleteTap;
  const TodoDetailsDialog({
    Key key,
    this.todo,
    this.onMarkAsCompleted,
    this.onDeleteTap,
  }) : super(key: key);

  static List<Map<String, dynamic>> importance = [
    {"value": 1, "text": "title_matrix_card_1"},
    {"value": 2, "text": "title_matrix_card_2"},
    {"value": 3, "text": "title_matrix_card_3"},
    {"value": 4, "text": "title_matrix_card_4"},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(marginStandard),
      decoration: BoxDecoration(
        color: colorPrimary,
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
          Container(
            child: todo == null
                ? Container(
                    height: 150,
                    child: Center(
                      child: Text(
                        TransUtil.trans("error_retreiving_todo"),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: marginSmall,
                        ),
                        child: Text(
                          todo.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: fontSizeMedium,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: todo.description != null,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: marginSmall,
                          ),
                          child: Text(
                            todo.description ?? "",
                            style: TextStyle(
                              fontSize: fontSizeMedium,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: marginSmall,
                        ),
                        child: Text(
                          TransUtil.trans(
                            importance.elementAt(todo.importance - 1)['text'],
                          ),
                          style: TextStyle(
                            fontSize: fontSizeMedium,
                          ),
                        ),
                      ),
                      Container(
                        // todo created date
                        margin: const EdgeInsets.symmetric(
                          vertical: marginSmall,
                        ),
                        child: Text(
                          TransUtil.trans("label_created_todo_on") + " " + MyDateUtil.toStringDate(todo?.createdOn) ??
                              "",
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: marginSmall,
                        ),
                        child: todo.completed
                            ? Text(
                                TransUtil.trans("label_completed_todo_on") +
                                    " " +
                                    MyDateUtil.toStringDate(todo?.completedOn),
                              )
                            : Text(
                                TransUtil.trans("label_not_completed_yet"),
                              ),
                      ),
                      SizedBox(
                        height: marginStandard,
                      ),
                      Visibility(
                        visible: !todo.completed,
                        child: StandardButton(
                          text: TransUtil.trans("btn_mark_as_completed"),
                          textStyle: TextStyle(color: Colors.black87),
                          onButtonPressed: () {
                            onMarkAsCompleted(todo.id);
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      SizedBox(
                        height: marginStandard,
                      ),
                      StandardButton(
                        text: TransUtil.trans("btn_delete_todo"),
                        textStyle: TextStyle(color: Colors.black87),
                        activeColor: Colors.red.shade400,
                        inactiveColor: Colors.red.shade200,
                        onButtonPressed: () {
                          onDeleteTap(todo.id);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
