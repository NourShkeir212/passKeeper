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
                  //   Group accounts inside the category by service name ---
                  final groupedByService = groupBy(accountsInCategory, (Account acc) => acc.serviceName);

                  if (accountsInCategory.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  // This helper builds the full section, including the header.
                  return _buildCategorySection(
                    context: context,
                    category: category,
                    groupedAccounts: groupedByService,
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
        // List of services within this category
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: groupedAccounts.keys.length,
          itemBuilder: (context, index) {
            final serviceName = groupedAccounts.keys.elementAt(index);
            final accountsForService = groupedAccounts[serviceName]!;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              clipBehavior: Clip.antiAlias,
              child: Builder(
                builder: (innerContext) {
                  return ExpansionTile(
                    collapsedBackgroundColor: Theme.of(innerContext).colorScheme.background,
                    backgroundColor: Theme.of(innerContext).colorScheme.background,
                    leading: const Icon(AppIcons.service),
                    title: CustomText(serviceName, style: Theme.of(context).textTheme.titleMedium),
                    subtitle: CustomText(AppLocalizations.of(context)!.homeScreenAccountCount(accountsForService.length)),
                    children: [
                      // This is the reorderable list for accounts within this service group
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: accountsForService.length,
                        itemBuilder: (context, itemIndex) {
                          final account = accountsForService[itemIndex];
                          return Slidable(
                            key: ValueKey(account.id),
                            startActionPane: ActionPane(
                              motion: const StretchMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (_) => _showAccountForm(context, account: account),
                                  backgroundColor: Colors.blue,
                                  icon: AppIcons.edit,
                                  label: "Edit",
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
                                  label: "Delete",
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
                          context.read<AccountCubit>().reorderAccounts(oldIndex, newIndex, category.id!);
                        },
                      )
                    ],
                  );
                }
              ),
            );
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
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(title, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 2),
                CustomText(displayValue, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500,),maxLines: 2,),
              ],
            ),
          ),
          if (trailing != null) trailing,
          Visibility(
            visible: isPassword,
            child: IconButton(
              icon: const Icon(AppIcons.copy, size: 20),
              onPressed:onCopy,
            ),
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