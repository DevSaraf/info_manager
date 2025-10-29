// lib/screens/task_list_page.dart
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/task.dart';
import 'task_form_dialog.dart';
import 'package:intl/intl.dart';

class TaskListPage extends StatelessWidget {
  final FirestoreService service;
  const TaskListPage({super.key, required this.service});

  Future<void> _openForm(BuildContext ctx, {Task? t}) async {
    final res = await showDialog<bool>(
      context: ctx,
      builder: (_) => TaskFormDialog(service: service, task: t),
    );
    if (res == true) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Task saved successfully')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('yyyy-MM-dd');
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Search', border: UnderlineInputBorder()),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _openForm(context),
                icon: Icon(Icons.add),
                label: Text('Add New Task'),
                style: ElevatedButton.styleFrom(shape: StadiumBorder()),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: service.streamTasks(),
              builder: (ctx, snap) {
                final list = snap.data ?? [];
                if (snap.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (list.isEmpty) {
                  return Center(child: Text('No tasks found'));
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Due on')),
                      DataColumn(label: Text('Task Name')),
                      DataColumn(label: Text('Details')),
                      DataColumn(label: Text('Starting Date')),
                      DataColumn(label: Text('Repeats')),
                      DataColumn(label: Text('is Active')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: list.map((t) {
                      return DataRow(cells: [
                        DataCell(Text(df.format(t.date))),
                        DataCell(Text(df.format(t.dueDate))),
                        DataCell(Text(t.name)),
                        DataCell(Container(width: 220, child: Text(t.details, overflow: TextOverflow.ellipsis))),
                        DataCell(Text(df.format(t.startDate))),
                        DataCell(Text(t.frequency)),
                        DataCell(Text(t.isActive ? 'Yes' : 'No')),
                        DataCell(Row(
                          children: [
                            IconButton(onPressed: () => _openForm(context, t: t), icon: Icon(Icons.edit)),
                            IconButton(
                              onPressed: () async {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text('Delete task?'),
                                    content: Text('Delete "${t.name}"? This cannot be undone.'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Cancel')),
                                      ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text('Delete')),
                                    ],
                                  ),
                                );
                                if (ok == true) {
                                  await service.deleteTask(t.id);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Task deleted')));
                                }
                              },
                              icon: Icon(Icons.delete_outline),
                            ),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
