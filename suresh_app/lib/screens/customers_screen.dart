import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/customer.dart';
import '../providers/customer_provider.dart';
import '../widgets/loading_indicator.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({Key? key}) : super(key: key);

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _gstNumberController = TextEditingController();
  final _stateCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _billingAddressController = TextEditingController();
  final _shippingAddressController = TextEditingController();
  final _openingBalanceController = TextEditingController();
  final _addressController = TextEditingController();

  Future<void> _refreshCustomers() async {
    try {
      // CustomerProvider.fetchCustomers() will get companyId from StorageService internally
      await Provider.of<CustomerProvider>(context, listen: false).fetchCustomers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing customers: $e')),
        );
      }
    }
  }
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshCustomers();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _gstNumberController.dispose();
    _stateCodeController.dispose();
    _billingAddressController.dispose();
    _shippingAddressController.dispose();
    _openingBalanceController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _nameController.clear();
    _gstNumberController.clear();
    _stateCodeController.clear();
    _phoneController.clear();
    _emailController.clear();
    _billingAddressController.clear();
    _shippingAddressController.clear();
    _openingBalanceController.text = '0.00';
    _addressController.clear();
  }

  void _showAddEditBottomSheet(BuildContext context, [Customer? customer]) {
    if (customer != null) {
      _nameController.text = customer.customerName;
      _gstNumberController.text = customer.gstNumber ?? '';
      _stateCodeController.text = customer.stateCode ?? '';
      _phoneController.text = customer.contactNumber ?? '';
      _emailController.text = customer.emailAddress ?? '';
      _billingAddressController.text = customer.billingAddress ?? '';
      _shippingAddressController.text = customer.shippingAddress ?? '';
      _openingBalanceController.text = customer.openingBalance?.toStringAsFixed(2) ?? '0.00';
      _addressController.text = customer.address ?? '';
    } else {
      _resetForm();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _CustomerFormSheet(
          formKey: _formKey,
          nameController: _nameController,
          gstNumberController: _gstNumberController,
          stateCodeController: _stateCodeController,
          phoneController: _phoneController,
          emailController: _emailController,
          billingAddressController: _billingAddressController,
          shippingAddressController: _shippingAddressController,
          openingBalanceController: _openingBalanceController,
          addressController: _addressController,
          customer: customer,
          initialOpeningDate: customer?.openingDate,
          initialIsActive: customer?.isActive ?? true,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Consumer<CustomerProvider>(
        builder: (ctx, customerProvider, child) {
          if (customerProvider.isLoading) {
            return const LoadingIndicator();
          }

          if (customerProvider.errorMessage != null && customerProvider.errorMessage!.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${customerProvider.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshCustomers,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (customerProvider.customers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No customers found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddEditBottomSheet(context),
                    child: const Text('Add Customer'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshCustomers,
            child: ListView.builder(
              itemCount: customerProvider.customers.length,
              itemBuilder: (ctx, index) {
                final customer = customerProvider.customers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: ListTile(
                    title: Text(customer.customerName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (customer.contactNumber != null && customer.contactNumber!.isNotEmpty)
                          Text('Phone: ${customer.contactNumber}'),
                        if (customer.emailAddress != null && customer.emailAddress!.isNotEmpty)
                          Text('Email: ${customer.emailAddress}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showAddEditBottomSheet(context, customer),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Customer'),
                                content: const Text('Are you sure you want to delete this customer?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Provider.of<CustomerProvider>(context, listen: false)
                                          .deleteCustomer(customer.id.toString());
                                      Navigator.of(ctx).pop();
                                    },
                                    child: const Text('Delete'),
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

class _CustomerFormSheet extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController gstNumberController;
  final TextEditingController stateCodeController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController billingAddressController;
  final TextEditingController shippingAddressController;
  final TextEditingController openingBalanceController;
  final TextEditingController addressController;
  final Customer? customer;
  final DateTime? initialOpeningDate;
  final bool initialIsActive;

  const _CustomerFormSheet({
    required this.formKey,
    required this.nameController,
    required this.gstNumberController,
    required this.stateCodeController,
    required this.phoneController,
    required this.emailController,
    required this.billingAddressController,
    required this.shippingAddressController,
    required this.openingBalanceController,
    required this.addressController,
    required this.customer,
    required this.initialOpeningDate,
    required this.initialIsActive,
  });

  @override
  State<_CustomerFormSheet> createState() => _CustomerFormSheetState();
}

class _CustomerFormSheetState extends State<_CustomerFormSheet> {
  DateTime? _openingDate;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _openingDate = widget.initialOpeningDate;
    _isActive = widget.initialIsActive;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black12)],
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
              key: widget.formKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.customer == null ? 'Add Customer' : 'Edit Customer',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        runSpacing: 16,
                        spacing: 16,
                        children: [
                          SizedBox(
                            width: isWide ? (constraints.maxWidth / 2) - 24 : double.infinity,
                            child: TextFormField(
                              controller: widget.nameController,
                              decoration: const InputDecoration(
                                labelText: 'Customer Name',
                                hintText: 'Enter customer name',
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter customer name' : null,
                            ),
                          ),
                          SizedBox(
                            width: isWide ? (constraints.maxWidth / 2) - 24 : double.infinity,
                            child: TextFormField(
                              controller: widget.gstNumberController,
                              decoration: const InputDecoration(
                                labelText: 'GST Number',
                                hintText: '22AAAAA0000A1Z5',
                              ),
                            ),
                          ),
                          SizedBox(
                            width: isWide ? (constraints.maxWidth / 2) - 24 : double.infinity,
                            child: TextFormField(
                              controller: widget.stateCodeController,
                              decoration: const InputDecoration(
                                labelText: 'State Code',
                                hintText: 'Enter state code (e.g., 24)',
                                helperText: 'Required. Common codes: GJ-24, MH-27, DL-07, KA-29, TN-33. Leave empty for outside India.',
                              ),
                            ),
                          ),
                          SizedBox(
                            width: isWide ? (constraints.maxWidth / 2) - 24 : double.infinity,
                            child: TextFormField(
                              controller: widget.phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Contact Number',
                                hintText: '10-digit mobile number',
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          SizedBox(
                            width: isWide ? (constraints.maxWidth / 2) - 24 : double.infinity,
                            child: TextFormField(
                              controller: widget.emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                                hintText: 'customer@example.com',
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          SizedBox(
                            width: isWide ? (constraints.maxWidth / 2) - 24 : double.infinity,
                            child: TextFormField(
                              controller: widget.addressController,
                              decoration: const InputDecoration(
                                labelText: 'Address',
                                hintText: 'Enter address',
                              ),
                              maxLines: 2,
                            ),
                          ),
                          SizedBox(
                            width: isWide ? (constraints.maxWidth / 2) - 24 : double.infinity,
                            child: TextFormField(
                              controller: widget.billingAddressController,
                              decoration: const InputDecoration(
                                labelText: 'Billing Address',
                                hintText: 'Enter billing address',
                              ),
                              maxLines: 2,
                            ),
                          ),
                          SizedBox(
                            width: isWide ? (constraints.maxWidth / 2) - 24 : double.infinity,
                            child: TextFormField(
                              controller: widget.shippingAddressController,
                              decoration: const InputDecoration(
                                labelText: 'Shipping Address',
                                hintText: 'Enter shipping address',
                              ),
                              maxLines: 2,
                            ),
                          ),
                          SizedBox(
                            width: isWide ? (constraints.maxWidth / 2) - 24 : double.infinity,
                            child: TextFormField(
                              controller: widget.openingBalanceController,
                              decoration: const InputDecoration(
                                labelText: 'Opening Balance',
                                hintText: '0.00',
                              ),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                          SizedBox(
                            width: isWide ? (constraints.maxWidth / 2) - 24 : double.infinity,
                            child: InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _openingDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null && mounted) {
                                  setState(() {
                                    _openingDate = picked;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Opening Date',
                                  hintText: 'dd-mm-yyyy',
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _openingDate != null
                                            ? '${_openingDate!.day.toString().padLeft(2, '0')}-${_openingDate!.month.toString().padLeft(2, '0')}-${_openingDate!.year}'
                                            : 'dd-mm-yyyy',
                                        style: TextStyle(
                                          color: _openingDate != null ? Colors.black87 : Colors.grey,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.calendar_today, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: isWide ? (constraints.maxWidth / 2) - 24 : double.infinity,
                            child: Row(
                              children: [
                                Switch(
                                  value: _isActive,
                                  onChanged: (val) {
                                    setState(() {
                                      _isActive = val;
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                const Text('Active'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          onPressed: () {
                            if (widget.formKey.currentState!.validate()) {
                              final customerData = Customer(
                                id: widget.customer?.id,
                                customerName: widget.nameController.text,
                                gstNumber: widget.gstNumberController.text.isEmpty ? null : widget.gstNumberController.text,
                                stateCode: widget.stateCodeController.text.isEmpty ? null : widget.stateCodeController.text,
                                contactNumber: widget.phoneController.text.isEmpty ? null : widget.phoneController.text,
                                emailAddress: widget.emailController.text.isEmpty ? null : widget.emailController.text,
                                billingAddress: widget.billingAddressController.text.isEmpty ? null : widget.billingAddressController.text,
                                shippingAddress: widget.shippingAddressController.text.isEmpty ? null : widget.shippingAddressController.text,
                                address: widget.addressController.text.isEmpty ? null : widget.addressController.text,
                                openingBalance: double.tryParse(widget.openingBalanceController.text) ?? 0.0,
                                openingDate: _openingDate,
                                isActive: _isActive,
                              );
                              if (widget.customer == null) {
                                Provider.of<CustomerProvider>(context, listen: false)
                                    .addCustomer(customerData);
                              } else {
                                Provider.of<CustomerProvider>(context, listen: false)
                                    .updateCustomer(widget.customer!.id!, customerData);
                              }
                              Navigator.of(context).pop();
                            }
                          },
                          child: Text(widget.customer == null ? 'Add Customer' : 'Update Customer'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}