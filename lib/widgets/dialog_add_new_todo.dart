import 'package:flutter/material.dart';
import 'package:my_task_planner/constants.dart';
import 'package:my_task_planner/models/todo.dart';
import 'package:my_task_planner/utils/trans_util.dart';
import 'package:my_task_planner/widgets/button_standard.dart';
import 'package:my_task_planner/widgets/input_standard.dart';

class AddNewTodoDialog extends StatefulWidget {
  final int importanceLevel;
  const AddNewTodoDialog({Key key, this.importanceLevel}) : super(key: key);

  @override
  _AddNewTodoDialogState createState() => _AddNewTodoDialogState();
}

class _AddNewTodoDialogState extends State<AddNewTodoDialog> {
  static List<Map<String, dynamic>> importance = [
    {"value": 1, "text": "title_matrix_card_1"},
    {"value": 2, "text": "title_matrix_card_2"},
    {"value": 3, "text": "title_matrix_card_3"},
    {"value": 4, "text": "title_matrix_card_4"},
  ];

  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _selectedItem;
  Todo todo = Todo();
  var _submitted = false;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.importanceLevel != null ? importance.elementAt(widget.importanceLevel - 1) : null;
    todo.importance = widget.importanceLevel;
  }

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
          SizedBox(
            height: marginLarge,
          ),
          Form(
              key: _formKey,
              child: Column(
                children: [
                  StandardInput(
                    hintText: TransUtil.trans("hint_todo_title"),
                    onChanged: (val) => todo.title = val,
                    isRequiredInput: true,
                    color: colorPrimaryLight,
                  ),
                  StandardInput(
                    hintText: TransUtil.trans("hint_add_note_optional"),
                    onChanged: (val) => todo.description = val,
                    color: colorPrimaryLight,
                  ),
                ],
              )),
          SizedBox(
            height: marginStandard,
          ),
          DropdownButton<Map<String, dynamic>>(
            value: _selectedItem,
            focusColor: colorPrimaryLight,
            hint: Text(TransUtil.trans("label_selecet_importance_level")),
            dropdownColor: colorPrimaryLight,
            items: importance.map((Map<String, dynamic> value) {
              return DropdownMenuItem<Map<String, dynamic>>(
                value: value,
                child: Text(TransUtil.trans(value['text'])),
              );
            }).toList(),
            onTap: () {},
            onChanged: (importance) {
              setState(() {
                // impLevel = importance;
                _selectedItem = importance;
                todo.importance = _selectedItem['value'];
              });
            },
          ),
          SizedBox(
            height: marginStandard,
          ),
          Visibility(
            visible: _submitted && todo.importance == null,
            child: Text(
              TransUtil.trans("error_select_todo_importance_level"),
              style: TextStyle(
                color: Theme.of(context).errorColor,
              ),
            ),
          ),
          SizedBox(
            height: marginStandard,
          ),
          StandardButton(
            text: TransUtil.trans("btn_add_todo"),
            onButtonPressed: () {
              setState(() {
                _submitted = true;
              });
              if (!_formKey.currentState.validate() || todo.importance == null) return;
              Navigator.of(context).pop(todo);
            },
          ),
        ],
      ),
    );
  }
}
