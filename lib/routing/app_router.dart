import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Route path constants.
///
/// All route paths are defined here to avoid hardcoded strings
/// throughout the application.
class RoutePaths {
  RoutePaths._();

  static const String home = '/';
  static const String search = '/search';
  static const String searchResults = '/search/results';
  static const String tripDetails = '/trips/:tripId';
  static const String seatSelection = '/trips/:tripId/seats';
  static const String passengerDetails = '/booking/passengers';
  static const String bookingSummary = '/booking/summary';
  static const String payment = '/booking/payment';
  static const String bookingConfirmation = '/booking/confirmation';
  static const String myTrips = '/my-trips';
  static const String ticketDetails = '/tickets/:ticketId';
  static const String profile = '/profile';
  static const String login = '/login';
  static const String register = '/register';

  // Operator routes
  static const String operatorDashboard = '/operator';
  static const String operatorBuses = '/operator/buses';
  static const String operatorRoutes = '/operator/routes';
  static const String operatorTrips = '/operator/trips';
  static const String operatorBookings = '/operator/bookings';
  static const String operatorScanner = '/operator/scanner';
}

/// Route name constants for named navigation.
class RouteNames {
  RouteNames._();

  static const String home = 'home';
  static const String search = 'search';
  static const String searchResults = 'searchResults';
  static const String tripDetails = 'tripDetails';
  static const String seatSelection = 'seatSelection';
  static const String passengerDetails = 'passengerDetails';
  static const String bookingSummary = 'bookingSummary';
  static const String payment = 'payment';
  static const String bookingConfirmation = 'bookingConfirmation';
  static const String myTrips = 'myTrips';
  static const String ticketDetails = 'ticketDetails';
  static const String profile = 'profile';
  static const String login = 'login';
  static const String register = 'register';
  static const String operatorDashboard = 'operatorDashboard';
}

/// GoRouter configuration for the application.
///
/// Routes are defined here and will be expanded as features are implemented.
/// Currently provides only the home route as a placeholder.
final goRouter = GoRouter(
  initialLocation: RoutePaths.home,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: RoutePaths.home,
      name: RouteNames.home,
      builder: (context, state) => const _PlaceholderHomeScreen(),
    ),
  ],
  errorBuilder: (context, state) => _ErrorScreen(
    error: state.error?.toString() ?? 'Page not found',
  ),
);

/// Riverpod provider for the GoRouter instance.
///
/// This allows other providers to access the router for
/// programmatic navigation.
final routerProvider = Provider<GoRouter>((ref) {
  return goRouter;
});

/// Placeholder home screen — will be replaced in Phase 3/4.
class _PlaceholderHomeScreen extends StatelessWidget {
  const _PlaceholderHomeScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EthioLiner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_bus,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'EthioLiner',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ethiopian Intercity Bus Booking',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'Your journey across Ethiopia starts here.\n'
                'Book intercity bus tickets with ease.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ElevatedButton(
                onPressed: () {
                  // Will navigate to search in Phase 4
                },
                child: const Text('Search Trips'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error screen shown for unmatched routes.
class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EthioLiner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RoutePaths.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
