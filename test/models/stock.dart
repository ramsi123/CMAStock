class Stock {
  final String materialId;
  final String namaBarang;
  final String jumlahBarang;
  final String unit;
  final String deskripsiBarang;
  final String imageId;
  final String imageUrl;
  final String timestamp;

  Stock({
    required this.materialId,
    required this.namaBarang,
    required this.jumlahBarang,
    required this.unit,
    required this.deskripsiBarang,
    required this.imageId,
    required this.imageUrl,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'materialId': materialId,
      'namaBarang': namaBarang,
      'jumlahBarang': jumlahBarang,
      'unit': unit,
      'deskripsiBarang': deskripsiBarang,
      'imageId': imageId,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
    };
  }

  factory Stock.fromMap(Map<String, dynamic> map) {
    return Stock(
      materialId: map['materialId'] as String,
      namaBarang: map['namaBarang'] as String,
      jumlahBarang: map['jumlahBarang'] as String,
      unit: map['unit'] as String,
      deskripsiBarang: map['deskripsiBarang'] as String,
      imageId: map['imageId'] as String,
      imageUrl: map['imageUrl'] as String,
      timestamp: map['timestamp'] as String,
    );
  }
}
