class StockReport {
  final String status;
  final String jumlah;
  final String sisa;
  final String note;
  final String timestamp;

  StockReport({
    required this.status,
    required this.jumlah,
    required this.sisa,
    required this.note,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'jumlah': jumlah,
      'sisa': sisa,
      'note': note,
      'timestamp': timestamp,
    };
  }

  factory StockReport.fromMap(Map<String, dynamic> map) {
    return StockReport(
      status: map['status'] as String,
      jumlah: map['jumlah'] as String,
      sisa: map['sisa'] as String,
      note: map['note'] as String,
      timestamp: map['timestamp'] as String,
    );
  }
}
