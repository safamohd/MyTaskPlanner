import 'package:flutter/material.dart';
import 'package:my_task_planner/constants.dart';
import 'package:my_task_planner/models/todo.dart';
import 'package:my_task_planner/services/database_service.dart';
import 'package:my_task_planner/utils/dialog_util.dart';
import 'package:my_task_planner/utils/trans_util.dart';
import 'package:my_task_planner/widgets/card_matrix.dart';

class EisenhowerMatrixScreen extends StatefulWidget {
  static const ROUTE_NAME = "/EisenhowerMatrixScreen";
  const EisenhowerMatrixScreen({Key key}) : super(key: key);

  @override
  _EisenhowerMatrixScreenState createState() => _EisenhowerMatrixScreenState();
}

class _EisenhowerMatrixScreenState extends State<EisenhowerMatrixScreen> {
  final _dbService = DBService();
  List<Todo> _todosList = [];
  var _isLoadingCard = [false, false, false, false];
  var _isLoading = false;
  var testVar;

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  set isLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  void setLoadingCard(bool loading, int index) {
    setState(() {
      _isLoadingCard[index] = loading;
    });
  }

  void fetchData() async {
    isLoading = true;
    _todosList = await _dbService.getAllTodos();
    isLoading = false;
  }

  void _addNewTodo(int importance) async {
    print("addNewTodo clicked importance: $importance");

    final result = await DialogUtil.showNewTodoDialog(context, importance);
    // ignore if user dismissed the dialog without submitting any value
    if (result == null) return;

    if (importance == null) importance = result.importance;

    if (importance != null) setLoadingCard(true, importance - 1);
    final addedTodo = await _dbService.addNewTodo(result);
    if (addedTodo == null) {
      DialogUtil.showToast(TransUtil.trans("error_adding_todo"));
      if (importance != null) setLoadingCard(false, importance - 1);
      return;
    }
    if (importance != null) setLoadingCard(false, importance - 1);
    setState(() => _todosList.add(addedTodo));
  }

  void _markAsComplete(String id) async {
    print("completed $id");
    final todo = getTodoById(_todosList, id);
    setState(() {
      todo.completed = true;
      todo.completedOn = DateTime.now();
    });
    final result = await _dbService.markTodoAsCompleted(id);
    if (result == null) {
      setState(() {
        todo.completed = false;
        todo.completedOn = null;
      });
      // DialogUtil.showToast(TransUtil.trans("error_updating_todo_status"));
      DialogUtil.showToast(TransUtil.trans("error_occurerd_check_internet_connection"));
    }
  }

  void _deleteTodo(String id) async {
    final todo = getTodoById(_todosList, id);
    setState(() {
      _todosList.removeWhere((element) => element.id == id);
    });
    final deleted = await _dbService.deleteTodo(id);
    // show error message in case the task couldn't be deleted
    if (!deleted) {
      DialogUtil.showToast(TransUtil.trans("error_deleting_todo"));
      _todosList.add(todo);
    }
  }

  void _showTodoDetails(String id) async {
    DialogUtil.showTodoDetailsDialog(
      context,
      getTodoById(_todosList, id),
      onDeleteTap: (id) => _deleteTodo(id),
      onMarkAsCompleted: (id) => _markAsComplete(id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          TransUtil.trans("title_eisenhower_matrix_screen"),
        ),
        actions: [
          IconButton(
            onPressed: () => _addNewTodo(null),
            icon: Icon(
              Icons.add_outlined,
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(marginStandard),
        child: Column(
          children: [
            Flexible(
              flex: 1,
              child: Container(
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: MatrixCard(
                        isLoading: (_isLoadingCard[0] || _isLoading) || false,
                        color: Colors.lightBlue,
                        title: TransUtil.trans("title_matrix_card_1"),
                        subTitle: TransUtil.trans("subtitle_matrix_card_1"),
                        matrixCardCategory: MatrixCardCategory.IMPORTANCE_1,
                        items: getTodosByImportance(_todosList, 1),
                        onCompleteTap: (id) => _markAsComplete(id),
                        onAddNewItemTap: () => _addNewTodo(1),
                        onTodoTap: (id) => _showTodoDetails(id),
                      ),
                    ),
                    // VerticalDivider(
                    //   thickness: 1,
                    //   color: colorPrimary,
                    // ),
                    SizedBox(
                      width: marginStandard,
                    ),
                    Flexible(
                      flex: 1,
                      child: MatrixCard(
                        isLoading: (_isLoadingCard[1] || _isLoading) || false,
                        color: Colors.blueAccent,
                        title: TransUtil.trans("title_matrix_card_2"),
                        subTitle: TransUtil.trans("subtitle_matrix_card_2"),
                        matrixCardCategory: MatrixCardCategory.IMPORTANCE_2,
                        onCompleteTap: (id) => _markAsComplete(id),
                        onAddNewItemTap: () => _addNewTodo(2),
                        onTodoTap: (id) => _showTodoDetails(id),
                        items: getTodosByImportance(_todosList, 2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Divider(
            //   thickness: 1.0,
            //   color: colorPrimary,
            // ),
            SizedBox(
              height: marginStandard,
            ),
            Flexible(
              flex: 1,
              child: Container(
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: MatrixCard(
                        isLoading: (_isLoadingCard[2] || _isLoading) || false,
                        color: Colors.green,
                        title: TransUtil.trans("title_matrix_card_3"),
                        subTitle: TransUtil.trans("subtitle_matrix_card_3"),
                        matrixCardCategory: MatrixCardCategory.IMPORTANCE_3,
                        onCompleteTap: (id) => _markAsComplete(id),
                        onAddNewItemTap: () => _addNewTodo(3),
                        onTodoTap: (id) => _showTodoDetails(id),
                        items: getTodosByImportance(_todosList, 3),
                      ),
                    ),
                    // VerticalDivider(
                    //   thickness: 1,
                    //   color: colorPrimary,
                    // ),
                    SizedBox(
                      width: marginStandard,
                    ),
                    Flexible(
                      flex: 1,
                      child: MatrixCard(
                        isLoading: (_isLoadingCard[3] || _isLoading) ?? false,
                        color: Colors.amber,
                        title: TransUtil.trans("title_matrix_card_4"),
                        subTitle: TransUtil.trans("subtitle_matrix_card_4"),
                        matrixCardCategory: MatrixCardCategory.IMPORTANCE_4,
                        onCompleteTap: (id) => _markAsComplete(id),
                        onAddNewItemTap: () => _addNewTodo(4),
                        onTodoTap: (id) => _showTodoDetails(id),
                        items: getTodosByImportance(_todosList, 4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: marginStandard,
            ),
          ],
        ),
      ),
    );
  }
}
