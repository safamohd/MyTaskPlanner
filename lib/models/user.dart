import 'dart:convert';

MyUser myUserFromJson(String str) => MyUser.fromJson(json.decode(str));

String myUserToJson(MyUser data) => json.encode(data.toJson());

class MyUser {
  MyUser({
    this.id = "",
    this.name = "",
    this.email = "",
    this.gender = "",
  });

  String id;
  String name;
  String email;
  String gender;

  factory MyUser.fromJson(Map<String, dynamic> json) => MyUser(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        gender: json["gender"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "gender": gender,
      };
}
