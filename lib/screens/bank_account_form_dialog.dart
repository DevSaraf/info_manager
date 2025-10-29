import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/bank_account.dart';
import '../models/assessee.dart';

class BankAccountFormDialog extends StatefulWidget {
  final FirestoreService service;
  final BankAccount? bankAccount;
  const BankAccountFormDialog({super.key, required this.service, this.bankAccount});

  @override
  State<BankAccountFormDialog> createState() => _BankAccountFormDialogState();
}

class _BankAccountFormDialogState extends State<BankAccountFormDialog> {
  final _form = GlobalKey<FormState>();
  String? _assesseeId;
  String? _assesseeName;
  final _accountNumber = TextEditingController();
  final _bankName = TextEditingController();
  final _branch = TextEditingController();
  String _accountType = 'Saving';
  final _ifsc = TextEditingController();
  final _micr = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.bankAccount != null) {
      final b = widget.bankAccount!;
      _assesseeId = b.assesseeId;
      _assesseeName = b.assesseeName;
      _accountNumber.text = b.accountNumber;
      _bankName.text = b.bankName;
      _branch.text = b.branchName;
      _accountType = b.accountType;
      _ifsc.text = b.ifsc;
      _micr.text = b.micr;
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(()=> _saving = true);
    final now = DateTime.now();
    final acc = BankAccount(
      id: widget.bankAccount?.id ?? '',
      assesseeId: _assesseeId ?? '',
      assesseeName: _assesseeName ?? '',
      bankName: _bankName.text.trim(),
      branchName: _branch.text.trim(),
      accountNumber: _accountNumber.text.trim(),
      accountType: _accountType,
      ifsc: _ifsc.text.trim(),
      micr: _micr.text.trim(),
      createdAt: widget.bankAccount?.createdAt ?? now,
    );
    try {
      if (widget.bankAccount == null) {
        await widget.service.createBankAccount(acc);
      } else {
        await widget.service.updateBankAccount(acc.id, acc.toMap());
      }
      Navigator.of(context).pop(true);
    } catch (e) {
      debugPrint('save bank error: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Save failed')));
    } finally {
      setState(()=> _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountTypes = ['Saving', 'Current', 'Overdraft', 'Fixed Deposit', 'Term Loan'];
    return Dialog(
      insetPadding: const EdgeInsets.all(40),
      child: Container(
        width: 600, // gives it a nice wide desktop form look
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _form,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // assessee dropdown (load from stream)
            StreamBuilder<List<Assessee>>(
              stream: widget.service.streamAssessees(),
              builder: (ctx, snap) {
                final list = snap.data ?? [];
                return DropdownButtonFormField<String>(
                  value: _assesseeId,
                  items: list.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                  onChanged: (v){
                    final sel = list.firstWhere((e)=>e.id==v);
                    setState(() {
                      _assesseeId = v;
                      _assesseeName = sel.name;
                    });

                  },
                  validator: (v) => v == null ? 'Select assessee' : null,
                  decoration: const InputDecoration(labelText: 'A/c Holder Name'),
                );
              },
            ),
            TextFormField(controller: _accountNumber, decoration: const InputDecoration(labelText: 'A/c Number'), validator: (v) => v?.isEmpty==true ? 'Enter account number' : null),
            Row(children: [
              Expanded(child: TextFormField(controller: _bankName, decoration: const InputDecoration(labelText: 'Bank Name'))),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(controller: _branch, decoration: const InputDecoration(labelText: 'Bank Branch'))),
            ]),
            Row(children: [
              Expanded(child: DropdownButtonFormField<String>(
                value: _accountType,
                items: accountTypes.map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),
                onChanged: (v) => setState(()=> _accountType = v ?? _accountType),
                decoration: const InputDecoration(labelText: 'A/c Type'),
              )),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(controller: _ifsc, decoration: const InputDecoration(labelText: 'IFSC Code'))),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(controller: _micr, decoration: const InputDecoration(labelText: 'MICR Code'))),
            ]),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(false), child: const Text('Cancel')),
              const SizedBox(width: 12),
              ElevatedButton(onPressed: _saving ? null : _save, child: _saving ? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2)) : const Text('Save')),
            ])
          ]),
        ),
      ),
    );
  }
}
