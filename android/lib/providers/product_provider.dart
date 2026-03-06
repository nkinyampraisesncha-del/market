import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/supabase_service.dart';
import '../utils/constants.dart';

class ProductProvider extends ChangeNotifier {
  final SupabaseService _service = SupabaseService();

  List<ProductModel> _products = [];
  List<ProductModel> _featuredProducts = [];
  List<ProductModel> _searchResults = [];
  List<String> _favoriteIds = [];
  ProductModel? _selectedProduct;

  bool _isLoading = false;
  bool _isSearching = false;
  String? _errorMessage;
  String _selectedCategory = '';
  String _searchQuery = '';
  int _currentPage = 0;
  bool _hasMore = true;

  List<ProductModel> get products => _products;
  List<ProductModel> get featuredProducts => _featuredProducts;
  List<ProductModel> get searchResults => _searchResults;
  List<String> get favoriteIds => _favoriteIds;
  ProductModel? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  bool get hasMore => _hasMore;

  Future<void> loadProducts({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 0;
      _hasMore = true;
      _products = [];
    }

    if (!_hasMore) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _service.getProducts(
        category: _selectedCategory.isNotEmpty ? _selectedCategory : null,
        page: _currentPage,
      );

      if (refresh) {
        _products = results;
      } else {
        _products.addAll(results);
      }

      _hasMore = results.length == AppConstants.pageSize;
      _currentPage++;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFeaturedProducts() async {
    try {
      final results = await _service.getProducts(limit: 6);
      _featuredProducts = results;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _searchQuery = '';
      notifyListeners();
      return;
    }

    _searchQuery = query;
    _isSearching = true;
    notifyListeners();

    try {
      _searchResults = await _service.searchProducts(query);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<void> selectProduct(String productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedProduct = await _service.getProductById(productId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    if (_selectedCategory == category) {
      _selectedCategory = '';
    } else {
      _selectedCategory = category;
    }
    loadProducts(refresh: true);
  }

  Future<void> loadFavorites(String userId) async {
    try {
      _favoriteIds = await _service.getFavoriteIds(userId);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleFavorite(String userId, String productId) async {
    final isFav = _favoriteIds.contains(productId);
    if (isFav) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    notifyListeners();

    try {
      if (isFav) {
        await _service.removeFavorite(userId, productId);
      } else {
        await _service.addFavorite(userId, productId);
      }
    } catch (_) {
      // Revert on error
      if (isFav) {
        _favoriteIds.add(productId);
      } else {
        _favoriteIds.remove(productId);
      }
      notifyListeners();
    }
  }

  bool isFavorited(String productId) => _favoriteIds.contains(productId);

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
