
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/grocery.dart';

class GroceryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // READ: Get all groceries belonging to the logged-in user.
  Future<List<Grocery>> getGroceries() async {
    final response = await _supabase
        .from('groceries')
        .select()
        .order('created_at', ascending: false);

    return response
        .map((item) => Grocery.fromMap(item))
        .toList();
  }

  // CREATE: Add a new grocery item.
  Future<void> addGrocery(Grocery grocery) async {
    await _supabase
        .from('groceries')
        .insert(grocery.toMap());
  }

  // UPDATE: Update an existing grocery item.
  Future<void> updateGrocery(Grocery grocery) async {
    await _supabase
        .from('groceries')
        .update(grocery.toMap())
        .eq('id', grocery.id);
  }

  // DELETE: Remove a grocery item.
  Future<void> deleteGrocery(int id) async {
    await _supabase
        .from('groceries')
        .delete()
        .eq('id', id);
  }
}
