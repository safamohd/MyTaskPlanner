import 'package:flutter/material.dart';

import '../constants.dart';

class StandardButton extends StatelessWidget {
  final Function onButtonPressed;
  final String text;
  final bool isLoading;
  final double height;
  final double width;
  final TextStyle textStyle;
  final Color activeColor;
  final Color inactiveColor;

  StandardButton({
    @required this.text,
    this.isLoading = false,
    this.height = 45,
    this.width,
    this.textStyle,
    @required this.onButtonPressed,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      // height: height,
      width: width ?? size.width,
      decoration: BoxDecoration(
        color: isLoading || onButtonPressed == null
            ? inactiveColor ?? colorAccent.withAlpha(80)
            : activeColor ?? colorAccent,
        borderRadius: BorderRadius.all(
          Radius.circular(radiusStandard),
        ),
      ),
      child: isLoading
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  backgroundColor: colorPrimary,
                ),
              ),
            )
          : ButtonTheme(
              minWidth: double.infinity,
              height: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(radiusStandard)),
                child: TextButton(
                  onPressed: isLoading ? null : onButtonPressed,
                  child: Text(
                    text,
                    style: textStyle ??
                        TextStyle(
                          color: Colors.black87,
                        ),
                  ),
                ),
              ),
            ),
    );
  }
}
