import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'database/database_factory_config.dart';
import 'providers/movie_provider.dart';
import 'providers/my_list_provider.dart';
import 'providers/roulette_provider.dart';
import 'screens/details_screen.dart';
import 'screens/home_screen.dart';
import 'screens/my_list_screen.dart';
import 'screens/roulette_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDatabaseFactory();
  runApp(const CineMatchApp());
}

class CineMatchApp extends StatelessWidget {
  const CineMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        ChangeNotifierProvider(create: (_) => MyListProvider()),
        ChangeNotifierProvider(create: (_) => RouletteProvider()),
      ],
      child: MaterialApp(
        title: 'Cine Match',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/roulette': (context) => const RouletteScreen(),
          '/my-list': (context) => const MyListScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == DetailsScreen.routeName) {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => const DetailsScreen(),
            );
          }
          return null;
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (context) => const HomeScreen());
        },
      ),
    );
  }
}
