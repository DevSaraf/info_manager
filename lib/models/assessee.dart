import 'package:cloud_firestore/cloud_firestore.dart';

class Assessee {
  final String id;
  final String name;
  final String category;
  final DateTime? dob;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;

  Assessee({
    required this.id,
    required this.name,
    required this.category,
    required this.dob,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Assessee.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Assessee(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      dob: (data['dob'] as Timestamp?)?.toDate(),
      address: data['address'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'dob': dob != null ? Timestamp.fromDate(dob!) : null,
      'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
