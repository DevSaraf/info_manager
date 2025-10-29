// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/assessee.dart';
import '../models/bank_account.dart';
import '../models/task.dart';
import '../models/login_detail.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Assessees
  Stream<List<Assessee>> streamAssessees() {
    return _db.collection('assessees')
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Assessee.fromDoc(d)).toList());
  }

  Future<String> createAssessee(Assessee a) async {
    final docRef = await _db.collection('assessees').add(a.toMap());
    return docRef.id;
  }

  Future<void> updateAssessee(String id, Map<String,dynamic> map) async {
    await _db.collection('assessees').doc(id).update(map);
  }

  Future<void> deleteAssessee(String id) async {
    await _db.collection('assessees').doc(id).delete();
  }

  // Bank accounts
  Stream<List<BankAccount>> streamBankAccounts() {
    return _db.collection('bank_accounts')
        .orderBy('assesseeName')
        .snapshots()
        .map((snap) => snap.docs.map((d) => BankAccount.fromDoc(d)).toList());
  }

  Future<String> createBankAccount(BankAccount acc) async {
    final docRef = await _db.collection('bank_accounts').add(acc.toMap());
    return docRef.id;
  }

  Future<void> updateBankAccount(String id, Map<String,dynamic> map) async {
    await _db.collection('bank_accounts').doc(id).update(map);
  }

  Future<void> deleteBankAccount(String id) async {
    await _db.collection('bank_accounts').doc(id).delete();
  }

  // Tasks
  Stream<List<Task>> streamTasks() {
    return _db
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Task.fromDoc(d)).toList());
  }

  Future<String> createTask(Task t) async {
    final now = DateTime.now();
    final docRef = await _db.collection('tasks').add({
      ...t.toMap(),
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
    return docRef.id;
  }

  Future<void> updateTask(String id, Task t) async {
    final now = DateTime.now();
    await _db.collection('tasks').doc(id).set({
      ...t.toMap(),
      'updatedAt': Timestamp.fromDate(now),
    }, SetOptions(merge: true));
  }

  Future<void> deleteTask(String id) async {
    await _db.collection('tasks').doc(id).delete();
  }

  // --- Login details (credentials)
  // --- Login details (credentials)
  Stream<List<LoginDetail>> streamLoginDetails() {
    return _db.collection('login_details')
        .orderBy('friendlyName')
        .snapshots()
        .map((snap) => snap.docs.map((d) {
      final data = Map<String, dynamic>.from(d.data());
      data['id'] = d.id;
      return LoginDetail.fromMap(data);
    }).toList());
  }

  /// Return all login docs once (used by login_list_page._loadLogins)
  Future<List<LoginDetail>> getAllLoginDetails() async {
    final snapshot = await _db.collection('login_details')
        .orderBy('friendlyName')
        .get();
    return snapshot.docs.map((d) {
      final data = Map<String, dynamic>.from(d.data());
      data['id'] = d.id;
      return LoginDetail.fromMap(data);
    }).toList();
  }

  Future<String> createLoginDetail(Map<String, dynamic> map) async {
    final docRef = await _db.collection('login_details').add({
      ...map,
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
    return docRef.id;
  }

  Future<void> updateLoginDetail(String id, Map<String, dynamic> map) async {
    await _db.collection('login_details').doc(id).set({
      ...map,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }

  Future<void> deleteLoginDetail(String id) async {
    await _db.collection('login_details').doc(id).delete();
  }

}
