import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/mock_service.dart';
import '../services/local_storage.dart';

class AppProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LocalStorage _localStorage = LocalStorage();

  List<Category> _categories = [];
  List<AppBanner> _banners = [];
  List<Establishment> _featuredEstablishments = [];
  List<Establishment> _allEstablishments = []; 
  Set<String> _favoriteIds = {};
  bool _isLoading = false;
  bool _isDarkMode = false; 
  bool _isAdminAuthenticated = false;
  String? _sessionToken;
  int _currentTabIndex = 0;

  List<Category> get categories => _categories;
  List<AppBanner> get banners => _banners;
  List<Establishment> get featuredEstablishments => _featuredEstablishments;
  List<Establishment> get allEstablishments => _allEstablishments;
  List<Establishment> get searchResults => _searchResults;
  Set<String> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  bool get isAdminAuthenticated => _isAdminAuthenticated;
  String? get sessionToken => _sessionToken;
  int get currentTabIndex => _currentTabIndex;

  // Search Results
  List<Establishment> _searchResults = [];

  String? _errorMessage;
  bool _hasNetworkError = false;

  String? get errorMessage => _errorMessage;
  bool get hasNetworkError => _hasNetworkError;

  Future<void> initData() async {
    _isLoading = true;
    _hasNetworkError = false;
    _errorMessage = null;
    notifyListeners();

    // 1. TRY TO LOAD FROM LOCAL CACHE FIRST
    try {
      final localCats = await _localStorage.getCategories();
      final localSubs = await _localStorage.getSubCategories();
      final localBanners = await _localStorage.getBanners();
      final localEsts = await _localStorage.getEstablishments();
      final localFavs = await _localStorage.getFavorites();

      if (localCats.isNotEmpty || localEsts.isNotEmpty) {
        debugPrint("--- LOADING FROM CACHE ---");
        List<Category> rawCategories = localCats.map((json) => Category.fromJson(json)).toList();
        List<SubCategory> allSubCategories = localSubs.map((json) => SubCategory.fromJson(json)).toList();
        _banners = localBanners.map((json) => AppBanner.fromJson(json)).toList();
        _allEstablishments = localEsts.map((json) => Establishment.fromJson(json)).toList();
        _favoriteIds = localFavs.toSet();
        
        // Featured are just the first few for now or based on a flag
        _featuredEstablishments = _allEstablishments.where((e) => e.isFeatured).toList();
        if (_featuredEstablishments.isEmpty && _allEstablishments.isNotEmpty) {
          _featuredEstablishments = _allEstablishments.take(5).toList();
        }

        // Stitch SubCategories into Categories
        _categories = rawCategories.map((cat) {
          final subs = allSubCategories.where((s) => s.parentId == cat.id).toList();
          return Category(
            id: cat.id,
            name: cat.name,
            icon: cat.icon,
            subCategories: subs
          );
        }).toList();

        // Initial UI update with cached data
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading from local storage: $e");
    }

    // 2. FETCH FRESH DATA FROM API
    try {
      debugPrint("--- FETCHING FRESH DATA FROM API ---");
      final futures = await Future.wait([
        _apiService.getCategories(),
        _apiService.getAllSubCategories(),
        _apiService.getBanners(),
        _apiService.getRecentEstablishments(),
        _apiService.getEstablishments(),
        _localStorage.getFavorites(),
      ]).timeout(
        const Duration(seconds: 15), // Reduced timeout as we have cache
      );

      List<Category> rawCategories = futures[0] as List<Category>;
      List<SubCategory> allSubCategories = futures[1] as List<SubCategory>;
      _banners = futures[2] as List<AppBanner>;
      _featuredEstablishments = futures[3] as List<Establishment>;
      _allEstablishments = futures[4] as List<Establishment>;
      _favoriteIds = (futures[5] as List<String>).toSet();

      // Stitch SubCategories into Categories
      _categories = rawCategories.map((cat) {
        final subs = allSubCategories.where((s) => s.parentId == cat.id).toList();
        return Category(
          id: cat.id,
          name: cat.name,
          icon: cat.icon,
          subCategories: subs
        );
      }).toList();

      // 3. UPDATE LOCAL CACHE ON SUCCESS
      await _localStorage.saveCategories(rawCategories.map((e) => e.toJson()).toList());
      await _localStorage.saveSubCategories(allSubCategories.map((e) => e.toJson()).toList());
      await _localStorage.saveBanners(_banners.map((e) => e.toJson()).toList());
      await _localStorage.saveEstablishments(_allEstablishments.map((e) => e.toJson()).toList());

      _hasNetworkError = false;
      _errorMessage = null;

    } catch (e) {
      debugPrint("Error loading data from API: $e");
      // Only show error if we have NO data at all
      if (_categories.isEmpty && _allEstablishments.isEmpty) {
        _hasNetworkError = true;
        _errorMessage = 'Error al cargar datos. Verifica tu conexión.';
      } else {
        // We have cached data, so just log it and maybe show a snackbar elsewhere
        _hasNetworkError = true; // Still mark as error but don't clear data
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Retry loading data
  Future<void> retryLoadData() async {
    await initData();
  }

  Future<void> toggleFavorite(String id) async {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
      await _localStorage.removeFavorite(id);
    } else {
      _favoriteIds.add(id);
      await _localStorage.addFavorite(id);
    }
    notifyListeners();
  }

  bool isFavorite(String id) {
    return _favoriteIds.contains(id);
  }

  void search(String query) {
    if (query.isEmpty) {
      _searchResults = [];
    } else {
      _searchResults = _allEstablishments.where((e) => 
        e.name.toLowerCase().contains(query.toLowerCase()) || 
        e.description.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    notifyListeners();
  }

  Future<List<Establishment>> getByCategory(String categoryId) async {
     return _allEstablishments.where((e) => e.categoryId == categoryId).toList();
  }
  
  Future<void> refresh() async {
    await initData();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // --- CRUD METHODS ---
  // Implemented to fix Admin Panel build errors. 
  // Delegates to ApiService and refreshes data on success.

  // Categories
  Future<void> addCategory(Category category) async {
    final success = await _apiService.createCategory(category);
    if (success) await refresh();
  }

  Future<void> updateCategory(Category category) async {
     final success = await _apiService.updateCategory(category);
     if (success) await refresh();
  }

  Future<void> deleteCategory(String id) async {
     final success = await _apiService.deleteCategory(id);
     if (success) await refresh();
     else {
       // Optimistic local delete if API not ready?
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
     }
  }

  // SubCategories
  Future<void> addSubCategory(SubCategory sub) async {
    final success = await _apiService.createSubCategory(sub);
    if (success) await refresh();
  }

  Future<void> updateSubCategory(SubCategory sub) async {
     await _apiService.updateSubCategory(sub);
     await refresh();
  }

  Future<void> deleteSubCategory(String id, String parentId) async {
      await _apiService.deleteSubCategory(id);
      await refresh(); 
  }

  // Banners
  Future<void> addBanner(AppBanner banner) async {
     // Assuming banner has image path or URL
     await _apiService.createBanner(banner, banner.imageUrl); 
     await refresh();
  }

  Future<void> deleteBanner(String id) async {
    await _apiService.deleteBanner(id);
    await refresh();
  }

  // Establishments
  Future<void> addEstablishment(Establishment est) async {
     // Pass images if available in est (Need to adjust Est model or form to pass paths)
     await _apiService.createEstablishment(est, est.galleryImages);
     await refresh();
  }

  Future<void> updateEstablishment(Establishment est) async {
      await _apiService.updateEstablishment(est);
      await refresh();
  }

  Future<void> deleteEstablishment(String id) async {
    await _apiService.deleteEstablishment(id);
    await refresh();
  }

  // Auth
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    final responseData = await _apiService.login(email, password);
    
    if (responseData != null && responseData['success'] == true) {
      _isAdminAuthenticated = true;
      final data = responseData['data'];
      if (data != null && data['session_token'] != null) {
        _sessionToken = data['session_token'];
        // In a real app, store this in LocalStorage
      }
    } else {
      _isAdminAuthenticated = false;
    }
    
    _isLoading = false;
    notifyListeners();
    return _isAdminAuthenticated;
  }

  void logout() {
    _isAdminAuthenticated = false;
    _sessionToken = null;
    notifyListeners();
  }

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }
}
