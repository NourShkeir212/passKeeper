import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../model/account_model.dart';
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
            if (accountState is AccountLoading ||
                categoryState is CategoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (accountState is AccountLoaded &&
                categoryState is CategoryLoaded) {
              final accountsToDisplay = accountState.filteredAccounts ??
                  accountState.accounts;
              if (accountsToDisplay.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/svg/no_data.svg',
                          height: 150,
                        ),
                        const SizedBox(height: 24),
                        CustomText(
                          "Your Vault is Empty",
                          style: Theme
                              .of(context)
                              .textTheme
                              .headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        CustomText(
                          "Tap the '+' button to add your first secure account.",
                          textAlign: TextAlign.center,
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyMedium,
                        ),
                      ],
                    ),
                  ),
                );
              }

              final groupedAccounts = groupBy(
                  accountsToDisplay, (Account acc) => acc.categoryId);
              final categories = categoryState.categories;

              return ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final accountsInCategory = groupedAccounts[category.id] ?? [];
                  if (accountsInCategory.isEmpty)
                    return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Category Name
                            CustomText(
                              category.name,
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .primary,
                              ),
                            ),
                            // Account Count
                            CustomText(
                              '${accountsInCategory.length}',
                              // The quantity of accounts
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .primary
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...accountsInCategory.map((account) {
                        return Slidable(
                          key: ValueKey(account.id),
                          startActionPane: ActionPane(
                            motion: const StretchMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (_) =>
                                    _showAccountForm(context, account: account),
                                backgroundColor: Colors.blue,
                                icon: AppIcons.edit,
                                label: 'Edit',
                              ),
                            ],
                          ),
                          endActionPane: ActionPane(
                            motion: const StretchMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (_) =>
                                    _showDeleteConfirmation(
                                        context, account.id!),
                                backgroundColor: Colors.red,
                                icon: AppIcons.delete,
                                label: 'Delete',
                              ),
                            ],
                          ),
                          child: AccountCard(
                            account: account,
                            onTap: () => _showAccountDetails(context, account),
                          ),
                        );
                      })
                    ],
                  );
                },
              );
            }
            return const Center(child: Text("Something went wrong."));
          },
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String title,
      String value,
      {Widget? trailing}) {
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
                CustomText(title,
                    style: TextStyle(
                        fontSize: 12,
                        color:
                        Theme
                            .of(context)
                            .textTheme
                            .bodySmall
                            ?.color)),
                const SizedBox(height: 2),
                CustomText(value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          if (trailing != null) trailing,
          IconButton(
            icon: const Icon(AppIcons.copy, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                    SnackBar(content: Text('$title copied to clipboard')));
            },
          )
        ],
      ),
    );
  }

  void _showAccountForm(BuildContext context, {Account? account}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
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
    // This state variable is scoped to this function and the modal.
    bool isPasswordVisible = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          // This builder gives us a special `setModalState` function
          builder: (BuildContext context, StateSetter setModalState) {
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
                      decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomText(account.serviceName,
                      style: Theme
                          .of(context)
                          .textTheme
                          .headlineSmall),
                  const Divider(height: 32),
                  _buildDetailRow(
                      context, AppIcons.user, "Username",
                      account.username),
                  _buildDetailRow(context, AppIcons.password, "Password",
                      isPasswordVisible ? account.password : '••••••••••',
                      trailing: IconButton(
                        icon: Icon(
                            isPasswordVisible ? AppIcons.eyeSlash : AppIcons.eye
                        ),
                        // --- THE FIX IS HERE ---
                        onPressed: () {
                          setModalState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      )),
                  if (account.recoveryAccount != null &&
                      account.recoveryAccount!.isNotEmpty)
                    _buildDetailRow(context, AppIcons.email,
                        "Recovery Email", account.recoveryAccount!),
                  if (account.phoneNumbers != null &&
                      account.phoneNumbers!.isNotEmpty)
                    _buildDetailRow(context, AppIcons.phone,
                        "Phone Number", account.phoneNumbers!),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, int accountId) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const CustomText('Confirm Deletion'),
          content: const CustomText(
              'Are you sure you want to delete this account? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const CustomText('Cancel'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              child: CustomText('Delete', style: TextStyle(color: Theme
                  .of(context)
                  .colorScheme
                  .error)),
              onPressed: () {
                // 1. Tell the AccountCubit to delete the account
                // (This will also trigger the auto-delete logic for the category in the database)
                context.read<AccountCubit>().deleteAccount(accountId);

                // 2. THE FIX: Also tell the CategoryCubit to refresh its list
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