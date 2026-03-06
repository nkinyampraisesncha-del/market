import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/listing_model.dart';
import '../models/rental_model.dart';
import '../models/review_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // ─── Products ─────────────────────────────────────────────────────────────

  Future<List<ProductModel>> getProducts({
    String? category,
    String? search,
    String? universityId,
    int page = 0,
    int limit = AppConstants.pageSize,
  }) async {
    var query = _client
        .from('listings')
        .select('*, profiles!seller_id(name, profile_image_url)')
        .eq('status', 'active')
        .range(page * limit, (page + 1) * limit - 1)
        .order('created_at', ascending: false);

    if (category != null && category.isNotEmpty) {
      query = query.eq('category', category);
    }
    if (universityId != null && universityId.isNotEmpty) {
      query = query.eq('university_id', universityId);
    }

    final response = await query;
    return (response as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<ProductModel?> getProductById(String id) async {
    final response = await _client
        .from('listings')
        .select('*, profiles!seller_id(name, profile_image_url)')
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return ProductModel.fromJson(response);
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final response = await _client
        .from('listings')
        .select()
        .eq('status', 'active')
        .ilike('title', '%$query%')
        .limit(AppConstants.pageSize);
    return (response as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  // ─── Listings (Seller) ────────────────────────────────────────────────────

  Future<List<ListingModel>> getSellerListings(String sellerId) async {
    final response = await _client
        .from('listings')
        .select()
        .eq('seller_id', sellerId)
        .order('created_at', ascending: false);
    return (response as List).map((e) => ListingModel.fromJson(e)).toList();
  }

  Future<ListingModel> createListing(Map<String, dynamic> data) async {
    final response =
        await _client.from('listings').insert(data).select().single();
    return ListingModel.fromJson(response);
  }

  Future<ListingModel> updateListing(
      String id, Map<String, dynamic> data) async {
    final response = await _client
        .from('listings')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return ListingModel.fromJson(response);
  }

  Future<void> deleteListing(String id) async {
    await _client.from('listings').delete().eq('id', id);
  }

  // ─── Orders ───────────────────────────────────────────────────────────────

  Future<List<OrderModel>> getBuyerOrders(String buyerId) async {
    final response = await _client
        .from('orders')
        .select()
        .eq('buyer_id', buyerId)
        .order('created_at', ascending: false);
    return (response as List).map((e) => OrderModel.fromJson(e)).toList();
  }

  Future<List<OrderModel>> getSellerOrders(String sellerId) async {
    final response = await _client
        .from('orders')
        .select()
        .eq('seller_id', sellerId)
        .order('created_at', ascending: false);
    return (response as List).map((e) => OrderModel.fromJson(e)).toList();
  }

  Future<OrderModel> createOrder(Map<String, dynamic> data) async {
    final response =
        await _client.from('orders').insert(data).select().single();
    return OrderModel.fromJson(response);
  }

  Future<OrderModel> updateOrderStatus(String id, String status) async {
    final response = await _client
        .from('orders')
        .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id)
        .select()
        .single();
    return OrderModel.fromJson(response);
  }

  // ─── Rentals ──────────────────────────────────────────────────────────────

  Future<List<RentalModel>> getBuyerRentals(String renterId) async {
    final response = await _client
        .from('rentals')
        .select()
        .eq('renter_id', renterId)
        .order('created_at', ascending: false);
    return (response as List).map((e) => RentalModel.fromJson(e)).toList();
  }

  Future<List<RentalModel>> getSellerRentals(String ownerId) async {
    final response = await _client
        .from('rentals')
        .select()
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false);
    return (response as List).map((e) => RentalModel.fromJson(e)).toList();
  }

  // ─── Reviews ──────────────────────────────────────────────────────────────

  Future<List<ReviewModel>> getProductReviews(String productId) async {
    final response = await _client
        .from('reviews')
        .select()
        .eq('product_id', productId)
        .order('created_at', ascending: false);
    return (response as List).map((e) => ReviewModel.fromJson(e)).toList();
  }

  Future<ReviewModel> createReview(Map<String, dynamic> data) async {
    final response =
        await _client.from('reviews').insert(data).select().single();
    return ReviewModel.fromJson(response);
  }

  // ─── Messages ─────────────────────────────────────────────────────────────

  Future<List<ConversationModel>> getConversations(String userId) async {
    final response = await _client
        .from('conversations')
        .select()
        .contains('participant_ids', [userId])
        .order('last_message_at', ascending: false);
    return (response as List)
        .map((e) => ConversationModel.fromJson(e))
        .toList();
  }

  Future<List<MessageModel>> getMessages(String conversationId) async {
    final response = await _client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);
    return (response as List).map((e) => MessageModel.fromJson(e)).toList();
  }

  Future<MessageModel> sendMessage(Map<String, dynamic> data) async {
    final response =
        await _client.from('messages').insert(data).select().single();
    return MessageModel.fromJson(response);
  }

  RealtimeChannel subscribeToMessages(
    String conversationId,
    void Function(MessageModel) onMessage,
  ) {
    return _client
        .channel('messages:$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            if (payload.newRecord.isNotEmpty) {
              onMessage(MessageModel.fromJson(payload.newRecord));
            }
          },
        )
        .subscribe();
  }

  // ─── Favorites ────────────────────────────────────────────────────────────

  Future<List<String>> getFavoriteIds(String userId) async {
    final response = await _client
        .from('favorites')
        .select('product_id')
        .eq('user_id', userId);
    return (response as List)
        .map((e) => e['product_id'].toString())
        .toList();
  }

  Future<void> addFavorite(String userId, String productId) async {
    await _client.from('favorites').upsert({
      'user_id': userId,
      'product_id': productId,
    });
  }

  Future<void> removeFavorite(String userId, String productId) async {
    await _client
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('product_id', productId);
  }

  // ─── Admin ────────────────────────────────────────────────────────────────

  Future<List<UserModel>> getAllUsers({int page = 0}) async {
    final response = await _client
        .from('profiles')
        .select()
        .range(page * 50, (page + 1) * 50 - 1)
        .order('created_at', ascending: false);
    return (response as List).map((e) => UserModel.fromJson(e)).toList();
  }

  Future<List<ListingModel>> getPendingApprovals() async {
    final response = await _client
        .from('listings')
        .select()
        .eq('status', 'pending_approval')
        .order('created_at', ascending: false);
    return (response as List).map((e) => ListingModel.fromJson(e)).toList();
  }

  Future<void> approveListing(String id) async {
    await _client.from('listings').update({
      'status': 'active',
      'approved_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> rejectListing(String id, String reason) async {
    await _client.from('listings').update({
      'status': 'rejected',
      'rejection_reason': reason,
    }).eq('id', id);
  }

  Future<Map<String, dynamic>> getAdminStats() async {
    final users = await _client.from('profiles').select('id', const FetchOptions(count: CountOption.exact, head: true));
    final listings = await _client.from('listings').select('id', const FetchOptions(count: CountOption.exact, head: true));
    final orders = await _client.from('orders').select('id', const FetchOptions(count: CountOption.exact, head: true));

    return {
      'total_users': users.count ?? 0,
      'total_listings': listings.count ?? 0,
      'total_orders': orders.count ?? 0,
    };
  }
}
