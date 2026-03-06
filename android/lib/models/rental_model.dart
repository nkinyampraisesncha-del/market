class RentalModel {
  final String id;
  final String productId;
  final String productTitle;
  final String? productImageUrl;
  final String renterId;
  final String renterName;
  final String ownerId;
  final String ownerName;
  final double dailyRate;
  final DateTime startDate;
  final DateTime endDate;
  final double totalAmount;
  final String status;
  final String paymentStatus;
  final String? returnNotes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const RentalModel({
    required this.id,
    required this.productId,
    required this.productTitle,
    this.productImageUrl,
    required this.renterId,
    required this.renterName,
    required this.ownerId,
    required this.ownerName,
    required this.dailyRate,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    this.returnNotes,
    required this.createdAt,
    this.updatedAt,
  });

  factory RentalModel.fromJson(Map<String, dynamic> json) {
    return RentalModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      productTitle: json['product_title'] as String? ?? '',
      productImageUrl: json['product_image_url'] as String?,
      renterId: json['renter_id'] as String,
      renterName: json['renter_name'] as String? ?? 'Unknown',
      ownerId: json['owner_id'] as String,
      ownerName: json['owner_name'] as String? ?? 'Unknown',
      dailyRate: (json['daily_rate'] as num).toDouble(),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      returnNotes: json['return_notes'] as String?,
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
      'renter_id': renterId,
      'renter_name': renterName,
      'owner_id': ownerId,
      'owner_name': ownerName,
      'daily_rate': dailyRate,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'total_amount': totalAmount,
      'status': status,
      'payment_status': paymentStatus,
      'return_notes': returnNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  RentalModel copyWith({
    String? id,
    String? productId,
    String? productTitle,
    String? productImageUrl,
    String? renterId,
    String? renterName,
    String? ownerId,
    String? ownerName,
    double? dailyRate,
    DateTime? startDate,
    DateTime? endDate,
    double? totalAmount,
    String? status,
    String? paymentStatus,
    String? returnNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RentalModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productTitle: productTitle ?? this.productTitle,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      renterId: renterId ?? this.renterId,
      renterName: renterName ?? this.renterName,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      dailyRate: dailyRate ?? this.dailyRate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      returnNotes: returnNotes ?? this.returnNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get rentalDays => endDate.difference(startDate).inDays;
  bool get isActive => status == 'active';
  bool get isOverdue => endDate.isBefore(DateTime.now()) && status == 'active';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is RentalModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
