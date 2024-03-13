import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_task_planner/constants.dart';

class LangPicker extends StatelessWidget {
  final bool popOnTap;

  const LangPicker({Key key, this.popOnTap = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          LangButton(
            isSelected: context.locale == Locale(langArCode),
            text: "العربية",
            onPressed: () {
              context.setLocale(Locale(langArCode));
              if (popOnTap) Navigator.of(context).pop();
            },
          ),
          LangButton(
            isSelected: context.locale == Locale(langEnCode),
            text: "English",
            onPressed: () {
              context.setLocale(Locale(langEnCode));
              if (popOnTap) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class LangButton extends StatelessWidget {
  final Function onPressed;
  final String text;
  final bool isSelected;

  LangButton({@required this.text, @required this.isSelected, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(radiusStandard),
        ),
        color: isSelected ? colorPrimaryDark : colorPrimaryLight,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(
          Radius.circular(radiusStandard),
        ),
        child: TextButton(
          onPressed: onPressed,
          child: Text(
            text,
            style: TextStyle(color: isSelected ? colorPrimaryLight : colorPrimaryDark),
          ),
        ),
      ),
    );
  }
}
