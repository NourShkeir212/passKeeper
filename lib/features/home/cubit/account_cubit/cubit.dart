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
      // First, find the account to get its category ID
      final accountToDelete = await _databaseService.getAccountById(accountId);
      if (accountToDelete == null) return; // Account already deleted

      final categoryId = accountToDelete.categoryId;

      // Delete the account
      await _databaseService.deleteAccount(accountId);

      // Check if any other accounts are left in that category
      final remainingAccounts = await _databaseService.countAccountsInCategory(categoryId);
      if (remainingAccounts == 0) {
        // If none are left, delete the category
        await _databaseService.deleteCategory(categoryId);
      }

      // Finally, reload the account list
      loadAccounts();
    } catch (e) {
      emit(AccountFailure(e.toString()));
    }
  }

  /// Filters the list of accounts based on a search query.
  void searchAccounts(String query) {
    // Only perform search if the state is AccountLoaded
    final currentState = state;
    if (currentState is AccountLoaded) {
      if (query.isEmpty) {
        // If query is empty, clear the filter
        emit(AccountLoaded(currentState.accounts, filteredAccounts: null));
        return;
      }

      // Filter the master list of accounts
      final filteredList = currentState.accounts.where((account) {
        final queryLower = query.toLowerCase();
        final serviceLower = account.serviceName.toLowerCase();
        final usernameLower = account.username.toLowerCase();

        return serviceLower.contains(queryLower) || usernameLower.contains(queryLower);
      }).toList();

      emit(AccountLoaded(currentState.accounts, filteredAccounts: filteredList));
    }
  }


  Future<void> reorderAccounts(int oldIndex, int newIndex, int categoryId) async {
    final currentState = state;
    if (currentState is AccountLoaded) {

      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      // Separate the accounts for the specific category
      final accountsInCat = currentState.accounts.where((a) => a.categoryId == categoryId).toList();
      final otherAccounts = currentState.accounts.where((a) => a.categoryId != categoryId).toList();

      // Reorder the list for the specific category
      final item = accountsInCat.removeAt(oldIndex);
      accountsInCat.insert(newIndex, item);

      // Update order index for the reordered items
      for (int i = 0; i < accountsInCat.length; i++) {
        accountsInCat[i] = accountsInCat[i].copyWith(accountOrder: i);
      }

      // Combine the lists back together
      final fullList = [...otherAccounts, ...accountsInCat];

      // Optimistically update the UI
      emit(AccountLoaded(fullList));

      // Persist the new order to the database
      await _databaseService.updateAccountOrder(accountsInCat);
    }
  }

  void filterByCategory(int? categoryId) {
    final currentState = state;
    if (currentState is AccountLoaded) {
      if (categoryId == null) {
        // If null, clear the filter
        emit(AccountLoaded(currentState.accounts, filteredAccounts: null));
      } else {
        final filteredList = currentState.accounts
            .where((account) => account.categoryId == categoryId)
            .toList();
        emit(AccountLoaded(currentState.accounts, filteredAccounts: filteredList));
      }
    }
  }
}