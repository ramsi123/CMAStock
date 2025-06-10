class Product {
  final String productId;
  final String namaBarang;
  final String jumlahBarang;
  final String deskripsiBarang;
  final String imageId;
  final String imageUrl;
  final List<String> materialName;
  final List<String> materialQuantity;
  final List<String> materialUnit;
  final String timestamp;

  Product({
    required this.productId,
    required this.namaBarang,
    required this.jumlahBarang,
    required this.deskripsiBarang,
    required this.imageId,
    required this.imageUrl,
    required this.materialName,
    required this.materialQuantity,
    required this.materialUnit,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'namaBarang': namaBarang,
      'jumlahBarang': jumlahBarang,
      'deskripsiBarang': deskripsiBarang,
      'imageId': imageId,
      'imageUrl': imageUrl,
      'materialName': materialName,
      'materialQuantity': materialQuantity,
      'materialUnit': materialUnit,
      'timestamp': timestamp,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      productId: map['productId'] as String,
      namaBarang: map['namaBarang'] as String,
      jumlahBarang: map['jumlahBarang'] as String,
      deskripsiBarang: map['deskripsiBarang'] as String,
      imageId: map['imageId'] as String,
      imageUrl: map['imageUrl'] as String,
      materialName: List<String>.from((map['materialName'] as List<String>)),
      materialQuantity:
          List<String>.from((map['materialQuantity'] as List<String>)),
      materialUnit: List<String>.from((map['materialUnit'] as List<String>)),
      timestamp: map['timestamp'] as String,
    );
  }
}
