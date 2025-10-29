// // lib/screens/login_form_dialog.dart
// import 'package:flutter/material.dart';
// import '../models/login_detail.dart';
// import '../services/firestore_service.dart';
//
// class LoginFormDialog extends StatefulWidget {
//   final FirestoreService service;
//   final LoginDetail? login; // optional for edit
//
//   const LoginFormDialog({super.key, required this.service, this.login});
//
//   @override
//   State<LoginFormDialog> createState() => _LoginFormDialogState();
// }
//
// class _LoginFormDialogState extends State<LoginFormDialog> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _categoryCtl;
//   late TextEditingController _friendlyNameCtl;
//   late TextEditingController _websiteCtl;
//   late TextEditingController _usernameCtl;
//   // For simplicity we handle passwords as plain text here — you probably encrypt before saving
//   late TextEditingController _loginPwdCtl;
//   late TextEditingController _adminPwdCtl;
//   late TextEditingController _authorizerPwdCtl;
//   late TextEditingController _profilePwdCtl;
//   late TextEditingController _additionalPwdCtl;
//
//   @override
//   void initState() {
//     super.initState();
//     _categoryCtl = TextEditingController(text: widget.login?.category ?? '');
//     _friendlyNameCtl = TextEditingController(text: widget.login?.friendlyName ?? '');
//     _websiteCtl = TextEditingController(text: widget.login?.website ?? '');
//     _usernameCtl = TextEditingController(text: widget.login?.username ?? '');
//     _loginPwdCtl = TextEditingController(text: widget.login?.loginPassword ?? '');
//     _adminPwdCtl = TextEditingController(text: widget.login?.administratorPassword ?? '');
//     _authorizerPwdCtl = TextEditingController(text: widget.login?.authorizerPassword ?? '');
//     _profilePwdCtl = TextEditingController(text: widget.login?.profilePassword ?? '');
//     _additionalPwdCtl = TextEditingController(text: widget.login?.additionalPassword ?? '');
//   }
//
//   @override
//   void dispose() {
//     _categoryCtl.dispose();
//     _friendlyNameCtl.dispose();
//     _websiteCtl.dispose();
//     _usernameCtl.dispose();
//     _loginPwdCtl.dispose();
//     _adminPwdCtl.dispose();
//     _authorizerPwdCtl.dispose();
//     _profilePwdCtl.dispose();
//     _additionalPwdCtl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _save() async {
//     if (!(_formKey.currentState?.validate() ?? false)) return;
//
//     // Here you must encrypt password fields using your CryptoService before saving.
//     // For now we send the controllers' text directly (assume encryption will be applied externally)
//     final map = {
//       'category': _categoryCtl.text.trim(),
//       'friendlyName': _friendlyNameCtl.text.trim(),
//       'website': _websiteCtl.text.trim(),
//       'username': _usernameCtl.text.trim(),
//       'loginPassword': _loginPwdCtl.text,
//       'administratorPassword': _adminPwdCtl.text,
//       'authorizerPassword': _authorizerPwdCtl.text,
//       'profilePassword': _profilePwdCtl.text,
//       'additionalPassword': _additionalPwdCtl.text,
//     };
//
//     try {
//       if (widget.login == null || widget.login!.id.isEmpty) {
//         await widget.service.createLoginDetail(map);
//       } else {
//         await widget.service.updateLoginDetail(widget.login!.id, map);
//       }
//       Navigator.of(context).pop(true);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text(widget.login == null ? 'Add New Login' : 'Edit Login'),
//       content: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Column(mainAxisSize: MainAxisSize.min, children: [
//             TextFormField(
//               controller: _categoryCtl,
//               decoration: const InputDecoration(labelText: 'Category'),
//               validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//             ),
//             TextFormField(
//               controller: _friendlyNameCtl,
//               decoration: const InputDecoration(labelText: 'Friendly Name'),
//               validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//             ),
//             TextFormField(
//               controller: _websiteCtl,
//               decoration: const InputDecoration(labelText: 'Website'),
//             ),
//             TextFormField(
//               controller: _usernameCtl,
//               decoration: const InputDecoration(labelText: 'Username'),
//             ),
//             TextFormField(
//               controller: _loginPwdCtl,
//               decoration: const InputDecoration(labelText: 'Login Password'),
//               obscureText: true,
//             ),
//             // you can add other password fields here...
//           ]),
//         ),
//       ),
//       actions: [
//         TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
//         ElevatedButton(onPressed: _save, child: const Text('Save')),
//       ],
//     );
//   }
// }

