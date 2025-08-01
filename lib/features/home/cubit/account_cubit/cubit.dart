import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/database_services.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../model/account_model.dart';
import 'states.dart';

class AccountCubit extends Cubit<AccountState> {
  final DatabaseService _databaseService;

  AccountCubit(this._databaseService) : super(AccountInitial());

  Future<void> loadAccounts() async {
    try {
      emit(AccountLoading());
      final userId = await SessionManager.getUserId();
      if (userId == null) {
        throw Exception("User not logged in.");
      }
      final accounts = await _databaseService.getAccounts(userId);
      emit(AccountLoaded(accounts));
    } catch (e) {
      emit(AccountFailure(e.toString()));
    }
  }

  Future<void> addAccount(Account newAccount) async {
    try {
      await _databaseService.insertAccount(newAccount);
      loadAccounts();
    } catch (e) {
      emit(AccountFailure(e.toString()));
    }
  }

  Future<void> updateAccount(Account account) async {
    try {
      await _databaseService.updateAccount(account);
      loadAccounts();
    } catch (e) {
      emit(AccountFailure(e.toString()));
    }
  }

  Future<void> deleteAccount(int accountId) async {
    try {
      await _databaseService.deleteAccount(accountId);
      loadAccounts();
    } catch (e) {
      emit(AccountFailure(e.toString()));
    }
  }
}