import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_task_planner/constants.dart';

class DraggableWidget extends StatelessWidget {
  final Widget skill;

  const DraggableWidget({
    Key key,
    @required this.skill,
  }) : super(key: key);

  static double size = 150;

  int get _randomNumber {
    var rng = new Random();
    return rng.nextInt(7);
  }

  @override
  Widget build(BuildContext context) => Draggable<int>(
        data: 1,
        feedback: buildImage(),
        child: buildImage(),
        childWhenDragging: Container(height: size),
      );

  Widget buildImage() => Container(
        height: size,
        width: size,
        child: skill,
      );
}
