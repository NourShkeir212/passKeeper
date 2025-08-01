import 'package:equatable/equatable.dart';
import '../../../../model/account_model.dart';

abstract class AccountState extends Equatable {
  const AccountState();
  @override
  List<Object> get props => [];
}

class AccountInitial extends AccountState {}
class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  final List<Account> accounts;
  const AccountLoaded(this.accounts);
  @override
  List<Object> get props => [accounts];
}

class AccountFailure extends AccountState {
  final String error;
  const AccountFailure(this.error);
  @override
  List<Object> get props => [error];
}