import 'package:flutter/material.dart';
import 'package:my_task_planner/constants.dart';
import 'package:my_task_planner/models/skill.dart';
import 'package:my_task_planner/utils/trans_util.dart';

class SkillGridItem extends StatelessWidget {
  final Function onTap;
  final Skill skill;
  const SkillGridItem({Key key, this.skill, this.onTap}) : super(key: key);

  String get _jarImage {
    switch (skill.completedHours) {
      case 0:
        return IMG_JAR_EMPTY;
      case 1:
        return IMG_JAR_1;
      case 2:
        return IMG_JAR_2;
      case 3:
        return IMG_JAR_3;
      case 4:
        return IMG_JAR_4;
      case 5:
        return IMG_JAR_5;
      case 6:
        return IMG_JAR_6;
      case 7:
        return IMG_JAR_7;
      default:
        return IMG_JAR_FULL;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(marginStandard),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              _jarImage,
              width: size.width * 0.3,
            ),
            SizedBox(
              height: marginLarge,
            ),
            Text(
              skill.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSizeMedium,
              ),
            ),
            SizedBox(
              height: marginSmall,
            ),
            Text(
              skill.completed || skill.completedHours == 20
                  ? TransUtil.trans("label_completed")
                  : TransUtil.trans("label_skill_remaining_hours") + " " + (20 - skill.completedHours).toString(),
            ),
          ],
        ),
      ),
    );
  }
}
