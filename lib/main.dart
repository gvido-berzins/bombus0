import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/search_screen.dart';
import 'screens/registry_screen.dart';

void main() {
  runApp(const ProviderScope(child: BombusApp()));
}

class BombusApp extends StatelessWidget {
  const BombusApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bombus - Bumble Bee Identifier',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.amber.shade100,
          foregroundColor: Colors.black87,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.shade600,
            foregroundColor: Colors.black87,
            elevation: 2,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.amber.shade600,
          foregroundColor: Colors.black87,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = [
    const SearchScreen(),
    const RegistryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Hide system UI for immersive experience
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.amber.shade700,
          unselectedItemColor: Colors.grey.shade600,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              activeIcon: Icon(Icons.search, size: 28),
              label: 'Search',
              tooltip: 'Identify bees by color',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              activeIcon: Icon(Icons.book, size: 28),
              label: 'Registry',
              tooltip: 'View your findings',
            ),
          ],
        ),
      ),
    );
  }
}
