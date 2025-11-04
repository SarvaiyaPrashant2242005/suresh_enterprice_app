import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../model/user.dart';

class UserFormSheet extends StatefulWidget {
  final User? user;
  final VoidCallback onSuccess;

  const UserFormSheet({
    super.key,
    required this.user,
    required this.onSuccess,
  });

  @override
  State<UserFormSheet> createState() => _UserFormSheetState();
}

class _UserFormSheetState extends State<UserFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final List<String> _userTypes = ['Admin', 'Manager', 'Customer User', 'Sales User'];
  final List<String> _statusOptions = ['active', 'inactive', 'suspended'];

  String _selectedUserType = 'Customer User';
  String _selectedStatus = 'active';
  bool _withGst = true;
  bool _withoutGst = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      final u = widget.user!;
      _nameController.text = u.name;
      _emailController.text = u.email;
      _phoneController.text = u.phone ?? '';
      _selectedUserType = u.userType ?? 'Customer User';
      _selectedStatus = u.status ?? 'active';
      _withGst = u.withGst;
      _withoutGst = u.withoutGst;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final userData = User(
      id: widget.user?.id,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.isEmpty ? null : _phoneController.text.trim(),
      password: widget.user == null ? _passwordController.text : null,
      userType: _selectedUserType,
      status: _selectedStatus,
      withGst: _withGst,
      withoutGst: _withoutGst,
    );

    bool success;
    if (widget.user == null) {
      success = await Provider.of<UserProvider>(context, listen: false)
          .addUser(userData, _passwordController.text);
    } else {
      success = await Provider.of<UserProvider>(context, listen: false)
          .updateUser(widget.user!.id.toString(), userData);
    }

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success
          ? widget.user == null
              ? 'User added successfully'
              : 'User updated successfully'
          : 'Operation failed'),
      backgroundColor: success ? Colors.green : Colors.red,
    ));

    if (success) widget.onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 24,
          bottom: mediaQuery.viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.user == null ? 'Add User' : 'Edit User',
                        style: Theme.of(context).textTheme.headlineSmall),
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      labelText: 'Name', prefixIcon: Icon(Icons.person)),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Please enter name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      labelText: 'Email', prefixIcon: Icon(Icons.email)),
                  keyboardType: TextInputType.emailAddress,
                  enabled: widget.user == null,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter email';
                    if (!v.contains('@')) return 'Enter valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                      labelText: 'Phone', prefixIcon: Icon(Icons.phone)),
                  keyboardType: TextInputType.phone,
                ),
                if (widget.user == null) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter password';
                      if (v.length < 6) return 'Min 6 characters';
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedUserType,
                  items: _userTypes
                      .map((type) =>
                          DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedUserType = v!),
                  decoration: const InputDecoration(
                      labelText: 'User Type',
                      prefixIcon: Icon(Icons.admin_panel_settings)),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  items: _statusOptions
                      .map((s) =>
                          DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedStatus = v!),
                  decoration: const InputDecoration(
                      labelText: 'Status', prefixIcon: Icon(Icons.info)),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('GST Options',
                              style: Theme.of(context).textTheme.titleMedium),
                          CheckboxListTile(
                            title: const Text('With GST'),
                            value: _withGst,
                            onChanged: (v) =>
                                setState(() => _withGst = v ?? false),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          CheckboxListTile(
                            title: const Text('Without GST'),
                            value: _withoutGst,
                            onChanged: (v) =>
                                setState(() => _withoutGst = v ?? false),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ]),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: Text(widget.user == null ? 'Add User' : 'Update User'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
