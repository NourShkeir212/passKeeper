import 'package:equatable/equatable.dart';

import '../../../../model/account_model.dart';

abstract class AccountState extends Equatable {
  const AccountState();
  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {}
class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  final List<Account> accounts;
  final List<Account>? filteredAccounts;

  const AccountLoaded(this.accounts, {this.filteredAccounts});

  @override
  List<Object?> get props => [accounts, filteredAccounts];
}

class AccountFailure extends AccountState {
  final String error;
  const AccountFailure(this.error);
  @override
  List<Object> get props => [error];
}