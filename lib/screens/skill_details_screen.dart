import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_task_planner/constants.dart';
import 'package:my_task_planner/models/skill.dart';
import 'package:my_task_planner/screens/skills_screen.dart';
import 'package:my_task_planner/services/database_service.dart';
import 'package:my_task_planner/services/notification_service.dart';
import 'package:my_task_planner/utils/dialog_util.dart';
import 'package:my_task_planner/utils/trans_util.dart';
import 'package:my_task_planner/widgets/draggable_widget.dart';

class SkillDetailsScreen extends StatefulWidget {
  static const ROUTE_NAME = "/SkillDetailsScreen";

  final Skill skill;
  const SkillDetailsScreen({Key key, this.skill}) : super(key: key);

  @override
  _SkillDetailsScreenState createState() => _SkillDetailsScreenState();
}

class _SkillDetailsScreenState extends State<SkillDetailsScreen> {
  static const _TOTAL_HOURS = 20;
  static const _BALLS_COUNT = 6;
  Skill _skill;
  List<Widget> _balls = [];

  @override
  void initState() {
    _skill = Skill.from(widget.skill);
    _initBalls();
    super.initState();
  }

  void _initBalls() {
    print("rem hrs = ${_TOTAL_HOURS - _skill.completedHours}");
    _balls
        .clear(); // to prevent adding over the old balls when re initializing again if needed

    for (int i = 0; i < _TOTAL_HOURS - _skill.completedHours; i++) {
      var count = _BALLS_COUNT % (i + 1);
      if (count == 0) count++;
      final imagePath =
          "assets/images/ball_" + _randomNumber.toString() + ".png";

      _balls.add(Container(
        child: Image.asset(imagePath),
      ));
    }
  }

  int get _randomNumber {
    final rng = new math.Random();
    final rnd = rng.nextInt(7);
    return rnd != 0 ? rnd : 1;
  }

  String get _jarImage {
    switch (_skill.completedHours) {
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

  void _deleteSkill() async {
    final deleted = await DBService().deleteSkill(_skill.id);
    if (!deleted) {
      DialogUtil.showToast(TransUtil.trans("error_deleting_skill"));
      return;
    }
    // return the id so the tasks screen remove
    //the corresponding item from the local list
    Navigator.of(context).pop(_skill.id);
  }

  Future<bool> _shouldPop() {
    if (!_skill.completed) {
      // check if the skill didn't completed schedule notification after 24 hours
      // to remind user to come back and continue learning this skill
      final tomorrow = NotificationService.tzDateTime(Duration(hours: 24));
      final notificationId = tomorrow.millisecond;
      final title = _skill.title;
      final body = TransUtil.trans("notification_complete_skill_specific");

      NotificationService.scheduleNotification(
        id: notificationId,
        title: title,
        body: body,
        payload: SkillsScreen.ROUTE_NAME,
        dateTime: tomorrow,
      );
    }
    Navigator.of(context).pop(_skill);
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _skill.title ?? TransUtil.trans("title_skills_screen"),
        ),
        actions: [
          IconButton(
            onPressed: _deleteSkill,
            icon: Icon(
              Icons.delete,
            ),
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: _shouldPop,
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (widget.skill.description != null &&
                  widget.skill.description.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(marginLarge),
                  margin: const EdgeInsets.all(marginLarge),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(radiusStandard),
                    ),
                    color: colorPrimaryLight,
                  ),
                  child: Text(
                    widget.skill?.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                      fontSize: fontSizeStandard,
                    ),
                  ),
                ),
              Text(
                TransUtil.trans("msg_instruction_skill_ball_representation"),
                style: TextStyle(color: Colors.grey),
              ),
              Container(
                height: size.height * 0.3,
                // backgroundColor: Colors.transparent,
                child: DragTarget<int>(
                  builder: (context, candidateData, rejectedData) => Stack(
                    alignment: Alignment.center,
                    children: [
                      ..._balls
                          .map((skill) => DraggableWidget(skill: skill))
                          .toList(),
                    ],
                  ),
                  onWillAccept: (data) => true,
                  onAccept: (data) {},
                ),
              ),
              // ),
              Container(
                height: size.height * 0.35,
                width: size.width * 0.6,
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      DragTarget<int>(
                        builder: (context, candidateData, rejectedData) =>
                            Stack(
                          children: [
                            InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () {
                                if (_skill.completedHours > 0) {
                                  _skill.completedHours--;
                                  _skill.completed =
                                      _skill.completedHours == _TOTAL_HOURS;
                                  setState(() {
                                    _initBalls();
                                  });
                                }
                              },
                              child: Container(
                                child: Image.asset(_jarImage),
                              ),
                            ),
                          ],
                        ),
                        onWillAccept: (data) => true,
                        onAccept: (data) {
                          setState(() {
                            _skill.completedHours++;
                            _skill.completed =
                                _skill.completedHours == _TOTAL_HOURS;
                            _skill.completedOn =
                                _skill.completed ? DateTime.now() : null;
                            _balls.removeLast();
                            print(
                                "rem hrs = ${_TOTAL_HOURS - _skill.completedHours}");
                          });
                        },
                      ),
                      SizedBox(
                        height: marginSmall,
                      ),
                      Text(
                        TransUtil.trans("hint_click_to_remove_balls"),
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                child: _skill.completed
                    ? Text(TransUtil.trans("msg_congrats_skill_accomplished"))
                    : Text(
                        "${_TOTAL_HOURS - _skill.completedHours}" +
                            " " +
                            TransUtil.trans("msg_skill_left_hours"),
                      ),
              ),
              SizedBox(
                height: marginStandard,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
