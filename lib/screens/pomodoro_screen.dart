import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_task_planner/constants.dart';
import 'package:my_task_planner/services/notification_service.dart';
import 'package:my_task_planner/utils/dialog_util.dart';
import 'package:my_task_planner/utils/trans_util.dart';
import 'package:my_task_planner/widgets/clock_style.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:vibration/vibration.dart';

enum ActiveTimer { NONE, POMODORO_ON, POMODORO_PAUSED, BREAK_ON, BREAK_PAUSED }

class PomodoroScreen extends StatefulWidget {
  static const ROUTE_NAME = "/PomodoroScreen";
  const PomodoroScreen({Key key}) : super(key: key);

  @override
  _PomodoroScreenState createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  static const TAG = "PomodoroScreen: ";
  //static const _POMODORO_TIME = 25 * 60; // original time
  static const _POMODORO_TIME = 25; // ! debug
  //static const _BREAK_TIME = 5 * 60; // original time
   static const _BREAK_TIME = 5; // ! debug

  var _activeTimer = ActiveTimer.NONE;
  var _note = TransUtil.trans("hint_click_to_start_pomodoro");
  var _totalTimeInSec = 0;
  var _leftTimeInSec = 0;

  Timer _timer;

  void _startPomodoroTimer() {
    print("$TAG started pomodoro timer");
    const oneSec = const Duration(seconds: 1);
    _note = TransUtil.trans("hint_pomodoro_working_time_started");
    _totalTimeInSec = _POMODORO_TIME; // 25 minutes
    _leftTimeInSec = _leftPomodoroTimeInSec; // 25 minutes
    _activeTimer = ActiveTimer.POMODORO_ON;
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_leftTimeInSec == 0) {
          print("$TAG finished pomodoro timer");
          DialogUtil.showToast(TransUtil.trans("msg_pomodoro_working_time_finished"));
          _vibrate();
          _startBreakTimer();
          _showNotification(1111, TransUtil.trans("notification_pomodoro_working_time_finished"));
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _leftTimeInSec--; // decrease by 1 sec
          });
        }
      },
    );
  }

  void _startBreakTimer() {
    print("$TAG started break timer");
    const oneSec = const Duration(seconds: 1);
    _note = TransUtil.trans("hint_pomodoro_break_time_started");
    _totalTimeInSec = _BREAK_TIME; // 5 minutes break
    _leftTimeInSec = _leftBreakTimeInSec; // 5 minutes break
    _activeTimer = ActiveTimer.BREAK_ON;
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_leftTimeInSec == 0) {
          print("$TAG finished break timer");
          _activeTimer = ActiveTimer.NONE;
          DialogUtil.showToast(TransUtil.trans("msg_pomodoro_break_time_finished"));
          _note = TransUtil.trans("hint_click_to_start_pomodoro");
          _vibrate();
          _showNotification(2222, TransUtil.trans("notification_pomodoro_break_time_finished"));
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _leftTimeInSec--; // decrease by 1 sec
          });
        }
      },
    );
  }

  void _onTimerClick() {
    print("$TAG onTimerClick active timer is $_activeTimer");
    switch (_activeTimer) {
      case ActiveTimer.POMODORO_ON:
        _activeTimer = ActiveTimer.POMODORO_PAUSED;
        DialogUtil.showToast(TransUtil.trans("msg_pomodoro_paused"));
        _note = TransUtil.trans("hint_pomodoro_timer_paused");
        _timer.cancel();
        setState(() {});
        break;
      case ActiveTimer.BREAK_ON:
        _activeTimer = ActiveTimer.BREAK_PAUSED;
        DialogUtil.showToast(TransUtil.trans("msg_pomodoro_paused"));
        _note = TransUtil.trans("hint_pomodoro_timer_paused");
        _timer.cancel();
        setState(() {});
        break;
      case ActiveTimer.NONE:
      case ActiveTimer.POMODORO_PAUSED:
        _startPomodoroTimer();
        break;
      case ActiveTimer.BREAK_PAUSED:
        _startBreakTimer();
        break;
    }
  }

  void _showNotification(int id, String body) {
    NotificationService.showNotification(
      id: id,
      title: TransUtil.trans("title_pomodoro"),
      body: body,
      payload: PomodoroScreen.ROUTE_NAME,
    );
  }

  void _resetTimer() {
    setState(() {
      _timer.cancel();
      _activeTimer = ActiveTimer.NONE;
      DialogUtil.showToast(TransUtil.trans("msg_pomodoro_canceled"));
      _note = TransUtil.trans("hint_click_to_start_pomodoro");
      _totalTimeInSec = 0;
      _leftTimeInSec = 0;
    });
  }

  void _vibrate() async {
    final hasVibrator = await Vibration.hasVibrator();
    print("$TAG hasVibrator: $hasVibrator");
    if (hasVibrator) {
      Vibration.vibrate(duration: 1000);
    }
  }

  /// returns the remaining time percent to show on the CircularPercentIndicator
  double get _leftTimePercent {
    return _activeTimer == ActiveTimer.NONE ? 0 : 1 - _leftTimeInSec / _totalTimeInSec;
  }

  /// returns the minutes part of the remaining time as string value
  String get _remainingMinString {
    final result = _leftTimeInSec ~/ 60;
    return result > 9 ? result.toString() : "0" + result.toString();
  }

  /// returns the seconds part of the remaining time as string value
  String get _remainingSecString {
    final result = _leftTimeInSec % 60;
    return result > 9 ? result.toString() : "0" + result.toString();
  }

  /// returns the total time in seconds if the timer starting from zero
  /// otherwise returns the last value in case if the timer starting after pause
  int get _leftPomodoroTimeInSec {
    return _leftTimeInSec != 0 ? _leftTimeInSec : _POMODORO_TIME;
  }

  /// returns the break time in seconds if the timer starting from zero
  /// otherwise returns the last value in case if the timer starting after pause
  int get _leftBreakTimeInSec {
    return _leftTimeInSec != 0 ? _leftTimeInSec : _BREAK_TIME;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          TransUtil.trans("title_pomodoro"),
        ),
        actions: [
          IconButton(
            onPressed: _resetTimer,
            icon: Icon(
              Icons.restore_outlined,
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(marginStandard),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(marginLarge),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(radiusStandard),
                    ),
                    color: colorPrimaryLight,
                  ),
                  child: Text(
                    _note,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: colorPrimary,
                      fontSize: fontSizeMedium,
                    ),
                  ),
                ),
                SizedBox(
                  height: marginStandard,
                ),
                Visibility(
                  visible: _leftTimeInSec > 0,
                  child: Column(
                    children: [
                      Text(
                        _remainingMinString + ":" + _remainingSecString,
                        style: TextStyle(
                          fontFamily: "Digital",
                          fontWeight: FontWeight.bold,
                          color: colorPrimary,
                          fontSize: fontSizeLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Spacer(),
            ClockStyleContainer(
              child: Center(
                child: FittedBox(
                  child: CircularPercentIndicator(
                    radius: size.width * 0.8,
                    lineWidth: 13.0,
                    percent: _leftTimePercent,
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: Colors.red,
                    center: InkWell(
                      onTap: _onTimerClick ,
                      enableFeedback: false,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      child: Image.asset(
                        IMG_POMODORO_LARGE,
                        width: size.width * 0.6,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
