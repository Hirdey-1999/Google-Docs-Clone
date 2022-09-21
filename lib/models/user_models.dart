import 'dart:convert';

class userModel {
  final String name;
  final String email;
  final String uid;
  final String token;

  userModel(
      {required this.name,
      required this.email,
      required this.uid,
      required this.token});

  Map<String, dynamic> toMap() {
    return {'email': email, 'name': name, 'uid': uid, 'token': token};
  }

  factory userModel.fromMap(Map<String, dynamic> map) {
    return userModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      uid: map['_id'] ?? '',
      token: map['token'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory userModel.fromJson(String source) => userModel.fromMap(json.decode(source));

  userModel copyWith({
    String? email,
    String? name,
    String? token,
    String? uid,
  }) {
    return userModel(
      name: name ?? this.name,
      email: email ?? this.email,
      uid: uid ?? this.uid,
      token: token ?? this.token,
    );
  }
}
