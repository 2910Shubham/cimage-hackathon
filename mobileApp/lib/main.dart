import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'splashScreen.dart';
import 'web_view_screen.dart';
import 'package:mobileapp/splashScreen.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const CimageHackathonSplash(),
    ),
    GoRoute(
      path: '/webview',
      builder: (context, state) =>
          const WebViewScreen(url: 'https://webapp-cimage-hackthon.vercel.app/'),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Cimage Hackathon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}

