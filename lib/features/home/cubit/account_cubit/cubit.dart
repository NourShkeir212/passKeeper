import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/database_services.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../model/account_model.dart';
import 'states.dart';

class AccountCubit extends Cubit<AccountState> {
  final DatabaseService _databaseService;

  AccountCubit(this._databaseService) : super(AccountInitial());


  Future<void> reorderAccountsInService(
      int oldIndex, int newIndex, int categoryId, String serviceName) async {
    final currentState = state;
    if (currentState is AccountLoaded) {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      // 1. Create a mutable copy of the full list of accounts.
      final fullList = List<Account>.from(currentState.accounts);

      // 2. Isolate the specific group being reordered.
      final serviceGroupToReorder = fullList
          .where((a) => a.categoryId == categoryId && a.serviceName == serviceName)
          .toList();

      // 3. Perform the reorder on the small list.
      final item = serviceGroupToReorder.removeAt(oldIndex);
      serviceGroupToReorder.insert(newIndex, item);

      // 4. Update the order index for the items in this reordered group.
      for (int i = 0; i < serviceGroupToReorder.length; i++) {
        serviceGroupToReorder[i] = serviceGroupToReorder[i].copyWith(accountOrder: i);
      }

      // 5. Remove the old, unsorted items from the main list.
      fullList.removeWhere((a) => a.categoryId == categoryId && a.serviceName == serviceName);

      // 6. Add the newly reordered items back into the main list.
      fullList.addAll(serviceGroupToReorder);

      // 7. Re-apply the filter if one is active.
      List<Account>? newFilteredList;
      if (currentState.activeCategoryId != null) {
        newFilteredList = fullList
            .where((acc) => acc.categoryId == currentState.activeCategoryId)
            .toList();
      }

      // 8. Emit this new, stable list IMMEDIATELY.
      // This optimistic update matches the UI's animation, preventing the flicker.
      emit(AccountLoaded(
        fullList,
        filteredAccounts: newFilteredList,
        activeCategoryId: currentState.activeCategoryId,
      ));

      // 9. In the background, save the changes to the database.
      try {
        await _databaseService.updateAccountOrder(serviceGroupToReorder);
      } catch (e) {
        // If saving fails, reload from the DB to revert the change.
        loadAccounts();
      }
    }
  }

  Future<void> loadAccounts({bool showLoading = true}) async {
    try {
      if (showLoading) {
        emit(AccountLoading());
      }
      final userId = SessionManager.currentVaultUserId;
      if (userId == null) {
        emit(const AccountLoaded([]));
        return;
      }
      final profileTag = SessionManager.currentSessionProfileTag;
      final accounts = await _databaseService.getAccounts(userId, profileTag);
      emit(AccountLoaded(accounts));
    } catch (e) {
      emit(AccountFailure(e.toString()));
    }
  }

  void filterByCategory(int? categoryId) {
    final currentState = state;
    if (currentState is AccountLoaded) {
      List<Account>? filteredList;
      if (categoryId != null) {
        filteredList = currentState.accounts
            .where((account) => account.categoryId == categoryId)
            .toList();
      }
      emit(AccountLoaded(
        currentState.accounts,
        filteredAccounts: filteredList,
        activeCategoryId: categoryId,
      ));
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
}