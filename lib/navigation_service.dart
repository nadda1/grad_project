class NavigationService {
  final List<String> _pastRoutes = ['/']; // Assuming '/' is your home route.
  final List<String> _forwardRoutes = [];

  void navigateTo(String route) {
    _pastRoutes.add(route);
    _forwardRoutes.add(route); // Clear forward history when navigating to a new route.
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
