
import 'package:flutter/material.dart';

import '../models/grocery.dart';
import '../services/auth_service.dart';
import '../services/grocery_service.dart';
import 'add_grocery_screen.dart';
import 'login_screen.dart';
import 'edit_grocery_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GroceryService _groceryService = GroceryService();

  late Future<List<Grocery>> _groceriesFuture;

  final TextEditingController _searchController =
    TextEditingController();

  String _selectedFilter = 'All';
  

  final List<String> _categories = [
    'All',
    'Vegetables',
    'Fruits',
    'Dairy',
    'Meat',
    'Fish',
    'Beverages',
    'Snacks',
    'Other',
  ];

  
DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

bool _isExpired(Grocery grocery) {
  if (grocery.expiryDate == null) {
    return false;
  }

  return _dateOnly(grocery.expiryDate!)
      .isBefore(_dateOnly(DateTime.now()));
}

bool _isExpiringSoon(Grocery grocery) {
  if (grocery.expiryDate == null || _isExpired(grocery)) {
    return false;
  }

  final today = _dateOnly(DateTime.now());
  final expiry = _dateOnly(grocery.expiryDate!);

  final difference = expiry.difference(today).inDays;

  return difference <= 3;
}



Widget _buildStatCard(
  String title,
  int count,
  IconData icon,
  Color color,
) {
  return Expanded(
    child: Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 8,
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}







  @override
  void initState() {
    super.initState();
    _loadGroceries();
  }

  void _loadGroceries() {
    _groceriesFuture = _groceryService.getGroceries();
  }

  Future<void> _refreshGroceries() async {
    setState(() {
      _loadGroceries();
    });

    await _groceriesFuture;
  }

  Future<void> _addGrocery() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddGroceryScreen(),
      ),
    );

    if (result == true) {
      setState(() {
        _loadGroceries();
      });
    }
  }
  Future<void> _editGrocery(Grocery grocery) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditGroceryScreen(
        grocery: grocery,
      ),
    ),
  );

  if (result == true) {
    setState(() {
      _loadGroceries();
    });
  }
}
Future<void> _deleteGrocery(Grocery grocery) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Grocery'),
      content: Text(
        'Are you sure you want to delete ${grocery.name}?',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: const Text(
            'Delete',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  try {
    await _groceryService.deleteGrocery(grocery.id);

    if (!mounted) return;

    setState(() {
      _loadGroceries();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Grocery deleted successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to delete grocery: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  Future<void> _logout() async {
    await AuthService().logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  
Widget _buildGroceryCard(Grocery grocery) {
  const primaryGreen = Color(0xFF167D48);

  final bool expired = _isExpired(grocery);
  final bool expiringSoon = _isExpiringSoon(grocery);

  Color statusColor;
  Color cardColor;
  String statusLabel;

  if (expired) {
    statusColor = Colors.red;
    cardColor = const Color(0xFFFFF1F0);
    statusLabel = 'EXPIRED';
  } else if (expiringSoon) {
    statusColor = Colors.deepOrange;
    cardColor = const Color(0xFFFFF5E9);
    statusLabel = 'EXPIRING SOON';
  } else if (grocery.expiryDate == null) {
    statusColor = Colors.blueGrey;
    cardColor = const Color(0xFFF2F4F5);
    statusLabel = 'NO EXPIRY DATE';
  } else {
    statusColor = primaryGreen;
    cardColor = const Color(0xFFF0F8F2);
    statusLabel = 'FRESH';
  }

  return Card(
    color: cardColor,
    elevation: 1,
    margin: const EdgeInsets.only(bottom: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(
          Icons.shopping_basket_outlined,
          color: statusColor,
        ),
      ),
      title: Text(
        grocery.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${grocery.category}'),
            const SizedBox(height: 4),
            Text('Quantity: ${grocery.quantity} ${grocery.unit}'),
            const SizedBox(height: 4),
            Text(
              grocery.expiryDate == null
                  ? 'Expiry: Not specified'
                  : 'Expiry: ${_formatDate(grocery.expiryDate!)}',
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: Colors.blue,
            ),
            tooltip: 'Edit Grocery',
            onPressed: () => _editGrocery(grocery),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
            ),
            tooltip: 'Delete Grocery',
            onPressed: () => _deleteGrocery(grocery),
          ),
        ],
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF167D48);

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF6),
      appBar: AppBar(
        title: const Text(
          'FreshTrack',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _refreshGroceries,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to FreshTrack! 🥬',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Manage your groceries and keep them fresh.',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 28),

              // Add Grocery Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _addGrocery,
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Add Grocery',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
  'My Groceries',
  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Color(0xFF26352B),
  ),
),
              const SizedBox(height: 16),

              // Display groceries from Supabase
              FutureBuilder<List<Grocery>>(
                future: _groceriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: CircularProgressIndicator(
                          color: primaryGreen,
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 45,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 10),
                          const Text('Failed to load groceries.'),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _loadGroceries();
                              });
                            },
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  }

                  final groceries = snapshot.data ?? [];

                  if (groceries.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: Column(
                          children: [
                            Icon(
                              Icons.shopping_basket_outlined,
                              size: 55,
                              color: Colors.black38,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No groceries added yet.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Tap the button above to add your first grocery.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  
final expiredCount =
    groceries.where((grocery) => _isExpired(grocery)).length;

final expiringCount =
    groceries.where((grocery) => _isExpiringSoon(grocery)).length;

return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Dashboard statistics
    Row(
      children: [
        _buildStatCard(
          'Total Items',
          groceries.length,
          Icons.shopping_basket,
          const Color(0xFF167D48),
        ),
        _buildStatCard(
          'Expired',
          expiredCount,
          Icons.warning_amber_rounded,
          Colors.red,
        ),
        _buildStatCard(
          'Expiring Soon',
          expiringCount,
          Icons.access_time,
          Colors.orange,
        ),
      ],
    ),

    const SizedBox(height: 24),

// Search groceries
TextField(
  controller: _searchController,
  decoration: InputDecoration(
    hintText: 'Search groceries...',
    prefixIcon: const Icon(Icons.search),
    suffixIcon: IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () {
        _searchController.clear();
        setState(() {});
      },
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  onChanged: (value) {
    setState(() {});
  },
),

const SizedBox(height: 16),

// Category filter
DropdownButtonFormField<String>(
  initialValue: _selectedFilter,
  decoration: InputDecoration(
    labelText: 'Filter by Category',
    prefixIcon: const Icon(Icons.category),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
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
        _selectedFilter = value;
      });
    }
  },
),

const SizedBox(height: 20),

const Text(
  'Grocery List',
  style: TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w600,
    color: Color(0xFF26352B),
  ),
),

    const SizedBox(height: 12),

    // Filtered grocery cards
..._filterGroceries(groceries).map((grocery) {
  return _buildGroceryCard(grocery);
}),
  ],
);

                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  List<Grocery> _filterGroceries(List<Grocery> groceries) {
    
  return groceries.where((grocery) {
    final matchesSearch = grocery.name
        .toLowerCase()
        .contains(_searchController.text.toLowerCase());

    final matchesCategory = _selectedFilter == 'All' ||
        grocery.category == _selectedFilter;

    return matchesSearch && matchesCategory;
  }).toList();
}
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

}
