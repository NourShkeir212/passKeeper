import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/database_services.dart';
import '../../core/services/navigation_service.dart';
import '../../core/theme/app_icons.dart';
import '../../l10n/app_localizations.dart';
import '../auth/cubit/auth_cubit/cubit.dart';
import '../auth/cubit/auth_cubit/states.dart';
import '../auth/screens/sign_in/sign_in_screen.dart';
import 'cubit/account_cubit/cubit.dart';
import 'cubit/account_cubit/states.dart';
import 'cubit/category_cubit/cubit.dart';
import 'cubit/category_cubit/states.dart';
import 'cubit/home_cubit/cubit.dart';
import 'cubit/home_cubit/states.dart';
import 'widgets/account_form.dart';
import 'widgets/account_list.dart';
import 'widgets/category_filter_chips.dart';
import 'widgets/home_screen_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeScreenCubit()),
        BlocProvider(create: (_) => AccountCubit(DatabaseService())..loadAccounts()),
        BlocProvider(create: (_) => CategoryCubit(DatabaseService())..loadCategories()),
      ],
      child: const HomeScreenView(),
    );
  }
}

class HomeScreenView extends StatelessWidget {
  const HomeScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();
    final chipsKey = GlobalKey<CategoryFilterChipsState>();
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOut) {
          NavigationService.pushAndRemoveUntil(const SignInScreen());
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) return;
          final l10n = AppLocalizations.of(context)!;
          showDialog<bool>( // Specify the return type
            context: context,
            builder: (dialogContext) =>
                AlertDialog(
                  title: Text(l10n.dialogConfirmExitTitle),
                  content: Text(l10n.dialogConfirmExitContent),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      // Return false
                      child: Text(l10n.dialogCancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      // Return true
                      child: Text(
                        l10n.dialogExitButton,
                        style: TextStyle(color: Theme
                            .of(context)
                            .colorScheme
                            .error),
                      ),
                    ),
                  ],
                ),
          ).then((exitConfirmed) {
            // Check the result from the dialog
            if (exitConfirmed ?? false) {
              SystemNavigator.pop();
            }
          });
        },
        child: BlocBuilder<CategoryCubit, CategoryState>(
            builder: (context, categoryState) {
              return BlocBuilder<HomeScreenCubit, HomeScreenState>(
                builder: (context, homeState) {
                  final isSearching = homeState.isSearching;
                  return BlocBuilder<AccountCubit, AccountState>(
                      builder: (context, accountState) {
                        int numberOfNonEmptyCategories = 0;
                        if (categoryState is CategoryLoaded &&
                            accountState is AccountLoaded) {
                          // Calculate how many categories actually have accounts in them
                          numberOfNonEmptyCategories =
                              categoryState.categories.where((category) {
                                return accountState.accounts.any((account) =>
                                account.categoryId == category.id);
                              }).length;
                        }

                        return Scaffold(
                          appBar: HomeScreenAppBar(
                            searchController: searchController,
                            isSearching: isSearching,),
                          body: GestureDetector(
                            onHorizontalDragEnd: (details) {
                              final accountState = context
                                  .read<AccountCubit>()
                                  .state;
                              final categoryState = context
                                  .read<CategoryCubit>()
                                  .state;

                              if (categoryState is CategoryLoaded &&
                                  accountState is AccountLoaded) {
                                // --- filtered list of categories with accounts ---
                                final categories = categoryState.categories
                                    .where((category) {
                                  return accountState.accounts.any((account) =>
                                  account.categoryId == category.id);
                                }).toList();

                                final currentSelection = chipsKey.currentState
                                    ?.selectedCategoryId;
                                int currentIndex = 0;
                                if (currentSelection != null) {
                                  currentIndex = categories.indexWhere((c) =>
                                  c.id == currentSelection) + 1;
                                }

                                if (details.primaryVelocity! < 0 &&
                                    currentIndex < categories.length) {
                                  chipsKey.currentState?.selectCategoryByIndex(
                                      currentIndex + 1, categories);
                                } else if (details.primaryVelocity! > 0 &&
                                    currentIndex > 0) {
                                  chipsKey.currentState?.selectCategoryByIndex(
                                      currentIndex - 1, categories);
                                }
                              }
                            },
                            child: Column(
                              children: [
                                if (!isSearching &&
                                    numberOfNonEmptyCategories > 1)...[
                                  const SizedBox(height: 20,),
                                  CategoryFilterChips(key: chipsKey),
                                ],
                                Expanded(child: const AccountList()),
                              ],
                            ),
                          ),
                          floatingActionButton: homeState.isSearching
                              ? null
                              : FloatingActionButton(
                            onPressed: () async {
                              // 1. Capture the result from the bottom sheet
                              final bool? wasSaved = await showModalBottomSheet<
                                  bool>(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(25.0))),
                                builder: (_) {
                                  return MultiBlocProvider(
                                    providers: [
                                      BlocProvider.value(
                                          value: context.read<AccountCubit>()),
                                      BlocProvider.value(
                                          value: context.read<CategoryCubit>()),
                                      BlocProvider.value(
                                          value: context.read<AuthCubit>()),
                                    ],
                                    child: const AccountForm(),
                                  );
                                },
                              );

                              // 2. Only reload the data if the form was successfully saved
                              if (wasSaved == true && context.mounted) {
                                await Future.wait([
                                  context.read<AccountCubit>().loadAccounts(showLoading: false),
                                  context.read<CategoryCubit>().loadCategories(),
                                ]);
                              }
                            },
                            child: const Icon(AppIcons.add),
                          ),
                        );
                      }
                  );
                },
              );
            }
        ),
      ),
    );
  }
}