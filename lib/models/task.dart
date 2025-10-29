// lib/models/task.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String name;
  final String details;
  final DateTime date;     // created / record date (optional)
  final DateTime startDate;
  final DateTime dueDate;
  final String frequency;  // e.g. "Daily", "Monthly", "None"
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.name,
    required this.details,
    required this.date,
    required this.startDate,
    required this.dueDate,
    required this.frequency,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'details': details,
      'date': Timestamp.fromDate(date),
      'startDate': Timestamp.fromDate(startDate),
      'dueDate': Timestamp.fromDate(dueDate),
      'frequency': frequency,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static Task fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    Timestamp toTs(String key) => data[key] as Timestamp? ?? Timestamp.fromDate(DateTime(1970));
    return Task(
      id: doc.id,
      name: data['name'] as String? ?? '',
      details: data['details'] as String? ?? '',
      date: (toTs('date')).toDate(),
      startDate: (toTs('startDate')).toDate(),
      dueDate: (toTs('dueDate')).toDate(),
      frequency: data['frequency'] as String? ?? 'None',
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (toTs('createdAt')).toDate(),
      updatedAt: (toTs('updatedAt')).toDate(),
    );
  }
}
