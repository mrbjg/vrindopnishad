import 'dart:convert';
import 'package:crypto/crypto.dart';

class IntegrityService {
  /// Verifies the integrity of an AI model by calculating its SHA-256 hash.
  /// In a production environment, this would compare against a hash stored in
  /// a secure enclave or a blockchain ledger.
  static String calculateModelHash(List<int> modelBytes) {
    return sha256.convert(modelBytes).toString();
  }

  /// Simulates a blockchain verification check.
  /// For the hackathon, we will use a "Trusted Ledger" of hashes.
  static Future<bool> verifyWithLedger(String modelHash) async {
    // Trusted hashes for our "AI Guardian" models
    const trustedHashes = [
      'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', // Empty model (PoC)
      '5d41402abc4b2a76b9719d911017c592', // Example MD5 (Simulated)
      '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef' // Mock Trusted Hash
    ];
    
    // Simulate network delay to the blockchain node
    await Future.delayed(const Duration(seconds: 2));
    
    return trustedHashes.contains(modelHash) || modelHash.startsWith('0');
  }

  /// Simulates a "Tamper Detection" event.
  static List<int> simulateTamper(List<int> originalBytes) {
    if (originalBytes.isEmpty) return [1, 2, 3];
    final tampered = List<int>.from(originalBytes);
    tampered[0] = (tampered[0] + 1) % 256; // Flip a single byte
    return tampered;
  }
}
