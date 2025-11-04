import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/user.dart';
import '../providers/user_provider.dart';
import '../widgets/loading_indicator.dart';
import 'user_form_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  Future<void> _refreshUsers() async {
    try {
      await Provider.of<UserProvider>(context, listen: false).fetchUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing users: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshUsers());
  }

  void _showAddEditBottomSheet(BuildContext context, [User? user]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return UserFormSheet(
          user: user,
          onSuccess: _refreshUsers,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey,
      ),
      body: Consumer<UserProvider>(
        builder: (ctx, userProvider, child) {
          if (userProvider.isLoading) {
            return const LoadingIndicator();
          }

          if (userProvider.errorMessage != null &&
              userProvider.errorMessage!.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${userProvider.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshUsers,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (userProvider.users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_alt, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No users found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddEditBottomSheet(context),
                    child: const Text('Add User'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshUsers,
            child: ListView.builder(
              itemCount: userProvider.users.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (ctx, index) {
                final user = userProvider.users[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          user.status == 'active' ? Colors.blue : Colors.grey,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(user.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.email,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(user.email,
                                  style: const TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        if (user.phone != null && user.phone!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.phone,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(user.phone!,
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () =>
                              _showAddEditBottomSheet(context, user),
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete User'),
                                content:
                                    Text('Delete ${user.name}? This can\'t be undone.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      if (user.id != null) {
                                        final success =
                                            await Provider.of<UserProvider>(
                                                    context,
                                                    listen: false)
                                                .deleteUser(
                                                    user.id.toString());
                                        if (mounted) {
                                          Navigator.pop(ctx);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(success
                                                ? 'User deleted successfully'
                                                : 'Failed to delete user'),
                                            backgroundColor: success
                                                ? Colors.green
                                                : Colors.red,
                                          ));
                                          _refreshUsers();
                                        }
                                      }
                                    },
                                    child: const Text('Delete',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditBottomSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}