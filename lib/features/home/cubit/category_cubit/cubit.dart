import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/database_services.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../model/category_model.dart';
import 'states.dart';


class CategoryCubit extends Cubit<CategoryState> {
  final DatabaseService _databaseService;

  CategoryCubit(this._databaseService) : super(CategoryInitial());

  Future<void> loadCategories() async {
    try {
      emit(CategoryLoading());
      final userId = await SessionManager.getUserId();
      if (userId == null) throw Exception("User not logged in.");
      final categories = await _databaseService.getCategories(userId);
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryFailure(e.toString()));
    }
  }

  Future<void> addCategory(String name) async {
    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) throw Exception("User not logged in.");
      final newCategory = Category(userId: userId, name: name);
      await _databaseService.insertCategory(newCategory);
      loadCategories();
    } catch (e) {
      emit(CategoryFailure(e.toString()));
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _databaseService.updateCategory(category);
      loadCategories(); // Reload to show changes
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    try {
      await _databaseService.deleteCategory(categoryId);
      loadCategories(); // Reload to show changes
    } catch (e) {
      // Handle error
    }
  }

  Future<void> reorderCategories(int oldIndex, int newIndex) async {
    final currentState = state;
    if (currentState is CategoryLoaded) {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final categories = List<Category>.from(currentState.categories);
      final item = categories.removeAt(oldIndex);
      categories.insert(newIndex, item);

      // Update order index for all items
      for (int i = 0; i < categories.length; i++) {
        categories[i] = categories[i].copyWith(categoryOrder: i);
      }

      // Optimistically update the UI
      emit(CategoryLoaded(categories));

      // Persist the new order to the database
      await _databaseService.updateCategoryOrder(categories);
    }
  }
}