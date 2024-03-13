import 'package:flutter/material.dart';
import 'package:my_task_planner/constants.dart';
import 'package:my_task_planner/models/todo.dart';
import 'package:my_task_planner/utils/trans_util.dart';

enum MatrixCardCategory { IMPORTANCE_1, IMPORTANCE_2, IMPORTANCE_3, IMPORTANCE_4 }

class MatrixCard extends StatelessWidget {
  final MatrixCardCategory matrixCardCategory;
  final Color color;
  final String title;
  final String subTitle;
  final List<Todo> items;
  final ValueSetter<String> onCompleteTap;
  final ValueSetter<String> onTodoTap;
  final Function onAddNewItemTap;
  final bool isLoading;

  const MatrixCard({
    Key key,
    this.matrixCardCategory,
    @required this.color,
    @required this.title,
    this.items,
    this.subTitle,
    this.onCompleteTap,
    this.onAddNewItemTap,
    this.isLoading = false,
    this.onTodoTap,
  }) : super(key: key);

  BorderRadiusGeometry get cardBorderRadius {
    switch (matrixCardCategory) {
      case MatrixCardCategory.IMPORTANCE_1:
        return BorderRadius.only(
          topLeft: Radius.circular(radiusLarge),
          bottomRight: Radius.circular(radiusLarge),
        );
      case MatrixCardCategory.IMPORTANCE_2:
        return BorderRadius.only(
          topRight: Radius.circular(radiusLarge),
          bottomLeft: Radius.circular(radiusLarge),
        );
      case MatrixCardCategory.IMPORTANCE_3:
        return BorderRadius.only(
          bottomLeft: Radius.circular(radiusLarge),
          topRight: Radius.circular(radiusLarge),
        );
      case MatrixCardCategory.IMPORTANCE_4:
        return BorderRadius.only(
          bottomRight: Radius.circular(radiusLarge),
          topLeft: Radius.circular(radiusLarge),
        );
      default:
        return BorderRadius.all(
          Radius.circular(radiusLarge),
        );
    }
  }

  BorderRadiusGeometry get headerBorderRadius {
    switch (matrixCardCategory) {
      case MatrixCardCategory.IMPORTANCE_1:
        return BorderRadius.only(
          topLeft: Radius.circular(radiusLarge),
        );
      case MatrixCardCategory.IMPORTANCE_2:
        return BorderRadius.only(
          topRight: Radius.circular(radiusLarge),
        );
      case MatrixCardCategory.IMPORTANCE_3:
        return BorderRadius.only(
          topRight: Radius.circular(radiusLarge),
        );
      case MatrixCardCategory.IMPORTANCE_4:
        return BorderRadius.only(
          topLeft: Radius.circular(radiusLarge),
        );
      default:
        return BorderRadius.all(
          Radius.circular(radiusLarge),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: cardBorderRadius,
        color: color,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            // title & sub title continer
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: headerBorderRadius,
              color: Color.fromRGBO(255, 255, 255, 90),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: marginSmall,
                  ),
                  Text(
                    subTitle,
                    style: TextStyle(
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: marginStandard,
          ),
          Expanded(
            child: Container(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : items == null || items.isEmpty
                      ? Center(
                          // no items clickable text
                          child: InkWell(
                            onTap: onAddNewItemTap,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    TransUtil.trans("msg_no_items"),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (ctx, index) {
                            return ListTile(
                              onTap: () => onTodoTap(items[index].id),
                              leading: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: items[index].title,
                                      style: TextStyle(
                                        color: items[index].completed ? Colors.blueGrey : Colors.black87,
                                        decoration:
                                            items[index].completed ? TextDecoration.lineThrough : TextDecoration.none,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: IconButton(
                                onPressed: () => items[index].completed ? null : onCompleteTap(items[index].id),
                                icon: Icon(
                                  items[index].completed
                                      ? Icons.radio_button_checked_outlined
                                      : Icons.radio_button_unchecked_outlined,
                                  color: items[index].completed ? Colors.blueGrey : Colors.black45,
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
