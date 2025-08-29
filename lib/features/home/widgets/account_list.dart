import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/services/encryption_service.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/custom_selectable_multiline_field.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/empty_screen.dart';
import '../../../core/widgets/master_password_dialog.dart';
import '../../../l10n/app_localizations.dart';
import '../../../model/account_model.dart';
import '../../../model/category_model.dart';
import '../../auth/cubit/auth_cubit/cubit.dart';
import '../../reorder_accounts/reorder_accounts_screen.dart';
import '../cubit/account_cubit/cubit.dart';
import '../cubit/account_cubit/states.dart';
import '../cubit/category_cubit/cubit.dart';
import '../cubit/category_cubit/states.dart';
import 'account_card.dart';
import 'account_form/account_form.dart';

class AccountList extends StatelessWidget {
  const AccountList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, accountState) {
        return BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, categoryState) {
            if (accountState is AccountLoading) { // Only show full spinner on initial load
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

              final groupedAccountsByCategory = groupBy(accountsToDisplay, (Account acc) => acc.categoryId);
              final categories = categoryState.categories;

              return ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final accountsInCategory = groupedAccountsByCategory[category.id] ?? [];
                  if (accountsInCategory.isEmpty) return const SizedBox.shrink();

                  final groupedByService = groupBy(accountsInCategory, (Account acc) => acc.serviceName);

                  return _buildCategorySection(
                    context: context,
                    category: category,
                    groupedAccounts: groupedByService,
                  );
                },
              );
            }
            return Center(child: Text(AppLocalizations.of(context)!.errorGeneric));
          },
        );
      },
    );
  }

  Widget _buildCategorySection({
    required BuildContext context,
    required Category category,
    required Map<String, List<Account>> groupedAccounts,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Header
        Builder(
          builder: (innerContext) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    category.name,
                    style: Theme.of(innerContext).textTheme.titleMedium?.copyWith(
                      color: Theme.of(innerContext).colorScheme.primary,
                    ),
                  ),
                  CustomText(
                    '${groupedAccounts.values.fold(0, (prev, list) => prev + list.length)}',
                    style: Theme.of(innerContext).textTheme.bodySmall?.copyWith(
                      color: Theme.of(innerContext).colorScheme.primary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }
        ),
        // This Column builds the list of ExpansionTiles
        Column(
          children: groupedAccounts.entries.map((entry) {
            final serviceName = entry.key;
            final accountsForService = entry.value;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Builder(
                builder: (innerContext) {
                  return ExpansionTile(
                    collapsedBackgroundColor: Theme.of(innerContext).cardColor,
                    backgroundColor: Theme.of(innerContext).colorScheme.background,
                    trailing: accountsForService.length > 1
                        ? IconButton(
                      icon: const Icon(Icons.sort),
                      tooltip: AppLocalizations.of(context)!.reorderToolTip,
                      onPressed: () async { // 1. Make the function async
                        // 2. Await the result of the navigation
                        await Navigator.push(context, MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<AccountCubit>(),
                            child: ReorderAccountsScreen(
                              categoryId: category.id!,
                              serviceName: serviceName,
                            ),
                          ),
                        ));
                        // 3. This code will only run AFTER the user returns from the ReorderAccountsScreen
                        //    Now, we silently refresh the list to show the new order.
                        context.read<AccountCubit>().loadAccounts(showLoading: false);
                      },
                    )
                        : null,
                    title: CustomText(serviceName, style: Theme.of(innerContext).textTheme.titleMedium),
                    subtitle: CustomText(AppLocalizations.of(innerContext)!.homeScreenAccountCount(accountsForService.length)),
                    children: accountsForService.map((account) {
                      return Slidable(
                        key: ValueKey(account.id),
                        startActionPane: ActionPane(
                          motion: const StretchMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) => _showAccountForm(innerContext, account: account),
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10,),
                                topLeft: Radius.circular(10,),
                              ),
                              icon: AppIcons.edit,
                              label: AppLocalizations.of(innerContext)!.accountCardEdit,
                            ),
                          ],
                        ),
                        endActionPane: ActionPane(
                          motion: const StretchMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) => _showDeleteConfirmation(innerContext, account.id!),
                              backgroundColor: Colors.red,
                              icon: AppIcons.delete,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10,),
                                bottomRight: Radius.circular(10,),
                              ),
                              label: AppLocalizations.of(innerContext)!.accountCardDelete,
                            ),
                          ],
                        ),
                        child: AccountCard(
                          account: account,
                          onTap: () => _showAccountDetails(innerContext, account),
                        ),
                      );
                    }).toList(),
                  );
                }
              ),
            );
          }).toList(),
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

            // --- Handler function for the copy action ---
            void handleCopyAction(String title, String value) async {
              final encryptionService = EncryptionService();
              String textToCopy = value;

              // If trying to copy the password and the vault is locked, prompt for master password
              if (title == "Password" && !encryptionService.isInitialized) {
                final password = await showMasterPasswordDialog(context);
                if (password == null || password.isEmpty) return; // User cancelled

                final success = await context.read<AuthCubit>().verifyMasterPassword(password);
                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Incorrect password"), backgroundColor: Colors.red));
                  return; // Stop on failure
                }
              }

              // If the value is a password, make sure to decrypt it before copying
              if (title == "Password") {
                textToCopy = encryptionService.decryptText(account.password);
              }

              Clipboard.setData(ClipboardData(text: textToCopy));
            }

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

            return SafeArea(
              child: Container(
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
                      onCopy: () => handleCopyAction("Password", account.password),
                      isPassword: true
                    ),
                    if (account.recoveryAccount != null &&
                        account.recoveryAccount!.isNotEmpty)
                      _buildDetailRow(context, AppIcons.email,  AppLocalizations.of(context)!.accountDetailsRecoveryEmail,
                          account.recoveryAccount!),
                    if (account.phoneNumbers != null &&
                        account.phoneNumbers!.isNotEmpty)
                      _buildDetailRow(context, AppIcons.phone,  AppLocalizations.of(context)!.accountDetailsPhone,
                          account.phoneNumbers!),

                    if (account.notes != null && account.notes!.isNotEmpty) ...[
                      const Divider(height: 32),
                      CustomSelectableMultiLineField(
                        labelText: "Notes", // TODO: Localize
                        text: account.notes!,
                        prefixIcon: Icons.notes,
                      ),
                      SizedBox(height: 10,),
                    ],
                    if (account.customFields.isNotEmpty) ...[
                      // Iterate through the map and build a row for each custom field
                      ...account.customFields.entries.map((entry) {
                        return _buildDetailRow(
                          context,
                          Iconsax.note_1, // A generic icon for custom fields
                          entry.key,      // The custom field's name
                          entry.value,    // The custom field's value
                          onCopy: () => handleCopyAction(entry.key, entry.value),
                        );
                      }),
                      const SizedBox(height: 20,)
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildDetailRow(
      BuildContext context,
      IconData icon,
      String title,
      String displayValue,
      {
        Widget? trailing,
        VoidCallback? onCopy,
        bool isPassword=false
      }
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme
              .of(context)
              .colorScheme
              .primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(title, style: Theme
                    .of(context)
                    .textTheme
                    .bodySmall),
                const SizedBox(height: 2),
                CustomText(
                  displayValue,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int accountId) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: CustomText(
            AppLocalizations.of(context)!.dialogConfirmDeleteTitle,
            style: TextStyle(
              color: Theme
                  .of(context)
                  .colorScheme
                  .error,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: CustomText(
            AppLocalizations.of(context)!.dialogConfirmDeleteAccount,
            maxLines: 5,),
          actions: <Widget>[
            TextButton(
              child: CustomText(AppLocalizations.of(context)!.dialogCancel,),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              child: CustomText(AppLocalizations.of(context)!.dialogDelete,
                style: TextStyle(color: Theme
                    .of(context)
                    .colorScheme
                    .error),),
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