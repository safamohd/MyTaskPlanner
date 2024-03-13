import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

Todo todoFromJson(String str) => Todo.fromJson(json.decode(str));

String todoToJson(Todo data) => json.encode(data.toJson());

List<Todo> todosFromQuerySnapShot(QuerySnapshot snapshot) =>
    List<Todo>.generate(snapshot.size, (index) => Todo.fromJson(snapshot.docs.elementAt(index).data())).toList();

List<Todo> getTodosByImportance(List<Todo> todos, int importance) =>
    todos.where((element) => element.importance == importance).toList();

Todo getTodoById(List<Todo> todos, String id) => todos.singleWhere((element) => element.id == id, orElse: () => null);

class Todo {
  Todo({
    this.id,
    this.userId,
    this.title,
    this.description,
    this.importance,
    this.completed,
    this.createdOn,
    this.completedOn,
  });

  String id;
  String userId;
  String title;
  String description;
  int importance;
  bool completed;
  DateTime createdOn;
  DateTime completedOn;

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
        id: json["id"],
        userId: json["user_id"],
        title: json["title"],
        description: json["description"],
        importance: json["importance"],
        completed: json["completed"],
        createdOn: json["created_on"] == null ? null : DateTime.parse(json["created_on"]),
        completedOn: json["completed_on"] == null ? null : DateTime.parse(json["completed_on"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "title": title,
        "description": description,
        "importance": importance,
        "completed": completed,
        "created_on": createdOn?.toString(),
        "completed_on": completedOn?.toString(),
      };
}
