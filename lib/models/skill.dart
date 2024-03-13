import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

Skill skillFromJson(String str) => Skill.fromJson(json.decode(str));

String skillToJson(Skill data) => json.encode(data.toJson());

List<Skill> skillsFromQuerySnapShot(QuerySnapshot snapshot) =>
    List<Skill>.generate(snapshot.size, (index) => Skill.fromJson(snapshot.docs.elementAt(index).data())).toList();

Skill getSkillById(List<Skill> skills, String id) =>
    skills.singleWhere((element) => element.id == id, orElse: () => null);

class Skill {
  Skill({
    this.id,
    this.userId,
    this.title,
    this.description,
    this.completedHours,
    this.completed,
    this.createdOn,
    this.completedOn,
  });

  String id;
  String userId;
  String title;
  String description;
  int completedHours;
  bool completed;
  DateTime createdOn;
  DateTime completedOn;

  factory Skill.from(Skill other) => Skill(
        id: other.id,
        userId: other.userId,
        title: other.title,
        description: other.description,
        completedHours: other.completedHours,
        completed: other.completed,
        createdOn: other.createdOn,
        completedOn: other.completedOn,
      );

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
        id: json["id"],
        userId: json["user_id"],
        title: json["title"],
        description: json["description"],
        completedHours: json["completed_hours"],
        completed: json["completed"],
        createdOn: json["created_on"] == null ? null : DateTime.parse(json["created_on"]),
        completedOn: json["completed_on"] == null ? null : DateTime.parse(json["completed_on"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "title": title,
        "description": description,
        "completed_hours": completedHours,
        "completed": completed,
        "created_on": createdOn?.toString(),
        "completed_on": completedOn?.toString(),
      };

  bool equals(Skill other) =>
      this.id == other.id &&
      this.userId == other.userId &&
      this.title == other.title &&
      this.description == other.description &&
      this.completedHours == other.completedHours &&
      this.completed == other.completed &&
      this.createdOn == other.createdOn &&
      this.completedOn == other.completedOn;
}
