import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'models/transaction.dart';
import 'models/budget.dart';
import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/streak_provider.dart';
import 'providers/theme_provider.dart';
import 'router/app_router.dart';
import 'utils/constants.dart';

void main() async {
  // Ensures Flutter is ready before running async code
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Hive.initFlutter();

  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(BudgetAdapter());

  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox<Budget>('budgets');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => BudgetProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => StreakProvider()..init(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'Finance Tracker',

            debugShowCheckedModeBanner: false,

            // Light theme configuration
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
              ),
              useMaterial3: true,
            ),

            // Dark theme configuration
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),

            themeMode: themeProvider.themeMode,

            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
