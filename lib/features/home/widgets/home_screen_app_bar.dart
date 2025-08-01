import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/custom_text.dart';
import '../../auth/cubit/auth_cubit/cubit.dart';
import '../cubit/account_cubit/cubit.dart';
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
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.read<HomeScreenCubit>().stopSearching();
                searchController.clear();
                context.read<AccountCubit>().searchAccounts('');
              },
            ),
            title: TextField(
              controller: searchController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Search...', border: InputBorder.none),
              onChanged: (query) => context.read<AccountCubit>().searchAccounts(query),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.close), onPressed: () => searchController.clear()),
            ],
          );
        } else {
          return AppBar(
            title: const CustomText('My Accounts'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(icon: const Icon(Icons.search), onPressed: () => context.read<HomeScreenCubit>().toggleSearch()),
              IconButton(icon: const Icon(Icons.logout), tooltip: 'Logout', onPressed: () => context.read<AuthCubit>().logout()),
            ],
          );
        }
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}