// lib/screens/login_form_dialog.dart
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/crypto_service.dart';

class LoginFormDialog extends StatefulWidget {
  final FirestoreService service;
  final Map<String, dynamic>? initial; // existing record or null

  const LoginFormDialog({super.key, required this.service, this.initial});

  @override
  State<LoginFormDialog> createState() => _LoginFormDialogState();
}

class _LoginFormDialogState extends State<LoginFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _friendlyCtl = TextEditingController();
  final _websiteCtl = TextEditingController();
  final _usernameCtl = TextEditingController();
  final _loginCtl = TextEditingController();
  final _adminCtl = TextEditingController();
  final _authorizerCtl = TextEditingController();
  final _profileCtl = TextEditingController();
  final _additionalCtl = TextEditingController();
  final CryptoService _crypto = CryptoService();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      final m = widget.initial!;
      _friendlyCtl.text = (m['friendlyName'] ?? '') as String;
      _websiteCtl.text = (m['website'] ?? '') as String;
      _usernameCtl.text = (m['username'] ?? '') as String;
      // passwords in DB are encrypted — don't put them into form here
    }
  }

  @override
  void dispose() {
    _friendlyCtl.dispose();
    _websiteCtl.dispose();
    _usernameCtl.dispose();
    _loginCtl.dispose();
    _adminCtl.dispose();
    _authorizerCtl.dispose();
    _profileCtl.dispose();
    _additionalCtl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      // encrypt each password field (if provided)
      final encLogin = _loginCtl.text.isNotEmpty ? await _crypto.encrypt(_loginCtl.text) : null;
      final encAdmin = _adminCtl.text.isNotEmpty ? await _crypto.encrypt(_adminCtl.text) : null;
      final encAuthorizer = _authorizerCtl.text.isNotEmpty ? await _crypto.encrypt(_authorizerCtl.text) : null;
      final encProfile = _profileCtl.text.isNotEmpty ? await _crypto.encrypt(_profileCtl.text) : null;
      final encAdd = _additionalCtl.text.isNotEmpty ? await _crypto.encrypt(_additionalCtl.text) : null;

      final map = {
        'friendlyName': _friendlyCtl.text.trim(),
        'website': _websiteCtl.text.trim(),
        'username': _usernameCtl.text.trim(),
        if (encLogin != null) 'loginPassword': encLogin,
        if (encAdmin != null) 'administratorPassword': encAdmin,
        if (encAuthorizer != null) 'authorizerPassword': encAuthorizer,
        if (encProfile != null) 'profilePassword': encProfile,
        if (encAdd != null) 'additionalPassword': encAdd,
        'updatedAt': DateTime.now(),
      };

      if (widget.initial == null) {
        await widget.service.createLoginDetail(map);
      } else {
        final id = widget.initial!['id'] as String;
        await widget.service.updateLoginDetail(id, map);
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Add New Login Details' : 'Edit Login Details'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(controller: _friendlyCtl, decoration: const InputDecoration(labelText: 'Friendly Name')),
            TextFormField(controller: _websiteCtl, decoration: const InputDecoration(labelText: 'Website')),
            TextFormField(controller: _usernameCtl, decoration: const InputDecoration(labelText: 'Username')),
            const SizedBox(height: 8),
            TextFormField(controller: _loginCtl, decoration: const InputDecoration(labelText: 'Login Password')),
            TextFormField(controller: _adminCtl, decoration: const InputDecoration(labelText: 'Administrator Password')),
            TextFormField(controller: _authorizerCtl, decoration: const InputDecoration(labelText: 'Authorizer Password')),
            TextFormField(controller: _profileCtl, decoration: const InputDecoration(labelText: 'Profile Password')),
            TextFormField(controller: _additionalCtl, decoration: const InputDecoration(labelText: 'Additional Password')),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        ElevatedButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'Saving...' : 'Save Details')),
      ],
    );
  }
}

