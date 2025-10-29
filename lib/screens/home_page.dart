// lib/screens/home_page.dart
import 'package:flutter/material.dart';

// FIXED imports (go up one level to reach /services and /screens)
import '../services/firestore_service.dart';
import 'assessee_list_page.dart';
import 'bank_account_list_page.dart';
import 'login_list_page.dart';
import 'task_list_page.dart';

class HomePage extends StatelessWidget {
  final FirestoreService service;
  const HomePage({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final tabs = <Tab>[
      const Tab(text: 'Assessee Details'),
      const Tab(text: 'Bank Account Information'),
      const Tab(text: 'Registration Details'),
      const Tab(text: 'Login Details'),
      const Tab(text: 'Task / To-do List'),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Information Manager',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.indigo,
            labelColor: Colors.indigo,
            unselectedLabelColor: Colors.grey,
            tabs: tabs,
          ),
        ),
        body: TabBarView(
          children: [
            AssesseeListPage(service: service),
            BankAccountListPage(service: service),
            const Center(child: Text('Registration Details - to implement')),
            LoginListPage(service: service),
            TaskListPage(service: service), // ✅ this now resolves
          ],
        ),
      ),
    );
  }
}
