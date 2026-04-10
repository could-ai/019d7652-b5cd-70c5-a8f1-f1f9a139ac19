import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/data_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/machine_detail_screen.dart';
import 'screens/add_replacement_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/reports_screen.dart';

void main() {
  runApp(const NzaroMillManager());
}

class NzaroMillManager extends StatelessWidget {
  const NzaroMillManager({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataProvider()),
      ],
      child: MaterialApp(
        title: 'NzaroMill Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: const ColorScheme(
            primary: Color(0xFF1E3A8A), // Industrial Blue
            secondary: Color(0xFFF97316), // Safety Orange
            surface: Colors.white,
            background: Colors.white,
            error: Colors.red,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Color(0xFF1E3A8A),
            onBackground: Color(0xFF1E3A8A),
            onError: Colors.white,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E3A8A),
            foregroundColor: Colors.white,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFF97316),
            foregroundColor: Colors.white,
          ),
        ),
        initialRoute: '/login',
        routes: {
          '/': (context) => const LoginScreen(),
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/machine_detail': (context) => const MachineDetailScreen(),
          '/add_replacement': (context) => const AddReplacementScreen(),
          '/inventory': (context) => const InventoryScreen(),
          '/reports': (context) => const ReportsScreen(),
        },
      ),
    );
  }
}
