import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_task_planner/models/skill.dart';
import 'package:my_task_planner/models/task.dart';
import 'package:my_task_planner/models/todo.dart';
import 'package:my_task_planner/models/user.dart';
import 'package:my_task_planner/utils/date_util.dart';

class DBService {
  static const TAG = "DBService:";

  static const _COL_USERS = "users";
  static const _COL_TASKS = "tasks";
  static const _COL_SKILLS = "skills";
  static const _COL_TODOS = "todos";

  final _auth = FirebaseAuth.instance;
  final _dbRef = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser?.uid;

  Future<dynamic> createNewUser(MyUser myUser) async {
    print("$TAG creating new user data ${myUser.toString()}");
    return _dbRef.collection(_COL_USERS).doc(myUser.id).set(myUser.toJson()).then((value) {
      print("$TAG created new user in db");
    }).catchError((error) {
      print("$TAG $error");
      return Future.value(null);
    });
  }

  Future<MyUser> getUserData(User user) async {
    print("$TAG retrieving user data for user ${user.uid}");
    MyUser myUser;
    await _dbRef.collection(_COL_USERS).doc(user?.uid).get().then((value) {
      myUser = MyUser.fromJson(value.data());
      print("$TAG retrieved user data from db: ${myUser.toJson()}");
    }).catchError((error) {
      print("$TAG $error");
      return Future.value(null);
    });
    return myUser;
  }

  Future<Task> addNewTask(Task task) async {
    print("$TAG creating new task ${task.toJson()}");
    // ensure to override tasks with same date to avoid error
    final idPostfix = task.date + task.hour.toString();
    final id = _uid.substring(0, 15) + idPostfix;
    task.id = id;
    task.userId = _uid;
    _dbRef.collection(_COL_TASKS).doc(id).set(task.toJson()).then((value) {
      print("$TAG created new tasks in db");
    }).catchError((error) {
      print("$TAG $error");
      return Future.value(null);
    });
    return getTaskById(task.id);
  }

  Future<bool> deleteTask(Task task) async {
    print("$TAG deleting task ${task.toJson()}");
    _dbRef.collection(_COL_TASKS).doc(task.id).delete().then((value) {
      print("$TAG deleted task");
    }).catchError((error) {
      print("$TAG $error");
      return Future.value(false);
    });
    return Future.value(true);
  }

  Future<Task> getTaskById(String id) async {
    print("$TAG getting task by id $id");
    Task task = Task();
    await _dbRef.collection(_COL_TASKS).doc(id).get().then((value) {
      print("$TAG retrieved task: $id");
      task = Task.fromJson(value.data());
    }).catchError((error) {
      print("$TAG $error");
      return Future.value(null);
    });
    return task;
  }

  Future<List<Task>> getTasksOn(DateTime dateTime) async {
    final id = _auth.currentUser?.uid;
    final dateString = MyDateUtil.toStringDate(dateTime);

    print("$TAG retrieving tasks for user $id..");
    List<Task> tasks;
    await _dbRef
        .collection(_COL_TASKS)
        .where("user_id", isEqualTo: id)
        .where("date", isEqualTo: dateString)
        .get()
        .then((value) {
      print("$TAG retrieved tasks for user $id");
      tasks = tasksFromQuerySnapShot(value);
    }).catchError((error) => print("$TAG $error"));
    return tasks;
  }

  Future<Task> markTaskAsCompleted(String id) async {
    print("$TAG marking task as completed for $id");
    Task task = await getTaskById(id);
    Map<String, Object> newData = task.toJson();
    newData['completed'] = true;
    await _dbRef.collection(_COL_TASKS).doc(id).update(newData).then((value) {
      print("$TAG updateed task: $id");
    }).catchError((error) {
      print("$TAG $error");
      return Future.value(null);
    });
    return task;
  }

  Future<Todo> addNewTodo(Todo todo) async {
    print("$TAG creating new todo ${todo.toJson()}");
    final docId = _dbRef.collection(_COL_TODOS).doc().id;
    todo.id = docId;
    todo.userId = _uid;
    todo.completed = false;
    todo.createdOn = DateTime.now();
    _dbRef.collection(_COL_TODOS).doc(docId).set(todo.toJson()).then((value) {
      print("$TAG created new todos in db");
    }).catchError((error) {
      print("$TAG $error");
      return Future.value(null);
    });
    return getTodoById(docId);
  }

