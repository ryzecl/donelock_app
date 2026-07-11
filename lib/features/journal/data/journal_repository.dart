import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/journal_model.dart';

class JournalRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  JournalRepository(this.firestore, this.auth);

  Future<void> saveJournal(Journal journal) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("journals")
        .doc(journal.id)
        .set(journal.toMap());
  }

  Future<Journal?> getTodayJournal(String date) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("journals")
        .doc(date)
        .get();

    if (!doc.exists) {
      return null;
    }

    return Journal.fromFirestore(doc);
  }

  Future<void> updateJournal(Journal journal) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("journals")
        .doc(journal.id)
        .update({
          "productive": journal.productivity == "productive",

          "mood": journal.mood,

          "content": journal.note,

          "updatedAt": Timestamp.now(),
        });
  }

  Future<void> deleteJournal(String id) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("journals")
        .doc(id)
        .delete();
  }

  Future<List<Journal>> getMonthlyJournals(String month) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final start = "${month}01";

    final year = int.parse(month.substring(0, 4));

    final mon = int.parse(month.substring(4));

    String end;

    if (mon == 12) {
      end = "${year + 1}0101";
    } else {
      end =
          "$year${(mon + 1).toString().padLeft(2, '0')}01";
    }

    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("journals")
        .where("date", isGreaterThanOrEqualTo: start)
        .where("date", isLessThan: end)
        .get();

    return snapshot.docs.map((doc) => Journal.fromFirestore(doc)).toList();
  }

  Stream<List<Journal>> getMonthlyJournalsStream(String month) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final start = "${month}01";
    final year = int.parse(month.substring(0, 4));
    final mon = int.parse(month.substring(4));
    
    String end;
    if (mon == 12) {
      end = "${year + 1}0101";
    } else {
      end = "$year${(mon + 1).toString().padLeft(2, '0')}01";
    }

    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("journals")
        .where("date", isGreaterThanOrEqualTo: start)
        .where("date", isLessThan: end)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Journal.fromFirestore(doc)).toList());
  }

  Future<List<Map<String, dynamic>>> getAllJournals() async {
    final uid = auth.currentUser!.uid;

    final snapshot = await firestore
        .collection("users")
        .doc(uid)
        .collection("journals")
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Stream<List<Map<String, dynamic>>> getAllJournalsStream() {
    final uid = auth.currentUser!.uid;

    return firestore
        .collection("users")
        .doc(uid)
        .collection("journals")
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
