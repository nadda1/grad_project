import 'package:shared_preferences/shared_preferences.dart';

class NavigationService {
  final List<String> _pastRoutes = ['/']; // Assuming '/' is your home route
  final List<String> _forwardRoutes = [];

  Future<void> navigateTo(String route) async {
    _pastRoutes.add(route);
    _forwardRoutes
        .add(route); // Clear forward history when navigating to a new route.
    await _updateLastRoute(route);
  }

  Future<void> _updateLastRoute(String route) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_route', route);
  }

  bool canGoBack() => _pastRoutes.length > 1;

  bool canGoForward() => _forwardRoutes.isNotEmpty;

  String goBack() {
    if (canGoBack()) {
      final lastRoute = _pastRoutes.removeLast();
      _forwardRoutes.add(lastRoute);
      return _pastRoutes.last;
    }
    return '/';
  }

  String goForward() {
    if (canGoForward()) {
      final route = _forwardRoutes.removeLast();
      _pastRoutes.add(route);
      return route;
    }
    return '/';
  }
}
