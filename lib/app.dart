import 'package:flutter/material.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/tos_screen.dart';
import 'presentation/screens/phishing_screen.dart';
import 'presentation/theme/app_them.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _currentIndex = 0;
  int _homeRefreshKey = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardian AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      builder: (context, child) => Container(
        color: const Color(0xFF1A1A2E),
        child: Center(
          child: SizedBox(
            width: 390,
            height: 844,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: child!,
            ),
          ),
        ),
      ),
      home: Scaffold(
        body: [
          HomeScreen(
            key: ValueKey(_homeRefreshKey),
            onNavigateToTab: (index) => setState(() => _currentIndex = index),
          ),
          const TosScreen(),
          const PhishingScreen(),
        ][_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() {
            if (index == 0) _homeRefreshKey++;
            _currentIndex = index;
          }),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description),
              label: '약관 분석',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.security),
              label: '피싱 탐지',
            ),
          ],
        ),
      ),
    );
  }
}