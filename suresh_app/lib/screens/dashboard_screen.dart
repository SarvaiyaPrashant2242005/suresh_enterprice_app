import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/sidebar_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _title = 'Dashboard';

  void _onSelect(String title) {
    setState(() {
      _title = title;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().authData;
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      drawer: SidebarDrawer(onSelect: _onSelect),
      body: Center(
        child: Text(
          'Selected: ' + _title,
          style: theme.textTheme.headlineSmall,
        ),
      ),
    );
  }

  
}


