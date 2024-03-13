import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_task_planner/constants.dart';
import 'package:my_task_planner/models/user.dart';
import 'package:my_task_planner/screens/eisenhower_matrix_screen.dart';
import 'package:my_task_planner/screens/pomodoro_screen.dart';
import 'package:my_task_planner/screens/skills_screen.dart';
import 'package:my_task_planner/screens/tasks_screen.dart';
import 'package:my_task_planner/services/notification_service.dart';
import 'package:my_task_planner/utils/trans_util.dart';
import 'package:my_task_planner/widgets/drawer.dart';
import 'package:my_task_planner/widgets/quarter_circle.dart';

class HomeScreen extends StatefulWidget {
  final MyUser myUser;
  const HomeScreen({
    Key key,
    this.myUser,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MyUser get myUser => widget.myUser;

  @override
  void initState() {
    super.initState();
    print("initState: called");
    NotificationService.init(scheduled: true).then((value) {
      _scheduledDailyNotifications();
    }).catchError((error) {
      print("initState: $error");
    });
    _listenNotification();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _scheduledDailyNotifications() {
    final dateTimeMorning = NotificationService.tzTime(Time(7));

    final dateTimeEvening = NotificationService.tzTime(Time(22));
    print("morningNotificationId: $morningNotificationId, time: $dateTimeMorning");
    print("eveningNotificationId: $eveningNotificationId, time: $dateTimeEvening");
    NotificationService.scheduleDailyNotification(
      id: morningNotificationId,
      title: TransUtil.trans("app_name"),
      body: TransUtil.trans("notification_good_morning"),
      tzDateTime: dateTimeMorning,
    );

    NotificationService.scheduleDailyNotification(
      id: eveningNotificationId,
      title: TransUtil.trans("app_name"),
      body: TransUtil.trans("notification_good_evening"),
      tzDateTime: dateTimeEvening,
    );
  }

  void _listenNotification() => NotificationService.onNotifications.stream.listen(_onClickNotification);

  void _onClickNotification(String payload) {
    if (payload != null && payload.isNotEmpty) Navigator.of(context).pushNamed(payload);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final iconOffset = size.width * 0.1;
    final _isRTL = TransUtil.isEnLocale(context);



    return Scaffold(
      appBar: AppBar(
        title: Text(
          TransUtil.trans("app_name"),
        ),
      ),
      drawer: MyDrawer(),
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "${TransUtil.trans("label_hello")} ${myUser?.name ?? ""}",
              style: TextStyle(
                fontSize: fontSizeMedium,
              ),
            ),
            SizedBox(height: marginSmall),
            Text(
              TransUtil.trans(
                "msg_home_greeting",
              ),
              style: TextStyle(
                fontSize: fontSizeMedium,
              ),
            ),
            Spacer(
              flex: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  // first quarter [tasks section]
                  enableFeedback: false,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  // borderRadius: BorderRadius.only(topLeft: Radius.circular(500)),
                  onTap: () => Navigator.of(context).pushNamed(TasksScreen.ROUTE_NAME),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: size.width * 0.45,
                        height: size.width * 0.45,
                        child: QuarterCircle(
                          circleAlignment: _isRTL ? CircleAlignment.bottomRight : CircleAlignment.bottomLeft,
                          color: colorPrimary,
                        ),
                      ),
                      Positioned(
                        bottom: iconOffset,
                        right: _isRTL ? iconOffset : null,
                        left: _isRTL ? null : iconOffset,
                        child: Image.asset(
                          IMG_CLOCK,
                          width: size.width * 0.2,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  width: marginStandard,
                ),
                InkWell(
                  // second quarter [ pomodoro section]
                  enableFeedback: false,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  // borderRadius: BorderRadius.only(topLeft: Radius.circular(500)),
                  onTap: () => Navigator.of(context).pushNamed(PomodoroScreen.ROUTE_NAME),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: size.width * 0.45,
                        height: size.width * 0.45,
                        child: QuarterCircle(
                          circleAlignment: _isRTL ? CircleAlignment.bottomLeft : CircleAlignment.bottomRight,
                          color: colorPrimary,
                        ),
                      ),
                      Positioned(
                        bottom: iconOffset,
                        right: _isRTL ? null : iconOffset,
                        left: _isRTL ? iconOffset : null,
                        child: Image.asset(
                          IMG_POMODORO,
                          width: size.width * 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: marginStandard,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  // third quarter [ matrix section]
                  enableFeedback: false,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  // borderRadius: BorderRadius.only(topLeft: Radius.circular(500)),
                  onTap: () => Navigator.of(context).pushNamed(EisenhowerMatrixScreen.ROUTE_NAME),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: size.width * 0.45,
                        height: size.width * 0.45,
                        child: QuarterCircle(
                          circleAlignment: _isRTL ? CircleAlignment.topRight : CircleAlignment.topLeft,
                          color: colorPrimary,
                        ),
                      ),
                      Positioned(
                        top: iconOffset,
                        left: _isRTL ? null : iconOffset,
                        right: _isRTL ? iconOffset : null,
                        child: Image.asset(
                          IMG_MATRIX,
                          width: size.width * 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: marginStandard,
                ),
                InkWell(
                  // fourth quarter [ *** section]
                  enableFeedback: false,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  // borderRadius: BorderRadius.only(topLeft: Radius.circular(500)),
                  onTap: () => Navigator.of(context).pushNamed(SkillsScreen.ROUTE_NAME),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: size.width * 0.45,
                        height: size.width * 0.45,
                        child: QuarterCircle(
                          circleAlignment: _isRTL ? CircleAlignment.topLeft : CircleAlignment.topRight,
                          color: colorPrimary,
                        ),
                      ),
                      Positioned(
                        top: iconOffset,
                        right: _isRTL ? null : iconOffset,
                        left: _isRTL ? iconOffset : null,
                        child: Image.asset(
                          IMG_JAR,
                          width: size.width * 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Spacer(
              flex: 3,
            ),
          ],
        ),
      ),
    );
  }
}
