import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suresh_app/providers/user_provider.dart';
import 'services/api_client.dart';
import 'providers/auth_provider_updated.dart';
import 'providers/category_provider.dart';
import 'providers/product_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/gst_master_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Get token from SharedPreferences
  final token = prefs.getString('auth_token') ?? '';

  // Initialize ApiClient with token (named parameter)
  final apiClient = ApiClient(token: token);

  runApp(MyApp(
    prefs: prefs,
    apiClient: apiClient,
  ));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final ApiClient apiClient;

  const MyApp({
    Key? key,
    required this.prefs,
    required this.apiClient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(apiClient, prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(apiClient),
        ),
        ChangeNotifierProvider(create: (_) => ProductProvider(apiClient)),
        ChangeNotifierProvider(
          create: (_) => CustomerProvider(apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => GstMasterProvider(apiClient),
        ),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Suresh Enterprise',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
