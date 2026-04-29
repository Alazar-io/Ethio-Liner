import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/onboarding_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/booking/presentation/screens/booking_summary_screen.dart';
import '../features/booking/presentation/screens/passenger_details_screen.dart';
import '../features/booking/presentation/screens/payment_simulation_screen.dart';
import '../features/booking/presentation/screens/seat_selection_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/search/presentation/search_results_screen.dart';
import '../features/tickets/presentation/screens/my_trips_screen.dart';
import '../features/tickets/presentation/screens/ticket_screen.dart';
import '../features/trips/presentation/trip_details_screen.dart';
import '../shared/widgets/app_shell.dart';

/// Route path constants.
class RoutePaths {
  RoutePaths._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
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

/// Route name constants.
class RouteNames {
  RouteNames._();

  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
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

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter configuration for the application.
final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RoutePaths.splash,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: RoutePaths.splash,
      name: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RoutePaths.onboarding,
      name: RouteNames.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: RoutePaths.login,
      name: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RoutePaths.register,
      name: RouteNames.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: RoutePaths.searchResults,
      name: RouteNames.searchResults,
      builder: (context, state) {
        final origin = state.uri.queryParameters['origin'];
        final destination = state.uri.queryParameters['destination'];
        final dateStr = state.uri.queryParameters['date'];
        final passengersStr = state.uri.queryParameters['passengers'];
        return SearchResultsScreen(
          origin: origin,
          destination: destination,
          dateStr: dateStr,
          passengersStr: passengersStr,
        );
      },
    ),
    GoRoute(
      path: RoutePaths.tripDetails,
      name: RouteNames.tripDetails,
      builder: (context, state) {
        final tripId = state.pathParameters['tripId'] ?? '';
        return TripDetailsScreen(tripId: tripId);
      },
    ),
    GoRoute(
      path: RoutePaths.seatSelection,
      name: RouteNames.seatSelection,
      builder: (context, state) {
        final tripId = state.pathParameters['tripId'] ?? '';
        return SeatSelectionScreen(tripId: tripId);
      },
    ),
    GoRoute(
      path: RoutePaths.passengerDetails,
      name: RouteNames.passengerDetails,
      builder: (context, state) => const PassengerDetailsScreen(),
    ),
    GoRoute(
      path: RoutePaths.bookingSummary,
      name: RouteNames.bookingSummary,
      builder: (context, state) => const BookingSummaryScreen(),
    ),
    GoRoute(
      path: RoutePaths.payment,
      name: RouteNames.payment,
      builder: (context, state) => const PaymentSimulationScreen(),
    ),
    GoRoute(
      path: RoutePaths.ticketDetails,
      name: RouteNames.ticketDetails,
      builder: (context, state) {
        final ticketId = state.pathParameters['ticketId'] ?? '';
        return TicketScreen(ticketId: ticketId);
      },
    ),

    // App Shell navigation (Tabs)
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: RoutePaths.home,
          name: RouteNames.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: RoutePaths.search,
          name: RouteNames.search,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: RoutePaths.myTrips,
          name: RouteNames.myTrips,
          builder: (context, state) => const MyTripsScreen(),
        ),
        GoRoute(
          path: RoutePaths.profile,
          name: RouteNames.profile,
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => _ErrorScreen(
    error: state.error?.toString() ?? 'Page not found',
  ),
);

/// Riverpod provider for GoRouter.
final routerProvider = Provider<GoRouter>((ref) {
  return goRouter;
});

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
