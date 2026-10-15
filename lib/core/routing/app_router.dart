import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/splash_screen.dart';
import '../../features/auth/onboarding_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/role_selection_screen.dart';
import '../../features/donor/donor_home_screen.dart';
import '../../features/donor/donation_tracking_screen.dart';
import '../../features/ngo/ngo_home_screen.dart';
import '../../features/ngo/create_request_screen.dart';
import '../../features/rider/rider_home_screen.dart';
import '../../features/rider/active_delivery_screen.dart';
import '../../features/donor/create_donation_screen.dart';
import '../../core/providers/app_providers.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                  parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/role-selection',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const RoleSelectionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                  parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
        ),
      ),
      // Donor
      GoRoute(
        path: '/donor/home',
        builder: (context, state) => const DonorHomeScreen(),
      ),
      GoRoute(
        path: '/donor/create-donation',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const CreateDonationScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                  parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/donor/track-donation',
        pageBuilder: (context, state) {
          final donation = (state.extra is Donation)
              ? (state.extra as Donation)
              : Donation(
                  id: 'd1',
                  foodName: 'Rice and Lentil Curry',
                  category: 'Cooked Meals',
                  quantity: '5',
                  unit: 'kg',
                  servings: 30,
                  condition: 'Freshly Prepared',
                  isUrgent: true,
                  postedAt: DateTime.now().subtract(const Duration(minutes: 40)),
                  status: DonationStatus.inTransit,
                  matchedNgo: 'Helping Hands Foundation',
                  riderId: 'R-201',
                );
          return CustomTransitionPage(
            child: DonationTrackingScreen(donation: donation),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                    parent: animation, curve: Curves.easeOutCubic)),
                child: child,
              );
            },
          );
        },
      ),
      // NGO
      GoRoute(
        path: '/ngo/home',
        builder: (context, state) => const NgoHomeScreen(),
      ),
      GoRoute(
        path: '/ngo/create-request',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const CreateRequestScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                  parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
        ),
      ),
      // Rider
      GoRoute(
        path: '/rider/home',
        builder: (context, state) => const RiderHomeScreen(),
      ),
      GoRoute(
        path: '/rider/active-delivery',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const ActiveDeliveryScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
    ],
  );
});