  Future<bool> deleteTodo(String id) async {
    print("$TAG deleting todo $id");
    _dbRef.collection(_COL_TODOS).doc(id).delete().then((value) {
      print("$TAG deleted todo");
    }).catchError((error) {
      print("$TAG $error");
      return Future.value(false);
    });
    return Future.value(true);
  }

  Future<Todo> getTodoById(String id) async {
    print("$TAG getting todo by id $id");
    Todo todo = Todo();
    await _dbRef.collection(_COL_TODOS).doc(id).get().then((value) {
      print("$TAG retrieved todo: $id");
      todo = Todo.fromJson(value.data());
    }).catchError((error) {
      print("$TAG $error");
      return Future.value(null);
    });
    return todo;
  }

  Future<Todo> markTodoAsCompleted(String id) async {
    print("$TAG getting todo by id $id");
    Todo todo = await getTodoById(id);
    Map<String, Object> newData = todo.toJson();
    newData['completed'] = true;
    newData['completed_on'] = DateTime.now().toString();
    await _dbRef.collection(_COL_TODOS).doc(id).update(newData).then((value) {
      print("$TAG updateed todo: $id");
  }).catchError((error) {
  print("$TAG $error");
  return Future.value(null);
  });
  return todo;
  }

  Future<List<Todo>> getAllTodos() async {
    final id = _auth.currentUser?.uid;

    print("$TAG retrieving todos for user $id..");
    List<Todo> todos;
    await _dbRef.collection(_COL_TODOS).where("user_id", isEqualTo: id).get().then((value) {
      print("$TAG retrieved todos for user $id");
      todos = todosFromQuerySnapShot(value);
    }).catchError((error) => print("$TAG $error"));
    return todos;
  }

  Future<Skill> addNewSkill(Skill skill) async {
    print("$TAG creating new skill ${skill.toJson()}");
    final docId = _dbRef.collection(_COL_SKILLS).doc().id;
    skill.id = docId;
    skill.userId = _uid;
    skill.completed = false;
    skill.createdOn = DateTime.now();
    skill.completedHours = 0;
    _dbRef.collection(_COL_SKILLS).doc(docId).set(skill.toJson()).then((value) {
      print("$TAG created new skill in db");
    }).catchError((error) {
      print("$TAG $error");
      return Future.value(null);
    });
    return getSkillById(docId);
  }

  Future<bool> deleteSkill(String id) async {
    print("$TAG deleting skill $id");
    _dbRef.collection(_COL_SKILLS).doc(id).delete().then((value) {
      print("$TAG deleted skill");
    }).catchError((error) {
      print("$TAG $error");
      return Future.value(false);
    });
    return Future.value(true);
  }

  Future<Skill> updateSkill(Skill skill) async {
    print("$TAG updating new skill ${skill.toJson()}");
    await _dbRef.collection(_COL_SKILLS).doc(skill.id).update(skill.toJson()).then((value) {
      print("$TAG updated skill");
    }).catchError((error) {
      print("$TAG $error");
      return Future.value(null);
    });
    return skill;
  }

  Future<Skill> getSkillById(String id) async {
    print("$TAG getting skill by id $id");
    Skill skill = Skill();
    await _dbRef.collection(_COL_SKILLS).doc(id).get().then((value) {
      print("$TAG retrieved skill: $id");
      skill = Skill.fromJson(value.data());
    }).catchError((error) {
      print("$TAG $error");
      return Future.value(null);
    });
    return skill;
  }

  Future<List<Skill>> getAllSkills() async {
    final id = _auth.currentUser?.uid;

    print("$TAG retrieving skills for user $id..");
    List<Skill> skills;
    await _dbRef.collection(_COL_SKILLS).where("user_id", isEqualTo: id).get().then((value) {
      print("$TAG retrieved todos for user $id");
      skills = skillsFromQuerySnapShot(value);
    }).catchError((error) => print("$TAG $error"));
    return skills;
  }
}
