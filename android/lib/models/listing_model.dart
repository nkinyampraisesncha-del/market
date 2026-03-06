class ListingModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String condition;
  final List<String> images;
  final String sellerId;
  final String? universityId;
  final String status;
  final bool isRentable;
  final double? rentalPricePerDay;
  final int viewCount;
  final int favoriteCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? approvedAt;
  final String? rejectionReason;

  const ListingModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.condition,
    required this.images,
    required this.sellerId,
    this.universityId,
    this.status = 'pending_approval',
    this.isRentable = false,
    this.rentalPricePerDay,
    this.viewCount = 0,
    this.favoriteCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.approvedAt,
    this.rejectionReason,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String? ?? 'Other',
      condition: json['condition'] as String? ?? 'Good',
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      sellerId: json['seller_id'] as String,
      universityId: json['university_id'] as String?,
      status: json['status'] as String? ?? 'pending_approval',
      isRentable: json['is_rentable'] as bool? ?? false,
      rentalPricePerDay: json['rental_price_per_day'] != null
          ? (json['rental_price_per_day'] as num).toDouble()
          : null,
      viewCount: json['view_count'] as int? ?? 0,
      favoriteCount: json['favorite_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      rejectionReason: json['rejection_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'condition': condition,
      'images': images,
      'seller_id': sellerId,
      'university_id': universityId,
      'status': status,
      'is_rentable': isRentable,
      'rental_price_per_day': rentalPricePerDay,
      'view_count': viewCount,
      'favorite_count': favoriteCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
    };
  }

  ListingModel copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? category,
    String? condition,
    List<String>? images,
    String? sellerId,
    String? universityId,
    String? status,
    bool? isRentable,
    double? rentalPricePerDay,
    int? viewCount,
    int? favoriteCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? approvedAt,
    String? rejectionReason,
  }) {
    return ListingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      images: images ?? this.images,
      sellerId: sellerId ?? this.sellerId,
      universityId: universityId ?? this.universityId,
      status: status ?? this.status,
      isRentable: isRentable ?? this.isRentable,
      rentalPricePerDay: rentalPricePerDay ?? this.rentalPricePerDay,
      viewCount: viewCount ?? this.viewCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  bool get isActive => status == 'active';
  bool get isPendingApproval => status == 'pending_approval';
  bool get isRejected => status == 'rejected';
  bool get isSold => status == 'sold';
  String get thumbnailUrl => images.isNotEmpty ? images.first : '';
}
