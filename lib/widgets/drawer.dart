import 'package:flutter/material.dart';
import 'package:my_task_planner/screens/eisenhower_matrix_screen.dart';
import 'package:my_task_planner/screens/pomodoro_screen.dart';
import 'package:my_task_planner/screens/skills_screen.dart';
import 'package:my_task_planner/screens/tasks_screen.dart';
import 'package:my_task_planner/utils/trans_util.dart';
import 'package:my_task_planner/widgets/lang_picker.dart';
import 'package:provider/provider.dart';
import 'package:my_task_planner/constants.dart';
import 'package:my_task_planner/services/auth_service.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key key}) : super(key: key);

  void _goTo(BuildContext context, String routeName) {
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final _authService = context.watch<AuthService>();
    final _myUser = _authService.myUser;
    return Container(
      width: size.width * 0.8,
      height: size.height,
      color: Colors.white,
      // padding: const EdgeInsets.all(marginLarge),
      child: Column(
        children: [
          Container(
            height: size.height * 0.2,
            color: colorPrimary,
            padding: const EdgeInsets.all(marginLarge),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(_myUser?.gender == "female" ? IMG_FEMALE : IMG_MALE),
                  ),
                ),
                SizedBox(
                  width: marginStandard,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _myUser?.name ?? "",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontSizeStandard,
                      ),
                    ),
                    SizedBox(
                      height: marginSmall,
                    ),
                    Text(
                      _myUser?.email ?? "",
                      style: TextStyle(),
                    )
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      TransUtil.trans("title_tasks_screen"),
                    ),
                    onTap: () => _goTo(context, TasksScreen.ROUTE_NAME),
                  ),
                  ListTile(
                    title: Text(
                      TransUtil.trans("title_pomodoro"),
                    ),
                    onTap: () => _goTo(context, PomodoroScreen.ROUTE_NAME),
                  ),
                  ListTile(
                    title: Text(
                      TransUtil.trans("title_eisenhower_matrix_screen"),
                    ),
                    onTap: () => _goTo(context, EisenhowerMatrixScreen.ROUTE_NAME),
                  ),
                  ListTile(
                    title: Text(
                      TransUtil.trans("title_skills_screen"),
                    ),
                    onTap: () => _goTo(context, SkillsScreen.ROUTE_NAME),
                  ),
                  ListTile(
                    title: Text(
                      TransUtil.trans("btn_logout"),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      _authService.logout();
                    },
                  ),
                ],
              ),
            ),
          ),
          LangPicker(
            popOnTap: true,
          ),
          SizedBox(
            height: marginLarge,
          ),
        ],
      ),
    );
  }
}
