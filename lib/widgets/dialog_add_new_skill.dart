import 'package:flutter/material.dart';
import 'package:my_task_planner/constants.dart';
import 'package:my_task_planner/models/skill.dart';
import 'package:my_task_planner/utils/trans_util.dart';
import 'package:my_task_planner/widgets/button_standard.dart';
import 'package:my_task_planner/widgets/input_standard.dart';

class AddNewSkillDialog extends StatefulWidget {
  const AddNewSkillDialog({
    Key key,
  }) : super(key: key);

  @override
  _AddNewSkillDialogState createState() => _AddNewSkillDialogState();
}

class _AddNewSkillDialogState extends State<AddNewSkillDialog> {
  final _formKey = GlobalKey<FormState>();
  Skill skill = Skill(
    completed: false,
    completedHours: 0,
  );
  var _buttonEnabled = false;

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
                    hintText: TransUtil.trans("hint_skill_title"),
                    onChanged: (val) {
                      setState(() {
                        _buttonEnabled = val.length > 0;
                      });
                      skill.title = val;
                    },
                    isRequiredInput: true,
                    color: colorPrimaryLight,
                  ),
                  StandardInput(
                    hintText: TransUtil.trans("hint_add_note_optional"),
                    onChanged: (val) => skill.description = val,
                    color: colorPrimaryLight,
                  ),
                ],
              )),
          SizedBox(
            height: marginStandard,
          ),
          StandardButton(
            text: TransUtil.trans("btn_add_skill"),
            onButtonPressed: !_buttonEnabled
                ? null
                : () {
                    if (!_formKey.currentState.validate()) return;
                    Navigator.of(context).pop(skill);
                  },
          ),
        ],
      ),
    );
  }
}
