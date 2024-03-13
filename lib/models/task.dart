import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

Task taskFromJson(String str) => Task.fromJson(json.decode(str));

Task getTaskAt(List<Task> tasksList, int hour) =>
    tasksList.singleWhere((element) => element.hour == hour, orElse: () => null);

String taskToJson(Task data) => json.encode(data.toJson());

List<Task> tasksFromQuerySnapShot(QuerySnapshot snapshot) =>
    List<Task>.generate(snapshot.size, (index) => Task.fromJson(snapshot.docs.elementAt(index).data())).toList();

class Task {
  Task({
    this.id,
    this.userId,
    this.imageId,
    this.description,
    this.date,
    this.hour,
    this.completed = false,
  });

  String id;
  String userId;
  String imageId;
  String description;
  String date;
  int hour;
  bool completed;

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json["id"],
        userId: json["user_id"],
        imageId: json["image_id"],
        description: json["description"],
        date: json["date"],
        hour: json["hour"],
        completed: json.containsKey("completed") ? json["completed"] : false,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "image_id": imageId,
        "description": description,
        "date": date,
        "hour": hour,
        "completed": completed,
      };
}
