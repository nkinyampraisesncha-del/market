class ProductModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String condition;
  final List<String> images;
  final String sellerId;
  final String sellerName;
  final String? sellerImageUrl;
  final String? universityId;
  final String? universityName;
  final String status;
  final bool isFavorited;
  final int viewCount;
  final bool isRentable;
  final double? rentalPricePerDay;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.condition,
    required this.images,
    required this.sellerId,
    required this.sellerName,
    this.sellerImageUrl,
    this.universityId,
    this.universityName,
    this.status = 'active',
    this.isFavorited = false,
    this.viewCount = 0,
    this.isRentable = false,
    this.rentalPricePerDay,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
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
      sellerName: json['seller_name'] as String? ?? 'Unknown',
      sellerImageUrl: json['seller_image_url'] as String?,
      universityId: json['university_id'] as String?,
      universityName: json['university_name'] as String?,
      status: json['status'] as String? ?? 'active',
      isFavorited: json['is_favorited'] as bool? ?? false,
      viewCount: json['view_count'] as int? ?? 0,
      isRentable: json['is_rentable'] as bool? ?? false,
      rentalPricePerDay: json['rental_price_per_day'] != null
          ? (json['rental_price_per_day'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
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
      'seller_name': sellerName,
      'seller_image_url': sellerImageUrl,
      'university_id': universityId,
      'university_name': universityName,
      'status': status,
      'is_favorited': isFavorited,
      'view_count': viewCount,
      'is_rentable': isRentable,
      'rental_price_per_day': rentalPricePerDay,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? category,
    String? condition,
    List<String>? images,
    String? sellerId,
    String? sellerName,
    String? sellerImageUrl,
    String? universityId,
    String? universityName,
    String? status,
    bool? isFavorited,
    int? viewCount,
    bool? isRentable,
    double? rentalPricePerDay,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      images: images ?? this.images,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerImageUrl: sellerImageUrl ?? this.sellerImageUrl,
      universityId: universityId ?? this.universityId,
      universityName: universityName ?? this.universityName,
      status: status ?? this.status,
      isFavorited: isFavorited ?? this.isFavorited,
      viewCount: viewCount ?? this.viewCount,
      isRentable: isRentable ?? this.isRentable,
      rentalPricePerDay: rentalPricePerDay ?? this.rentalPricePerDay,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get thumbnailUrl => images.isNotEmpty ? images.first : '';

  bool get isActive => status == 'active';
  bool get isSold => status == 'sold';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ProductModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
