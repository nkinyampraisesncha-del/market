class OrderModel {
  final String id;
  final String productId;
  final String productTitle;
  final String? productImageUrl;
  final String buyerId;
  final String buyerName;
  final String sellerId;
  final String sellerName;
  final double amount;
  final String status;
  final String paymentStatus;
  final String? paymentMethod;
  final String? shippingAddress;
  final String? trackingNumber;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const OrderModel({
    required this.id,
    required this.productId,
    required this.productTitle,
    this.productImageUrl,
    required this.buyerId,
    required this.buyerName,
    required this.sellerId,
    required this.sellerName,
    required this.amount,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    this.shippingAddress,
    this.trackingNumber,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      productTitle: json['product_title'] as String? ?? '',
      productImageUrl: json['product_image_url'] as String?,
      buyerId: json['buyer_id'] as String,
      buyerName: json['buyer_name'] as String? ?? 'Unknown',
      sellerId: json['seller_id'] as String,
      sellerName: json['seller_name'] as String? ?? 'Unknown',
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      paymentMethod: json['payment_method'] as String?,
      shippingAddress: json['shipping_address'] as String?,
      trackingNumber: json['tracking_number'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_title': productTitle,
      'product_image_url': productImageUrl,
      'buyer_id': buyerId,
      'buyer_name': buyerName,
      'seller_id': sellerId,
      'seller_name': sellerName,
      'amount': amount,
      'status': status,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'shipping_address': shippingAddress,
      'tracking_number': trackingNumber,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? productId,
    String? productTitle,
    String? productImageUrl,
    String? buyerId,
    String? buyerName,
    String? sellerId,
    String? sellerName,
    double? amount,
    String? status,
    String? paymentStatus,
    String? paymentMethod,
    String? shippingAddress,
    String? trackingNumber,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productTitle: productTitle ?? this.productTitle,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending => status == 'pending';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  bool get isDisputed => status == 'disputed';
  bool get isPaymentComplete => paymentStatus == 'completed';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is OrderModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
