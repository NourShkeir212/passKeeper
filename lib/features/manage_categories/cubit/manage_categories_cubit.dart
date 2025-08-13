import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- STATE ---


class ManageCategoriesState extends Equatable {
  final bool isSelectionMode;
  final Set<int> selectedCategoryIds;

  const ManageCategoriesState({
    this.isSelectionMode = false,
    this.selectedCategoryIds = const {},
  });

  ManageCategoriesState copyWith({
    bool? isSelectionMode,
    Set<int>? selectedCategoryIds,
  }) {
    return ManageCategoriesState(
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
    );
  }

  @override
  List<Object> get props => [isSelectionMode, selectedCategoryIds];
}

// --- CUBIT ---
class ManageCategoriesCubit extends Cubit<ManageCategoriesState> {
  ManageCategoriesCubit() : super(const ManageCategoriesState());

  void toggleSelectionMode() {
    if (state.isSelectionMode) {
      // If turning off, clear selection
      emit(state.copyWith(isSelectionMode: false, selectedCategoryIds: {}));
    } else {
      emit(state.copyWith(isSelectionMode: true));
    }
  }

  void selectCategory(int categoryId) {
    if (!state.isSelectionMode) return;

    final currentSelection = Set<int>.from(state.selectedCategoryIds);
    if (currentSelection.contains(categoryId)) {
      currentSelection.remove(categoryId);
    } else {
      currentSelection.add(categoryId);
    }
    emit(state.copyWith(selectedCategoryIds: currentSelection));
  }

  void selectAllCategories(List<int> allCategoryIds) {
    emit(state.copyWith(selectedCategoryIds: allCategoryIds.toSet()));
  }
}