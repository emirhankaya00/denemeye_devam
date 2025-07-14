import 'package:flutter/material.dart';
// veya alternatif olarak
// import 'package:flutter/foundation.dart';

class SearchViewModel extends ChangeNotifier {
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleSearch(bool value) {
    _isSearching = value;
    if (!value) {
      _searchQuery = ''; // Arama kapatıldığında sorguyu temizle
    }
    notifyListeners();
  }
}