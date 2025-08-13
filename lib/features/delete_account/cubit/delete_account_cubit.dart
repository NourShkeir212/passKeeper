

// --- STATE ---
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeleteAccountState extends Equatable {
  final bool isPasswordVisible;
  const DeleteAccountState({this.isPasswordVisible = false});

  @override
  List<Object> get props => [isPasswordVisible];
}

// --- CUBIT ---
class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  DeleteAccountCubit() : super(const DeleteAccountState());

  void togglePasswordVisibility() {
    emit(DeleteAccountState(isPasswordVisible: !state.isPasswordVisible));
  }
}