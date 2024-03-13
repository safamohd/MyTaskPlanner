import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_task_planner/constants.dart';

class ClockStyleContainer extends StatelessWidget {
  const ClockStyleContainer({Key key, this.child}) : super(key: key);
  final Widget child;

  Widget _buildTaskContainer(int hour12Format) {
    var degrees = 0;
    Widget clockNumberPlaceholder = Divider(
      thickness: 3,
      height: 5,
      color: colorPrimaryDark,
    );
    switch (hour12Format) {
      case 12:
      case 6:
        degrees = 90;
        break;
      case 2:
      case 8:
        degrees = 150;
        break;
      case 4:
      case 10:
        degrees = 30;
        break;
      case 5:
      case 11:
        degrees = 60;
        break;
      case 1:
      case 7:
        degrees = 120;
        break;
    }
    return Transform.rotate(
      angle: degrees * math.pi / 180,
      child: clockNumberPlaceholder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final clockOffset = size.width * 0.20;
    final width = size.width;
    return Container(
      width: width,
      height: width,
      child: Stack(
        children: [
          Positioned(
            top: clockOffset,
            bottom: clockOffset,
            right: clockOffset,
            left: clockOffset,
            child: child,
          ),
          Positioned(
            // 12 o'clock
            top: width * 0.03,
            left: width * 0.45,
            right: width * 0.45,
            height: width * 0.10, // width - (leftOffset + rightOffset)
            child: Container(
              child: _buildTaskContainer(12),
            ),
          ),
          Positioned(
            // 1 o'clock
            top: width * 0.07,
            left: width * 0.65,
            right: width * 0.25,
            height: width * 0.10, // width - (leftOffset + rightOffset)
            child: _buildTaskContainer(1),
          ),
          Positioned(
            // 2 o'clock
            top: width * 0.20,
            left: width * 0.80,
            right: width * 0.10,
            height: width * 0.10, // width - (leftOffset + rightOffset)
            child: _buildTaskContainer(2),
          ),
          Positioned(
            // 3 o'clock
            top: width * 0.45,
            left: width * 0.87,
            right: width * 0.03,
            height: width * 0.10, // width - (leftOffset + rightOffset)
            child: _buildTaskContainer(3),
          ),
          Positioned(
            // 4 o'clock
            bottom: width * 0.20,
            left: width * 0.80,
            right: width * 0.10,
            height: width * 0.10, // width - (leftOffset + rightOffset)
            child: _buildTaskContainer(4),
          ),
          Positioned(
            // 5 o'clock
            bottom: width * 0.07,
            left: width * 0.65,
            right: width * 0.25,
            height: width * 0.10, // width - (leftOffset + rightOffset)
            child: _buildTaskContainer(5),
          ),
          Positioned(
            // 6 o'clock
            bottom: width * 0.03,
            left: width * 0.45,
            right: width * 0.45,
            height: width * 0.10, // width - (leftOffset + rightOffset)
            child: _buildTaskContainer(6),
          ),
          Positioned(
            // 7 o'clock
            bottom: width * 0.07,
            right: width * 0.65,
            left: width * 0.25,
            height: width * 0.10, // width - (leftOffset + rightOffset)
            child: _buildTaskContainer(7),
          ),
          Positioned(
            // 8 o'clock
            bottom: width * 0.20,
            right: width * 0.80,
            left: width * 0.10,
            height: width * 0.10, // width - (leftOffset + rightOffset)
            child: _buildTaskContainer(8),
          ),
          Positioned(
            // 9 o'clock
            top: width * 0.45,
            right: width * 0.87,
            left: width * 0.03,
            height: width * 0.10, // width - (leftOffset + rightOffset)
            child: _buildTaskContainer(9),
          ),
          Positioned(
            // 10 o'clock
            top: width * 0.20,
            right: width * 0.80,
            left: width * 0.10,
            height: width * 0.10, // width - (leftOffset + rightOffset)
            child: _buildTaskContainer(10),
          ),
          Positioned(
            // 11 o'clock
            top: width * 0.07,
            right: width * 0.65,
            left: width * 0.25,
            height: width * 0.10, // width - (leftOffset + rightOffset)
            child: _buildTaskContainer(11),
          ),
        ],
      ),
    );
  }
}
