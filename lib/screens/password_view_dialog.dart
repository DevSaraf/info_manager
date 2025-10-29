// lib/screens/password_view_dialog.dart
import 'package:flutter/material.dart';
import '../models/login_detail.dart';
import '../services/crypto_service.dart';

class PasswordViewDialog extends StatefulWidget {
  final LoginDetail login;
  final dynamic service; // not used here, but kept for parity
  const PasswordViewDialog({super.key, required this.login, this.service});

  @override
  State<PasswordViewDialog> createState() => _PasswordViewDialogState();
}

class _PasswordViewDialogState extends State<PasswordViewDialog> {
  final _authorizerCtl = TextEditingController();
  final CryptoService _crypto = CryptoService();
  bool _authorized = false;
  bool _loading = false;
  String? _loginPwd, _adminPwd, _profilePwd, _additionalPwd;

  Future<void> _verify() async {
    setState(() { _loading = true; });
    try {
      final provided = _authorizerCtl.text.trim();
      final savedEnc = widget.login.authorizerPassword;
      final saved = await _crypto.decrypt(savedEnc);
      if (provided == saved) {
        // decrypt others
        _loginPwd = await _crypto.decrypt(widget.login.loginPassword);
        _adminPwd = await _crypto.decrypt(widget.login.administratorPassword);
        _profilePwd = await _crypto.decrypt(widget.login.profilePassword);
        _additionalPwd = await _crypto.decrypt(widget.login.additionalPassword);
        setState(() => _authorized = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Authorizer password incorrect')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Decryption failed: $e')));
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  void dispose() {
    _authorizerCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('View Current Password'),
      content: _authorized
          ? SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Username: ${widget.login.username}'),
        const SizedBox(height: 8),
        Text('Login Password: ${_loginPwd ?? ''}'),
        const SizedBox(height: 6),
        Text('Administrator Password: ${_adminPwd ?? ''}'),
        const SizedBox(height: 6),
        Text('Profile Password: ${_profilePwd ?? ''}'),
        const SizedBox(height: 6),
        Text('Additional Password: ${_additionalPwd ?? ''}'),
      ]))
          : Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: _authorizerCtl, decoration: const InputDecoration(labelText: 'Required Authorization Password'), obscureText: true),
      ]),
      actions: [
        if (!_authorized)
          TextButton(onPressed: _loading ? null : () => Navigator.of(context).pop(), child: const Text('Close')),
        if (!_authorized)
          ElevatedButton(onPressed: _loading ? null : _verify, child: _loading ? const CircularProgressIndicator() : const Text('Show Password')),
        if (_authorized)
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
      ],
    );
  }
}
