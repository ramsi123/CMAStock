class Order {
  final String customerName;
  final String deskripsi;
  final List<String> orderItemName;
  final List<String> orderItemQuantity;
  final String orderLeftovers;
  final String status;
  final String timestamp;

  Order({
    required this.customerName,
    required this.deskripsi,
    required this.orderItemName,
    required this.orderItemQuantity,
    required this.orderLeftovers,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'deskripsi': deskripsi,
      'orderItemName': orderItemName,
      'orderItemQuantity': orderItemQuantity,
      'orderLeftovers': orderLeftovers,
      'status': status,
      'timestamp': timestamp,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      customerName: map['customerName'] as String,
      deskripsi: map['deskripsi'] as String,
      orderItemName: List<String>.from((map['orderItemName'] as List<String>)),
      orderItemQuantity:
          List<String>.from((map['orderItemQuantity'] as List<String>)),
      orderLeftovers: map['orderLeftovers'] as String,
      status: map['status'] as String,
      timestamp: map['timestamp'] as String,
    );
  }
}
