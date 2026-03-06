class ReviewModel {
  final String id;
  final String productId;
  final String reviewerId;
  final String reviewerName;
  final String? reviewerImageUrl;
  final String revieweeId;
  final String? orderId;
  final double rating;
  final String? comment;
  final bool isSellerReview;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ReviewModel({
    required this.id,
    required this.productId,
    required this.reviewerId,
    required this.reviewerName,
    this.reviewerImageUrl,
    required this.revieweeId,
    this.orderId,
    required this.rating,
    this.comment,
    this.isSellerReview = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      reviewerId: json['reviewer_id'] as String,
      reviewerName: json['reviewer_name'] as String? ?? 'Anonymous',
      reviewerImageUrl: json['reviewer_image_url'] as String?,
      revieweeId: json['reviewee_id'] as String,
      orderId: json['order_id'] as String?,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String?,
      isSellerReview: json['is_seller_review'] as bool? ?? false,
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
      'reviewer_id': reviewerId,
      'reviewer_name': reviewerName,
      'reviewer_image_url': reviewerImageUrl,
      'reviewee_id': revieweeId,
      'order_id': orderId,
      'rating': rating,
      'comment': comment,
      'is_seller_review': isSellerReview,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ReviewModel copyWith({
    String? id,
    String? productId,
    String? reviewerId,
    String? reviewerName,
    String? reviewerImageUrl,
    String? revieweeId,
    String? orderId,
    double? rating,
    String? comment,
    bool? isSellerReview,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewerImageUrl: reviewerImageUrl ?? this.reviewerImageUrl,
      revieweeId: revieweeId ?? this.revieweeId,
      orderId: orderId ?? this.orderId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      isSellerReview: isSellerReview ?? this.isSellerReview,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ReviewModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
