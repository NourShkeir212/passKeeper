import 'package:equatable/equatable.dart';
import '../../../../model/category_model.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object> get props => [];
}

class CategoryInitial extends CategoryState {}
class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;
  const CategoryLoaded(this.categories);
  @override
  List<Object> get props => [categories];
}

class CategoryFailure extends CategoryState {
  final String error;
  const CategoryFailure(this.error);
  @override
  List<Object> get props => [error];
}