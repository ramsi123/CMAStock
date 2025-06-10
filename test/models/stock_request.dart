class StockRequest {
  final String namaBarang;
  final String jumlahBarang;
  final String unit;
  final String deskripsiBarang;
  final String status;
  final String timestamp;

  StockRequest({
    required this.namaBarang,
    required this.jumlahBarang,
    required this.unit,
    required this.deskripsiBarang,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'namaBarang': namaBarang,
      'jumlahBarang': jumlahBarang,
      'unit': unit,
      'deskripsiBarang': deskripsiBarang,
      'status': status,
      'timestamp': timestamp,
    };
  }

  factory StockRequest.fromMap(Map<String, dynamic> map) {
    return StockRequest(
      namaBarang: map['namaBarang'] as String,
      jumlahBarang: map['jumlahBarang'] as String,
      unit: map['unit'] as String,
      deskripsiBarang: map['deskripsiBarang'] as String,
      status: map['status'] as String,
      timestamp: map['timestamp'] as String,
    );
  }
}
