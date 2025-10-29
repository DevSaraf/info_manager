// lib/screens/task_form_dialog.dart
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/firestore_service.dart';

class TaskFormDialog extends StatefulWidget {
  final FirestoreService service;
  final Task? task;
  const TaskFormDialog({super.key, required this.service, this.task});

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _detailsCtl = TextEditingController();
  DateTime? _startDate;
  DateTime? _dueDate;
  String _frequency = 'None';
  bool _isActive = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _nameCtl.text = widget.task!.name;
      _detailsCtl.text = widget.task!.details;
      _startDate = widget.task!.startDate;
      _dueDate = widget.task!.dueDate;
      _frequency = widget.task!.frequency;
      _isActive = widget.task!.isActive;
    } else {
      final now = DateTime.now();
      _startDate = now;
      _dueDate = now.add(Duration(days: 30));
    }
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _detailsCtl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext ctx, DateTime initial, ValueChanged<DateTime> onPicked) async {
    final picked = await showDatePicker(
      context: ctx,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final now = DateTime.now();
    final t = Task(
      id: widget.task?.id ?? '',
      name: _nameCtl.text.trim(),
      details: _detailsCtl.text.trim(),
      date: now,
      startDate: _startDate ?? now,
      dueDate: _dueDate ?? now,
      frequency: _frequency,
      isActive: _isActive,
      createdAt: widget.task?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      if (widget.task == null) {
        await widget.service.createTask(t);
      } else {
        await widget.service.updateTask(widget.task!.id, t);
      }
      Navigator.of(context).pop(true);
    } catch (e) {
      // show error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save task: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Add Task / To-do' : 'Update Task / To-do'),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameCtl,
                  decoration: InputDecoration(labelText: 'Task Name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _detailsCtl,
                  decoration: InputDecoration(labelText: 'Details'),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickDate(context, _startDate ?? DateTime.now(), (d) => setState(() => _startDate = d)),
                        child: InputDecorator(
                          decoration: InputDecoration(labelText: 'Start Date'),
                          child: Text(_startDate != null ? _startDate!.toLocal().toIso8601String().split('T').first : ''),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickDate(context, _dueDate ?? DateTime.now(), (d) => setState(() => _dueDate = d)),
                        child: InputDecorator(
                          decoration: InputDecoration(labelText: 'Due Date'),
                          child: Text(_dueDate != null ? _dueDate!.toLocal().toIso8601String().split('T').first : ''),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _frequency,
                        items: ['None', 'Daily', 'Weekly', 'Monthly', 'Yearly'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => setState(() => _frequency = v ?? 'None'),
                        decoration: InputDecoration(labelText: 'Frequency'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Active'),
                        value: _isActive,
                        onChanged: (v) => setState(() => _isActive = v ?? true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(false), child: Text('Cancel')),
        ElevatedButton(onPressed: _saving ? null : _save, child: Text(widget.task == null ? 'Save' : 'Update')),
      ],
    );
  }
}
