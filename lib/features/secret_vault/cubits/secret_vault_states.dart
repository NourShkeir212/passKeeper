import 'package:equatable/equatable.dart';
import '../../../model/secret_item_model.dart';

abstract class SecretVaultState extends Equatable {
  const SecretVaultState();
  @override
  List<Object> get props => [];
}

class SecretVaultInitial extends SecretVaultState {}
class SecretVaultLoading extends SecretVaultState {}
class SecretVaultUnlocked extends SecretVaultState {}

class SecretVaultLocked extends SecretVaultState {
  final bool isSetup;
  const SecretVaultLocked({required this.isSetup});
  @override
  List<Object> get props => [isSetup];
}

class SecretVaultError extends SecretVaultState {
  final String error;
  const SecretVaultError(this.error);
  @override
  List<Object> get props => [error];
}

class SecretVaultLoaded extends SecretVaultState {
  final List<SecretItem> items;
  // The 'required' keyword was missing here
  const SecretVaultLoaded({required this.items});
  @override
  List<Object> get props => [items];
}