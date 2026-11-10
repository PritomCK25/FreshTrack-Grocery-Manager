
import 'package:flutter/material.dart';

import '../models/grocery.dart';
import '../services/grocery_service.dart';

class AddGroceryScreen extends StatefulWidget {
  const AddGroceryScreen({super.key});

  @override
  State<AddGroceryScreen> createState() => _AddGroceryScreenState();
}

class _AddGroceryScreenState extends State<AddGroceryScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _notesController = TextEditingController();

  final GroceryService _groceryService = GroceryService();

  final List<String> _categories = [
    'Vegetables',
    'Fruits',
    'Dairy',
    'Meat',
    'Fish',
    'Beverages',
    'Snacks',
    'Other',
  ];

  final List<String> _units = [
    'item',
    'kg',
    'g',
    'litre',
    'ml',
    'packet',
    'dozen',
  ];

  String _selectedCategory = 'Other';
  String _selectedUnit = 'item';

  DateTime _purchaseDate = DateTime.now();
  DateTime? _expiryDate;

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _selectPurchaseDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _purchaseDate = selectedDate;

        if (_expiryDate != null &&
            _expiryDate!.isBefore(_purchaseDate)) {
          _expiryDate = null;
        }
      });
    }
  }

  Future<void> _selectExpiryDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? _purchaseDate,
      firstDate: _purchaseDate,
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _expiryDate = selectedDate;
      });
    }
  }

  Future<void> _saveGrocery() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final grocery = Grocery(
        id: 0,
        name: _nameController.text.trim(),
        category: _selectedCategory,
        quantity: double.parse(_quantityController.text.trim()),
        unit: _selectedUnit,
        purchaseDate: _purchaseDate,
        expiryDate: _expiryDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      await _groceryService.addGrocery(grocery);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Grocery added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add grocery: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF167D48);

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF6),
      appBar: AppBar(
        title: const Text(
          'Add Grocery',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: Card(
              color: Colors.white,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Grocery Information',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Grocery name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Grocery Name',
                          hintText: 'Example: Milk',
                          prefixIcon: Icon(Icons.shopping_basket_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a grocery name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Category
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category_outlined),
                          border: OutlineInputBorder(),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Quantity and unit
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _quantityController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Quantity',
                                prefixIcon: Icon(Icons.numbers),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                final quantity =
                                    double.tryParse(value ?? '');

                                if (quantity == null || quantity <= 0) {
                                  return 'Enter a valid quantity';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedUnit,
                              decoration: const InputDecoration(
                                labelText: 'Unit',
                                border: OutlineInputBorder(),
                              ),
                              items: _units.map((unit) {
                                return DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedUnit = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Purchase date
                      OutlinedButton.icon(
                        onPressed: _selectPurchaseDate,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          'Purchase Date: ${_formatDate(_purchaseDate)}',
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Expiry date
                      OutlinedButton.icon(
                        onPressed: _selectExpiryDate,
                        icon: const Icon(Icons.event_busy_outlined),
                        label: Text(
                          _expiryDate == null
                              ? 'Select Expiry Date (Optional)'
                              : 'Expiry Date: ${_formatDate(_expiryDate!)}',
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                      if (_expiryDate != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _expiryDate = null;
                              });
                            },
                            child: const Text('Remove expiry date'),
                          ),
                        ),
                      const SizedBox(height: 12),

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional)',
                          hintText: 'Add any additional information...',
                          prefixIcon: Icon(Icons.notes),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Save button
                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _saveGrocery,
                          icon: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(
                            _isLoading ? 'Saving...' : 'Save Grocery',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
