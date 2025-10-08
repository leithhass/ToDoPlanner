import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todolocal/services/notification_service.dart';

import 'core/theme.dart';
import 'features/todos/data/todo_box.dart';
import 'features/todos/presentation/pages/todos_home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await TodoBox.init();
  await NotificationService.instance.init();
  runApp(const ProviderScope(child: LunaApp()));
}

class LunaApp extends StatefulWidget {
  const LunaApp({super.key});

  @override
  State<LunaApp> createState() => _LunaAppState();
}

class _LunaAppState extends State<LunaApp> {
  late final GoRouter _router = GoRouter(
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (_, __) => const TodosHome()),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Luna – Local Starter',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
