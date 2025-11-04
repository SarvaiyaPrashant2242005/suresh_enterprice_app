// suresh_app/lib/main_with_api.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_client.dart';
// UPDATED: use the unified provider file
import 'providers/auth_provider_updated.dart';
import 'providers/category_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  final apiClient = ApiClient(token: token);

  runApp(MyApp(apiClient: apiClient, prefs: prefs));
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;
  final SharedPreferences prefs;

  const MyApp({Key? key, required this.apiClient, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // UPDATED: constructor for the updated provider
        ChangeNotifierProvider(create: (_) => AuthProvider(apiClient, prefs)),
        ChangeNotifierProvider(create: (_) => CategoryProvider(apiClient)),
      ],
      child: MaterialApp(
        title: 'Suresh Enterprise App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}