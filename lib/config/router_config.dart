// 导入Riverpod状态管理库
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 导入GoRouter路由管理库
import 'package:go_router/go_router.dart';
// 导入登录界面
import 'package:library_management/presentation/screens/auth/login_screen.dart';
// 导入注册界面
import 'package:library_management/presentation/screens/auth/register_screen.dart';
// 导入主界面
import 'package:library_management/presentation/screens/home/home_screen.dart';
// 导入启动界面
import 'package:library_management/presentation/screens/splash/splash_screen.dart';
// 导入图书详情界面
import 'package:library_management/presentation/screens/book/book_detail_screen.dart';

// 路由提供者,管理应用的所有路由配置
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    // 初始路由路径
    initialLocation: '/',
    // 路由列表
    routes: [
      // 启动页路由
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      // 登录页路由
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      // 注册页路由
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // 主页路由
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      // 图书详情页路由,带参数id
      GoRoute(
        path: '/book/:id',
        name: 'book-detail',
        builder: (context, state) {
          // 从路径参数中获取图书ID
          final bookId = state.pathParameters['id']!;
          return BookDetailScreen(bookId: bookId);
        },
      ),
    ],
    // 路由重定向逻辑
    redirect: (context, state) {
      // 在此处添加身份验证逻辑
      return null;
    },
  );
});
