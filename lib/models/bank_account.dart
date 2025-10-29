import 'package:cloud_firestore/cloud_firestore.dart';

class BankAccount {
  final String id;
  final String assesseeId; // link to assessee doc id
  final String assesseeName;
  final String bankName;
  final String branchName;
  final String accountNumber;
  final String accountType;
  final String ifsc;
  final String micr;
  final DateTime createdAt;

  BankAccount({
    required this.id,
    required this.assesseeId,
    required this.assesseeName,
    required this.bankName,
    required this.branchName,
    required this.accountNumber,
    required this.accountType,
    required this.ifsc,
    required this.micr,
    required this.createdAt,
  });

  factory BankAccount.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return BankAccount(
      id: doc.id,
      assesseeId: d['assesseeId'] ?? '',
      assesseeName: d['assesseeName'] ?? '',
      bankName: d['bankName'] ?? '',
      branchName: d['branchName'] ?? '',
      accountNumber: d['accountNumber'] ?? '',
      accountType: d['accountType'] ?? '',
      ifsc: d['ifsc'] ?? '',
      micr: d['micr'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'assesseeId': assesseeId,
      'assesseeName': assesseeName,
      'bankName': bankName,
      'branchName': branchName,
      'accountNumber': accountNumber,
      'accountType': accountType,
      'ifsc': ifsc,
      'micr': micr,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
