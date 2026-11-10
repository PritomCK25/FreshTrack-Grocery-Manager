
import 'package:flutter/material.dart';

import '../models/grocery.dart';
import '../services/grocery_service.dart';

class EditGroceryScreen extends StatefulWidget {
  final Grocery grocery;

  const EditGroceryScreen({
    super.key,
    required this.grocery,
  });

  @override
  State<EditGroceryScreen> createState() => _EditGroceryScreenState();
}

class _EditGroceryScreenState extends State<EditGroceryScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _notesController;

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
    'pack',
    'dozen',
  ];

  late String _selectedCategory;
  late String _selectedUnit;
  late DateTime _purchaseDate;
  DateTime? _expiryDate;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    final grocery = widget.grocery;

    _nameController = TextEditingController(text: grocery.name);
    _quantityController =
        TextEditingController(text: grocery.quantity.toString());
    _notesController =
        TextEditingController(text: grocery.notes ?? '');

    _selectedCategory = grocery.category;
    _selectedUnit = grocery.unit;
    _purchaseDate = grocery.purchaseDate;
    _expiryDate = grocery.expiryDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
            _expiryDate!.isBefore(selectedDate)) {
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

  Future<void> _updateGrocery() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedGrocery = Grocery(
        id: widget.grocery.id,
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

      await _groceryService.updateGrocery(updatedGrocery);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Grocery updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update grocery: $error'),
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
          'Edit Grocery',
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
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Update Grocery Information',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Grocery Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.shopping_basket_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a grocery name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category_outlined),
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

                      TextFormField(
                        controller: _quantityController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.numbers),
                        ),
                        validator: (value) {
                          final quantity =
                              double.tryParse(value ?? '');

                          if (quantity == null || quantity <= 0) {
                            return 'Enter a valid quantity greater than 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      DropdownButtonFormField<String>(
                        initialValue: _selectedUnit,
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.scale_outlined),
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
                      const SizedBox(height: 20),

                      OutlinedButton.icon(
                        onPressed: _selectPurchaseDate,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          'Purchase Date: ${_formatDate(_purchaseDate)}',
                        ),
                      ),
                      const SizedBox(height: 12),

                      OutlinedButton.icon(
                        onPressed: _selectExpiryDate,
                        icon: const Icon(Icons.event),
                        label: Text(
                          _expiryDate == null
                              ? 'Select Expiry Date (Optional)'
                              : 'Expiry Date: ${_formatDate(_expiryDate!)}',
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

                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.notes),
                        ),
                      ),
                      const SizedBox(height: 28),

                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed:
                              _isLoading ? null : _updateGrocery,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(
                            _isLoading ? 'Updating...' : 'Update Grocery',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
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
