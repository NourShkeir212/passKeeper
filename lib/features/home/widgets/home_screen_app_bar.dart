import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../l10n/app_localizations.dart';
import '../../settings/settings_screen.dart';
import '../cubit/account_cubit/cubit.dart';
import '../cubit/category_cubit/cubit.dart';
import '../cubit/home_cubit/cubit.dart';
import '../cubit/home_cubit/states.dart';


class HomeScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;

  const HomeScreenAppBar({super.key, required this.searchController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeScreenCubit, HomeScreenState>(
      builder: (context, state) {
        if (state.isSearching) {
          return AppBar(
            leading: IconButton(
              icon: const Icon(AppIcons.back),
              onPressed: () {
                context.read<HomeScreenCubit>().stopSearching();
                searchController.clear();
                context.read<AccountCubit>().searchAccounts('');
              },
            ),
            title: TextField(
              controller: searchController,
              autofocus: true,
              decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.homeScreenSearchHint,
                  border: InputBorder.none),
              onChanged: (query) =>
                  context.read<AccountCubit>().searchAccounts(query),
            ),
            actions: [
              IconButton(icon: const Icon(AppIcons.close),
                  onPressed: () => searchController.clear()),
              // NEW: Settings Button
            ],
          );
        } else {
          return AppBar(
            elevation: 2,
            title: RichText(
              text: TextSpan(
                // Sets the default style for all text spans below
                style: Theme
                    .of(context)
                    .textTheme
                    .headlineMedium,
                children: <TextSpan>[
                  TextSpan(
                    text: 'Pass',
                    // Overrides the default style with the primary color
                    style: TextStyle(color: Theme
                        .of(context)
                        .colorScheme
                        .primary),
                  ),
                  const TextSpan(
                    text: 'Keeper',
                  ),
                ],
              ),
            ),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(icon: const Icon(AppIcons.search),
                  onPressed: () =>
                      context.read<HomeScreenCubit>().toggleSearch()),
              IconButton(
                icon: const Icon(AppIcons.settings),
                tooltip: AppLocalizations.of(context)!.settingsAccount,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) =>
                        MultiBlocProvider(
                          providers: [
                            // Provide the existing cubits to the settings page
                            BlocProvider.value(
                                value: context.read<AccountCubit>()),
                            BlocProvider.value(
                                value: context.read<CategoryCubit>()),
                          ],
                          child: const SettingsScreen(),
                        ),
                  ));
                },
              ),
            ],
          );
        }
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}