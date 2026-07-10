import 'package:cloud_firestore/cloud_firestore.dart';

class Journal {
  final String id;

  final String date;

  final String productivity;

  final String mood;

  final String note;

  final Timestamp createdAt;

  final Timestamp updatedAt;

  Journal({
    required this.id,

    required this.date,

    required this.productivity,

    required this.mood,

    required this.note,

    required this.createdAt,

    required this.updatedAt,
  });

  factory Journal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Journal(
      id: data["id"] ?? doc.id,

      date: data["date"] ?? "",

      productivity: data["productive"] == true
          ? "productive"
          : (data["productivity"] ?? "not_productive"),

      mood: data["mood"] ?? "😐",

      note: data["content"] ?? data["note"] ?? "",

      createdAt: data["createdAt"] ?? Timestamp.now(),

      updatedAt: data["updatedAt"] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,

      "date": date,

      "productive": productivity == "productive",

      "mood": mood,

      "content": note,

      "createdAt": createdAt,

      "updatedAt": updatedAt,
    };
  }
}
