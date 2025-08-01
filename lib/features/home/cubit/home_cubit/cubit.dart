import 'package:flutter_bloc/flutter_bloc.dart';

import 'states.dart';

class HomeScreenCubit extends Cubit<HomeScreenState> {
  HomeScreenCubit() : super(const HomeScreenState());

  void toggleSearch() {
    emit(state.copyWith(isSearching: !state.isSearching));
  }

  void stopSearching() {
    emit(state.copyWith(isSearching: false));
  }
}