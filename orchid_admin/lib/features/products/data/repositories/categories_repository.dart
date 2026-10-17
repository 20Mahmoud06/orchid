import '../../../../core/supabase/supabase.dart';
import '../../domain/models/category_model.dart';

class CategoriesRepository {
  Future<List<Category>> getAllCategories() async {
    final rows =
        await supabase.from('categories').select('id, name, created_at').order('name');
    return rows.map(Category.fromRow).toList();
  }

  Future<Category> createCategory(String name) async {
    final row =
        await supabase.from('categories').insert({'name': name}).select().single();
    return Category.fromRow(row);
  }

  Future<void> updateCategory(String id, String name) async {
    await supabase.from('categories').update({'name': name}).eq('id', id);
  }

  Future<void> deleteCategory(String id) async {
    await supabase.from('categories').delete().eq('id', id);
  }
}
