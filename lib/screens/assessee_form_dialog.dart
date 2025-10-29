import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../models/assessee.dart';

class AssesseeFormDialog extends StatefulWidget {
  final FirestoreService service;
  final Assessee? assessee;
  const AssesseeFormDialog({super.key, required this.service, this.assessee});

  @override
  State<AssesseeFormDialog> createState() => _AssesseeFormDialogState();
}

class _AssesseeFormDialogState extends State<AssesseeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _addressCtl = TextEditingController();
  String _category = 'Individual';
  DateTime? _dob;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.assessee != null) {
      _nameCtl.text = widget.assessee!.name;
      _addressCtl.text = widget.assessee!.address;
      _category = widget.assessee!.category;
      _dob = widget.assessee!.dob;
    }
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(context: context, initialDate: _dob ?? DateTime(2000), firstDate: DateTime(1900), lastDate: now);
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final now = DateTime.now();
    final a = Assessee(
      id: widget.assessee?.id ?? '',
      name: _nameCtl.text.trim(),
      category: _category,
      dob: _dob,
      address: _addressCtl.text.trim(),
      createdAt: widget.assessee?.createdAt ?? now,
      updatedAt: now,
    );
    try {
      if (widget.assessee == null) {
        await widget.service.createAssessee(a);
      } else {
        await widget.service.updateAssessee(a.id, a.toMap());
      }
      Navigator.of(context).pop(true);
    } catch (e) {
      debugPrint('save assessee error: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Save failed')));
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd-MM-yyyy');
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(controller: _nameCtl, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => v?.trim().isEmpty == true ? 'Enter name' : null),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: DropdownButtonFormField<String>(
                value: _category,
                items: ['Individual','Company','Other'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(()=> _category = v ?? _category),
                decoration: const InputDecoration(labelText: 'Category'),
              )),
              const SizedBox(width: 12),
              Expanded(child: InkWell(
                onTap: _pickDob,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date of Birth'),
                  child: Text(_dob != null ? df.format(_dob!) : 'Select'),
                ),
              )),
            ]),
            const SizedBox(height: 8),
            TextFormField(controller: _addressCtl, decoration: const InputDecoration(labelText: 'Address')),
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
