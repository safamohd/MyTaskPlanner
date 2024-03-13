import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:my_task_planner/constants.dart';
import 'package:my_task_planner/landing_screen.dart';
import 'package:my_task_planner/utils/shared_pref.dart';
import 'package:my_task_planner/utils/trans_util.dart';

class IntroScreen extends StatefulWidget {
  IntroScreen({Key key}) : super(key: key);

  @override
  IntroScreenState createState() => new IntroScreenState();
}

// ------------------ Default config ------------------
class IntroScreenState extends State<IntroScreen> {
  List<Slide> slides = [];

  @override
  void initState() {
    super.initState();

    slides.add(
      new Slide(
        title: TransUtil.trans("title_tasks_screen"),
        description: TransUtil.trans("tutorial_description_1"),
        pathImage: IMG_CLOCK,
        backgroundColor: Color(0xfff5a623),
      ),
    );
    slides.add(
      new Slide(
        title: TransUtil.trans("title_pomodoro"),
        description: TransUtil.trans("tutorial_description_2"),
        pathImage: IMG_POMODORO,
        backgroundColor: Color(0xff203152),
      ),
    );
    slides.add(
      new Slide(
        title: TransUtil.trans("title_eisenhower_matrix_screen"),
        description: TransUtil.trans("tutorial_description_3"),
        pathImage: IMG_MATRIX,
        backgroundColor: Color(0xff9932CC),
      ),
    );
    slides.add(
      new Slide(
        title: TransUtil.trans("title_skills_screen"),
        description: TransUtil.trans("tutorial_description_4"),
        pathImage: IMG_JAR_FULL,
        backgroundColor: Color(0xff00AE87),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void onDonePress() {
    SharedPrefUtil.setFirstOpen(false);
    if (Navigator.of(context).canPop())
      Navigator.of(context).pop();
    else
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (builder) => LandingScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return new IntroSlider(
      slides: this.slides,
      onDonePress: this.onDonePress,
    );
  }
}
