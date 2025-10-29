import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CryptoService {
  static const _storageKey = 'info_manager_aes_key';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Get or create a persistent 32-byte AES key
  Future<enc.Key> _getKey() async {
    final existing = await _secureStorage.read(key: _storageKey);
    if (existing != null) {
      final bytes = base64Decode(existing);
      return enc.Key(Uint8List.fromList(bytes));
    }

    // Create a new random key once, store it permanently
    final rnd = Random.secure();
    final keyBytes = List<int>.generate(32, (_) => rnd.nextInt(256));
    final encoded = base64Encode(keyBytes);
    await _secureStorage.write(key: _storageKey, value: encoded);
    return enc.Key(Uint8List.fromList(keyBytes));
  }

  /// Encrypt plaintext -> base64(iv + ciphertext)
  Future<String> encrypt(String plainText) async {
    final key = await _getKey();
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    final combined = iv.bytes + encrypted.bytes;
    return base64Encode(combined);
  }

  /// Decrypt base64(iv + ciphertext)
  Future<String> decrypt(String base64Cipher) async {
    try {
      final bytes = base64Decode(base64Cipher);
      if (bytes.length <= 16) {
        throw ArgumentError('Invalid cipher text');
      }

      final ivBytes = bytes.sublist(0, 16);
      final cipherBytes = bytes.sublist(16);

      final key = await _getKey();
      final iv = enc.IV(ivBytes);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'));

      return encrypter.decrypt(enc.Encrypted(Uint8List.fromList(cipherBytes)), iv: iv);
    } catch (e) {
      print('❌ Decryption failed: $e');
      throw Exception('Decryption failed. Possibly wrong key or corrupted data.');
    }
  }
}
