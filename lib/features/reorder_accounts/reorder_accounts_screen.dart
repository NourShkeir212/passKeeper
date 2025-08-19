import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_accounts/l10n/app_localizations.dart';

import '../../core/theme/app_icons.dart';
import '../../core/widgets/custom_text.dart';
import '../home/cubit/account_cubit/cubit.dart';
import '../home/cubit/account_cubit/states.dart';

class ReorderAccountsScreen extends StatelessWidget {
  final int categoryId;
  final String serviceName;

  const ReorderAccountsScreen({
    super.key,
    required this.categoryId,
    required this.serviceName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${AppLocalizations.of(context)!.reorderScreenTitle} $serviceName"),
      ),
      body: BlocBuilder<AccountCubit, AccountState>(
        builder: (context, state) {
          if (state is AccountLoaded) {
            final accountsForService = state.accounts
                .where((a) => a.categoryId == categoryId && a.serviceName == serviceName)
                .toList();

            return ReorderableListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: accountsForService.length,
              itemBuilder: (context, index) {
                final account = accountsForService[index];

                // --- THE UI UPDATE IS HERE ---
                return Animate(
                  key: ValueKey(account.id),
                  effects: [FadeEffect(delay: (50 * index).ms)],
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Icon(AppIcons.key),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(account.username, style: Theme.of(context).textTheme.titleMedium),
                                CustomText(account.serviceName, style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Icon(Icons.drag_handle),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              onReorder: (oldIndex, newIndex) {
                context.read<AccountCubit>().reorderAccountsInService(
                    oldIndex, newIndex, categoryId, serviceName);
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}