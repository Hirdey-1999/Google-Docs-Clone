import 'dart:convert';

class documentModel {
  final String title;
  final String uid;
  final List content;
  final DateTime createdAt;
  final String id;

  documentModel({
    required this.title,
    required this.uid,
    required this.content,
    required this.createdAt,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'uid': uid,
      'content': content,
      'createdAt': createdAt,
      'id': id,
    };
  }

  factory documentModel.fromMap(Map<String, dynamic> map) {
    return documentModel(
      title: map['title'] ?? '',
      uid: map['uid'] ?? '',
      content: List.from(map['content']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      id: map['_id'] ?? '',
    );
  }
  String toJson() => json.encode(toMap());

  factory documentModel.fromJson(String source) => documentModel.fromMap(json.decode(source));
}
