import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:library_management/presentation/screens/auth/login_screen.dart';
import 'package:library_management/presentation/screens/auth/register_screen.dart';
import 'package:library_management/presentation/screens/home/home_screen.dart';
import 'package:library_management/presentation/screens/splash/splash_screen.dart';
import 'package:library_management/presentation/screens/book/book_detail_screen.dart';

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/book/:id',
        name: 'book-detail',
        builder: (context, state) {
          final bookId = state.pathParameters['id']!;
          return BookDetailScreen(bookId: bookId);
        },
      ),
    ],
    redirect: (context, state) {
      // Add authentication logic here
      return null;
    },
  );
});
