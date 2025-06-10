class Outstanding {
  final String product;
  final String jumlah;
  final String note;
  final String timestamp;

  Outstanding({
    required this.product,
    required this.jumlah,
    required this.note,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'product': product,
      'jumlah': jumlah,
      'note': note,
      'timestamp': timestamp,
    };
  }

  factory Outstanding.fromMap(Map<String, dynamic> map) {
    return Outstanding(
      product: map['product'] as String,
      jumlah: map['jumlah'] as String,
      note: map['note'] as String,
      timestamp: map['timestamp'] as String,
    );
  }
}
