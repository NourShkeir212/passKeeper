import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../core/services/encryption_service.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/empty_screen.dart';
import '../../../core/widgets/master_password_dialog.dart';
import '../../../l10n/app_localizations.dart';
import '../../../model/account_model.dart';
import '../../../model/category_model.dart';
import '../../auth/cubit/auth_cubit/cubit.dart';
import '../cubit/account_cubit/cubit.dart';
import '../cubit/account_cubit/states.dart';
import '../cubit/category_cubit/cubit.dart';
import '../cubit/category_cubit/states.dart';
import 'account_card.dart';
import 'account_form.dart';

class AccountList extends StatelessWidget {
  const AccountList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, accountState) {
        return BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, categoryState) {
            if (accountState is AccountLoading || categoryState is CategoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (accountState is AccountLoaded && categoryState is CategoryLoaded) {
              final accountsToDisplay = accountState.filteredAccounts ?? accountState.accounts;
              if (accountsToDisplay.isEmpty) {
                return BuildEmptyWidget(
                  title: AppLocalizations.of(context)!.homeScreenEmptyTitle,
                  subTitle: AppLocalizations.of(context)!.homeScreenEmptySubtitle
                );
              }

              final groupedAccounts = groupBy(accountsToDisplay, (Account acc) => acc.categoryId);
              final categories = categoryState.categories;

              // This outer list is now a standard, non-reorderable ListView.
              return ListView.builder(
                physics: BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final accountsInCategory = groupedAccounts[category.id] ?? [];

                  if (accountsInCategory.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  // This helper builds the full section, including the header.
                  return _buildCategorySection(
                    context: context,
                    category: category,
                    accounts: accountsInCategory,
                  );
                },
              );
            }
            return  Center(child: Text(AppLocalizations.of(context)!.errorGeneric));
          },
        );
      },
    );
  }


  Widget _buildCategorySection({
    required BuildContext context,
    required Category category,
    required List<Account> accounts,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // THE CATEGORY HEADER
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                category.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              CustomText(
                '${accounts.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  fontSize: 15,
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
        ),
        // This is the reorderable list for accounts WITHIN this category.
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: accounts.length,
          itemBuilder: (context, index) {
            final account = accounts[index];
            // Each item MUST have a key for the reordering to work.
            return Slidable(
              key: ValueKey(account.id),
              startActionPane: ActionPane(
                motion: const StretchMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) => _showAccountForm(context, account: account),
                    backgroundColor: Colors.blue,
                    icon: AppIcons.edit,
                    label: AppLocalizations.of(context)!.accountCardEdit,
                  ),
                ],
              ),
              endActionPane: ActionPane(
                motion: const StretchMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) => _showDeleteConfirmation(context, account.id!),
                    backgroundColor: Colors.red,
                    icon: AppIcons.delete,
                    label: AppLocalizations.of(context)!.accountCardDelete,
                  ),
                ],
              ),
              child: AccountCard(
                account: account,
                onTap: () => _showAccountDetails(context, account),
              ),
            );
          },
          onReorder: (oldIndex, newIndex) {
            // This call only affects the accounts within this specific category.
            context.read<AccountCubit>().reorderAccounts(oldIndex, newIndex, category.id!);
          },
        ),
      ],
    );
  }

  void _showAccountForm(BuildContext context, {Account? account}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      builder: (_) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<AccountCubit>()),
            BlocProvider.value(value: context.read<CategoryCubit>()),
          ],
          child: AccountForm(accountToEdit: account),
        );
      },
    );
  }

  void _showAccountDetails(BuildContext context, Account account) {
    bool isPasswordVisible = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            void handleDetailsPasswordVisibility() async {
              final encryptionService = EncryptionService();
              if (encryptionService.isInitialized) {
                setModalState(() => isPasswordVisible = !isPasswordVisible);
                return;
              }

              final password = await showMasterPasswordDialog(context);
              if (password != null && password.isNotEmpty) {
                final success =
                await context.read<AuthCubit>().verifyMasterPassword(password);
                if (success) {
                  setModalState(() => isPasswordVisible = true);
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(AppLocalizations.of(context)!.errorIncorrectPassword),
                        backgroundColor: Colors.red),
                  );
                }
              }
            }

            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                      child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 24),
                  CustomText(account.serviceName, style: Theme.of(context).textTheme.headlineSmall),
                  const Divider(height: 32),
                  _buildDetailRow(
                      context, AppIcons.user, AppLocalizations.of(context)!.accountDetailsUsernameOrEmail, account.username),
                  _buildDetailRow(
                    context,
                    AppIcons.lock,
                    AppLocalizations.of(context)!.accountDetailsPassword,
                    isPasswordVisible && EncryptionService().isInitialized
                        ? EncryptionService().decryptText(account.password)
                        : '••••••••••',
                    trailing: IconButton(
                      icon: Icon(isPasswordVisible
                          ? AppIcons.eyeSlash
                          : AppIcons.eye),
                      onPressed:
                      handleDetailsPasswordVisibility,
                    ),
                  ),
                  if (account.recoveryAccount != null &&
                      account.recoveryAccount!.isNotEmpty)
                    _buildDetailRow(context, AppIcons.email,  AppLocalizations.of(context)!.accountDetailsRecoveryEmail,
                        account.recoveryAccount!),
                  if (account.phoneNumbers != null &&
                      account.phoneNumbers!.isNotEmpty)
                    _buildDetailRow(context, AppIcons.phone,  AppLocalizations.of(context)!.accountDetailsPhone,
                        account.phoneNumbers!),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildDetailRow(
      BuildContext context, IconData icon, String title, String value,
      {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(title, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 2),
                CustomText(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500,),maxLines: 2,),
              ],
            ),
          ),
          if (trailing != null) trailing,
          IconButton(
            icon: const Icon(AppIcons.copy, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
            },
          )
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int accountId) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title:  CustomText(AppLocalizations.of(context)!.dialogConfirmDeleteTitle,style:TextStyle(color: Theme.of(context).colorScheme.error),),
          content:  CustomText(AppLocalizations.of(context)!.dialogConfirmDeleteAccount,maxLines: 5,),
          actions: <Widget>[
            TextButton(
              child:  CustomText(AppLocalizations.of(context)!.dialogCancel,),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              child: CustomText(AppLocalizations.of(context)!.dialogDelete, style: TextStyle(color: Theme.of(context).colorScheme.error),),
              onPressed: () {
                context.read<AccountCubit>().deleteAccount(accountId);
                context.read<CategoryCubit>().loadCategories();
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }
}