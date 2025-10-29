import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/bank_account.dart';
import 'bank_account_form_dialog.dart';

class BankAccountListPage extends StatelessWidget {
  final FirestoreService service;
  const BankAccountListPage({super.key, required this.service});

  Future<void> _openForm(BuildContext ctx, [BankAccount? acc]) async {
    final res = await showDialog<bool>(
      context: ctx,
      builder: (_) => BankAccountFormDialog(service: service, bankAccount: acc),
    );
    if (res == true) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Bank Information saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search + Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Enter Assessee Name to Filter Details',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: () => _openForm(context),
                icon: const Icon(Icons.add),
                label: const Text('Add New Bank Information'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade50,
                  foregroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Table Header
          Container(
            color: Colors.indigo.shade50,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Row(
              children: const [
                Expanded(flex: 2, child: Text('Assessee Name', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Branch Name', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Account No.', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Account Type', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('IFSC Code', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          const Divider(height: 0),

          // Bank Account List (Firestore Stream)
          Expanded(
            child: StreamBuilder<List<BankAccount>>(
              stream: service.streamBankAccounts(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = snap.data ?? [];
                if (list.isEmpty) {
                  return const Center(child: Text('No Bank Accounts Found'));
                }

                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (ctx, i) {
                    final b = list[i];
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text(b.assesseeName)),
                          Expanded(flex: 2, child: Text(b.branchName)),
                          Expanded(flex: 2, child: Text(b.accountNumber)),
                          Expanded(flex: 2, child: Text(b.accountType)),
                          Expanded(flex: 2, child: Text(b.ifsc)),
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.indigo),
                                  tooltip: 'Edit',
                                  onPressed: () => _openForm(context, b),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  tooltip: 'Delete',
                                  onPressed: () async {
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Delete Bank Information?'),
                                        content: Text('Delete account for ${b.assesseeName}?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (ok == true) {
                                      await service.deleteBankAccount(b.id);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
