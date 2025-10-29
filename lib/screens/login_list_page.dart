import 'package:flutter/material.dart';
import '../models/login_detail.dart';
import '../services/firestore_service.dart';
import 'password_view_dialog.dart';
import 'login_form_dialog.dart';

class LoginListPage extends StatefulWidget {
  final FirestoreService service;

  const LoginListPage({super.key, required this.service});

  @override
  State<LoginListPage> createState() => _LoginListPageState();
}

class _LoginListPageState extends State<LoginListPage> {
  List<LoginDetail> _logins = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadLogins();
  }

  Future<void> _loadLogins() async {
    final logins = await widget.service.getAllLoginDetails();
    setState(() {
      _logins = logins;
    });
  }

  Future<void> _addLogin() async {
    final result = await showDialog(
      context: context,
      builder: (_) => LoginFormDialog(service: widget.service),
    );
    if (result == true) _loadLogins();
  }

  Future<void> _editLogin(LoginDetail login) async {
    final result = await showDialog(
      context: context,
      builder: (_) => LoginFormDialog(service: widget.service, initial: login.toMapForUpdate()),

    );
    if (result == true) _loadLogins();
  }

  Future<void> _deleteLogin(String id) async {
    await widget.service.deleteLoginDetail(id);
    _loadLogins();
  }

  Future<void> _viewPassword(LoginDetail login) async {
    await showDialog(
      context: context,
      builder: (_) => PasswordViewDialog(
        login: login,
        service: widget.service,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredLogins = _logins
        .where((item) =>
    item.friendlyName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        item.website.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        item.username.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔍 Search bar
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search',
              border: UnderlineInputBorder(),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
          const SizedBox(height: 20),

          // 🧾 Table Title + Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'List of Login Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add New Login'),
                onPressed: _addLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade50,
                  foregroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 📋 Table Headers
          Container(
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              border: Border.all(color: Colors.indigo.shade100),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: const Row(
              children: [
                Expanded(flex: 1, child: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Friendly Name', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text('Website', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Username', style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 100, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 🧠 Table Rows
          Expanded(
            child: filteredLogins.isEmpty
                ? const Center(child: Text('No login details found.'))
                : ListView.separated(
              itemCount: filteredLogins.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final login = filteredLogins[index];
                return Container(
                  color: index.isEven ? Colors.blue.shade50.withOpacity(0.3) : Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: Row(
                    children: [
                      Expanded(flex: 1, child: Text(login.category)),
                      Expanded(flex: 2, child: Text(login.friendlyName)),
                      Expanded(flex: 3, child: Text(login.website)),
                      Expanded(flex: 2, child: Text(login.username)),
                      SizedBox(
                        width: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility, size: 20),
                              onPressed: () => _viewPassword(login),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _editLogin(login),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              onPressed: () => _deleteLogin(login.id),
                            ),
                          ],
                        ),
                      ),
                    ],
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
