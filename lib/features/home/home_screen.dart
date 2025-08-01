import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/database_services.dart';
import '../../core/services/navigation_service.dart';
import '../auth/cubit/auth_cubit/cubit.dart';
import '../auth/cubit/auth_cubit/states.dart';
import '../auth/screens/sign_in/sign_in_screen.dart';
import 'cubit/account_cubit/cubit.dart';
import 'cubit/category_cubit/cubit.dart';
import 'cubit/home_cubit/cubit.dart';
import 'cubit/home_cubit/states.dart';
import 'widgets/account_form.dart';
import 'widgets/account_list.dart';
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

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOut) {
          NavigationService.pushAndRemoveUntil(const SignInScreen());
        }
      },
      child: BlocBuilder<HomeScreenCubit, HomeScreenState>(
        builder: (context, homeState) {
          return SafeArea(
            child: Scaffold(
              appBar: HomeScreenAppBar(searchController: searchController),
              body: const AccountList(),
              floatingActionButton: homeState.isSearching
                  ? null
                  : FloatingActionButton(
                onPressed: () {
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
                        child: const AccountForm(),
                      );
                    },
                  );
                },
                child: const Icon(Icons.add),
              ),
            ),
          );
        },
      ),
    );
  }
}