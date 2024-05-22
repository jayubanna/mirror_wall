import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  bool isLoad = true;
  double webProgress = 0;

  void onChangeLoad(bool isLoad) {
    this.isLoad = isLoad;
    notifyListeners();
  }

  void onWebProgress(double webProgress) {
    this.webProgress = webProgress;
    notifyListeners();
  }

  int _searchEngineValue = 1;
  String _searchEngine = "https://www.google.com/search?q=";
  List<String> bookmarks = [];

  final List<Map<String, String>> searchEngines = [
    {'name': 'Google', 'url': 'https://www.google.com/search?q='},
    {'name': 'Yahoo', 'url': 'https://search.yahoo.com/search?p= '},
    {'name': 'Bing', 'url': 'https://www.bing.com/search?q='},
    {'name': 'DuckDuckGo', 'url': 'https://duckduckgo.com/?q='},
  ];

  int get searchEngineValue => _searchEngineValue;

  String get searchEngine => _searchEngine;

  void setSearchEngine(int value) {
    _searchEngineValue = value;
    _searchEngine = searchEngines[value]['url']!;
    notifyListeners();
  }

  void addBookmark(String url) {
    if (!bookmarks.contains(url)) {
      bookmarks.add(url);
      notifyListeners();
    }
  }

  bool Android_Theme_Mode = false;

  void change_Android_Theme() {
    Android_Theme_Mode = !Android_Theme_Mode;
    notifyListeners();
  }

  void removeBookmark(String bookmark) {
    bookmarks.remove(bookmark);
    notifyListeners();
  }
}
