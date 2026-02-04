/// Hash history model
/// Author: ZF_Clark
/// Description: Represents a single hash calculation record with input text, calculated hash value, algorithm used, and timestamp. Provides methods for converting between model instances and JSON strings for storage purposes
/// Last Modified: 2026/02/04
/// Version: V0.1
library;

class HashHistory {
  /// Input text
  final String input;

  /// Calculated hash value
  final String hash;

  /// Hash algorithm used
  final String algorithm;

  /// Timestamp of calculation
  final DateTime timestamp;

  /// Constructor
  HashHistory({
    required this.input,
    required this.hash,
    required this.algorithm,
    required this.timestamp,
  });

  /// Convert to JSON string
  String toJson() {
    return '$input|$hash|$algorithm|${timestamp.toIso8601String()}';
  }

  /// Create from JSON string
  factory HashHistory.fromJson(String json) {
    final parts = json.split('|');
    return HashHistory(
      input: parts[0],
      hash: parts[1],
      algorithm: parts[2],
      timestamp: DateTime.parse(parts[3]),
    );
  }
}
