import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/invoice_provider.dart';
import '../model/invoice.dart';
import '../model/customer.dart';
import '../model/company_profile.dart';
import '../model/product.dart';

class InvoiceFormSheet extends StatefulWidget {
  final Invoice? invoice;

  const InvoiceFormSheet({Key? key, this.invoice}) : super(key: key);

  @override
  State<InvoiceFormSheet> createState() => _InvoiceFormSheetState();
}

class _InvoiceFormSheetState extends State<InvoiceFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _deliveryController = TextEditingController();
  final _transportController = TextEditingController();
  final _lrController = TextEditingController();

  int? _selectedCustomerId;
  int? _selectedCompanyId;
  List<Map<String, dynamic>> _items = [];

  double _sgstAmount = 0;
  double _cgstAmount = 0;
  double _igstAmount = 0;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    if (widget.invoice != null) {
      _loadInvoiceData();
    } else {
      _addNewItem();
    }
  }

  void _loadInvoiceData() {
    final inv = widget.invoice!;
    _dateController.text = inv.billDate;
    _deliveryController.text = inv.deliveryAt ?? '';
    _transportController.text = inv.transport ?? '';
    _lrController.text = inv.lrNumber ?? '';
    _selectedCustomerId = inv.customerId;
    _selectedCompanyId = inv.companyProfileId;
    _sgstAmount = inv.sgstAmount;
    _cgstAmount = inv.cgstAmount;
    _igstAmount = inv.igstAmount;

    if (inv.invoiceItems != null) {
      _items = inv.invoiceItems!.map((item) => {
        'productId': item.productId,
        'hsnCode': item.hsnCode,
        'uom': item.uom,
        'quantity': item.quantity,
        'rate': item.rate,
      }).toList();
    }
  }

  void _addNewItem() {
    setState(() {
      _items.add({
        'productId': null,
        'hsnCode': '',
        'uom': 'PCS',
        'quantity': 1,
        'rate': 0.0,
      });
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  double _calculateTotal() {
    double total = 0;
    for (var item in _items) {
      final qty = item['quantity'] ?? 1;
      final rate = (item['rate'] ?? 0).toDouble();
      total += qty * rate;
    }
    return total;
  }

  double _calculateGrandTotal() {
    return _calculateTotal() + _sgstAmount + _cgstAmount + _igstAmount;
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(date);
      });
    }
  }

  Future<void> _saveInvoice() async {
    if (!_formKey.currentState!.validate()) return;

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one item')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final invoiceData = {
      'customerId': _selectedCustomerId,
      'companyProfileId': _selectedCompanyId,
      'billDate': _dateController.text,
      'deliveryAt': _deliveryController.text.isEmpty ? null : _deliveryController.text,
      'transport': _transportController.text.isEmpty ? null : _transportController.text,
      'lrNumber': _lrController.text.isEmpty ? null : _lrController.text,
      'totalAssesValue': _calculateTotal(),
      'sgstAmount': _sgstAmount,
      'cgstAmount': _cgstAmount,
      'igstAmount': _igstAmount,
      'items': _items,
    };

    final provider = context.read<InvoiceProvider>();
    bool success;

    if (widget.invoice != null) {
      success = await provider.updateInvoice(widget.invoice!.id!, invoiceData);
    } else {
      success = await provider.createInvoice(context, invoiceData);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.invoice != null 
              ? 'Invoice updated successfully' 
              : 'Invoice created successfully'),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to save invoice'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Container(
      height: size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.invoice != null ? 'Edit Invoice' : 'New Invoice',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Customer & Company Selection
                    Row(
                      children: [
                        Expanded(
                          child: _buildCustomerDropdown(),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildCompanyDropdown(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Date and Delivery Info
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _dateController,
                            decoration: const InputDecoration(
                              labelText: 'Bill Date',
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(),
                            ),
                            readOnly: true,
                            onTap: _selectDate,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Date is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _deliveryController,
                            decoration: const InputDecoration(
                              labelText: 'Delivery At',
                              prefixIcon: Icon(Icons.location_on),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Transport & LR Number
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _transportController,
                            decoration: const InputDecoration(
                              labelText: 'Transport',
                              prefixIcon: Icon(Icons.local_shipping),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _lrController,
                            decoration: const InputDecoration(
                              labelText: 'LR Number',
                              prefixIcon: Icon(Icons.confirmation_number),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Items Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Invoice Items',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addNewItem,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Item'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Items List
                    ..._items.asMap().entries.map((entry) {
                      return _buildItemRow(entry.key, entry.value, isTablet);
                    }).toList(),

                    const SizedBox(height: 24),

                    // Tax Section
                    _buildTaxSection(),

                    const SizedBox(height: 24),

                    // Summary
                    _buildSummary(),

                    const SizedBox(height: 24),

                    // Save Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveInvoice,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              widget.invoice != null ? 'Update Invoice' : 'Create Invoice',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDropdown() {
    // In real implementation, fetch from provider/controller
    return DropdownButtonFormField<int>(
      value: _selectedCustomerId,
      decoration: const InputDecoration(
        labelText: 'Customer',
        prefixIcon: Icon(Icons.person),
        border: OutlineInputBorder(),
      ),
      items: const [], // Populate with actual customers
      onChanged: (value) {
        setState(() => _selectedCustomerId = value);
      },
      validator: (value) => value == null ? 'Customer is required' : null,
    );
  }

  Widget _buildCompanyDropdown() {
    // In real implementation, fetch from provider/controller
    return DropdownButtonFormField<int>(
      value: _selectedCompanyId,
      decoration: const InputDecoration(
        labelText: 'Company',
        prefixIcon: Icon(Icons.business),
        border: OutlineInputBorder(),
      ),
      items: const [], // Populate with actual companies
      onChanged: (value) {
        setState(() => _selectedCompanyId = value);
      },
      validator: (value) => value == null ? 'Company is required' : null,
    );
  }

  Widget _buildItemRow(int index, Map<String, dynamic> item, bool isTablet) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Item ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeItem(index),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Product Dropdown (simplified)
            DropdownButtonFormField<int>(
              value: item['productId'],
              decoration: const InputDecoration(
                labelText: 'Product',
                border: OutlineInputBorder(),
              ),
              items: const [], // Populate with products
              onChanged: (value) {
                setState(() => item['productId'] = value);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item['hsnCode']?.toString() ?? '',
                    decoration: const InputDecoration(
                      labelText: 'HSN Code',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => item['hsnCode'] = value,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: item['uom'] ?? 'PCS',
                    decoration: const InputDecoration(
                      labelText: 'UOM',
                      border: OutlineInputBorder(),
                    ),
                    items: ['PCS', 'KG', 'MTR', 'LTR', 'BOX']
                        .map((uom) => DropdownMenuItem(value: uom, child: Text(uom)))
                        .toList(),
                    onChanged: (value) {
                      setState(() => item['uom'] = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item['quantity']?.toString() ?? '1',
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      setState(() => item['quantity'] = int.tryParse(value) ?? 1);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: item['rate']?.toString() ?? '0',
                    decoration: const InputDecoration(
                      labelText: 'Rate',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      setState(() => item['rate'] = double.tryParse(value) ?? 0);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Amount', style: TextStyle(fontSize: 12)),
                        Text(
                          '₹ ${((item['quantity'] ?? 1) * (item['rate'] ?? 0)).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tax Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _sgstAmount.toString(),
                    decoration: const InputDecoration(
                      labelText: 'SGST',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      setState(() => _sgstAmount = double.tryParse(value) ?? 0);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: _cgstAmount.toString(),
                    decoration: const InputDecoration(
                      labelText: 'CGST',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      setState(() => _cgstAmount = double.tryParse(value) ?? 0);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: _igstAmount.toString(),
                    decoration: const InputDecoration(
                      labelText: 'IGST',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      setState(() => _igstAmount = double.tryParse(value) ?? 0);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final subtotal = _calculateTotal();
    final grandTotal = _calculateGrandTotal();

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryRow('Subtotal:', subtotal),
            _buildSummaryRow('SGST:', _sgstAmount),
            _buildSummaryRow('CGST:', _cgstAmount),
            _buildSummaryRow('IGST:', _igstAmount),
            const Divider(height: 24),
            _buildSummaryRow('Grand Total:', grandTotal, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '₹ ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.blue : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _deliveryController.dispose();
    _transportController.dispose();
    _lrController.dispose();
    super.dispose();
  }
}