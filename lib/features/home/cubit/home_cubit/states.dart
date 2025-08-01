import 'package:equatable/equatable.dart';

class HomeScreenState extends Equatable {
  final bool isSearching;

  const HomeScreenState({this.isSearching = false});

  HomeScreenState copyWith({bool? isSearching}) {
    return HomeScreenState(isSearching: isSearching ?? this.isSearching);
  }

  @override
  List<Object> get props => [isSearching];
}