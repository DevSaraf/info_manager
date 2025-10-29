// lib/screens/assessee_list_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/firestore_service.dart';
import '../models/assessee.dart';
import 'assessee_form_dialog.dart';

class AssesseeListPage extends StatefulWidget {
  final FirestoreService service;
  const AssesseeListPage({super.key, required this.service});

  @override
  State<AssesseeListPage> createState() => _AssesseeListPageState();
}

class _AssesseeListPageState extends State<AssesseeListPage> {
  final TextEditingController _searchCtl = TextEditingController();
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _searchCtl.addListener(() => setState(() => _filter = _searchCtl.text.trim()));
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  Future<void> _openForm(BuildContext ctx, [Assessee? a]) async {
    final res = await showDialog<bool>(
      context: ctx,
      builder: (_) => AssesseeFormDialog(service: widget.service, assessee: a),
    );
    if (res == true) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Assessee saved successfully')),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext ctx, Assessee a) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Delete assessee?'),
        content: Text('Delete "${a.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
        ],
      ),
    );

    if (ok == true) {
      await widget.service.deleteAssessee(a.id);
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Assessee deleted')));
    }
  }

  bool _matchesFilter(Assessee a) {
    if (_filter.isEmpty) return true;
    final f = _filter.toLowerCase();
    return (a.name?.toLowerCase().contains(f) ?? false) ||
        (a.address?.toLowerCase().contains(f) ?? false) ||
        (a.category?.toLowerCase().contains(f) ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('yyyy-MM-dd');
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search + Add Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtl,
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
                label: const Text('Add New Assessee'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade50,
                  foregroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Header (table-like)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            color: Colors.indigo.shade50,
            child: Row(
              children: const [
                Expanded(flex: 3, child: Text('Assessee Name', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 4, child: Text('Address', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Date of Birth', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          const Divider(height: 0),

          // Data (stream)
          Expanded(
            child: StreamBuilder<List<Assessee>>(
              stream: widget.service.streamAssessees(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = (snap.data ?? []).where(_matchesFilter).toList();
                if (list.isEmpty) {
                  return const Center(child: Text('No assessees found'));
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (ctx, i) {
                    final a = list[i];
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: Text(a.name ?? '', style: const TextStyle(fontWeight: FontWeight.w600))),
                          Expanded(flex: 4, child: Text(a.address ?? '')),
                          Expanded(flex: 2, child: Text(a.category ?? '')),
                          Expanded(flex: 2, child: Text(a.dob != null ? df.format(a.dob!) : '')),
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.indigo),
                                  tooltip: 'Edit assessee',
                                  onPressed: () => _openForm(context, a),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  tooltip: 'Delete assessee',
                                  onPressed: () => _confirmDelete(context, a),
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
