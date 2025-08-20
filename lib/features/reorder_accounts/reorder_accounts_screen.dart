import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_accounts/l10n/app_localizations.dart';
import '../../core/theme/app_icons.dart';
import '../../core/widgets/custom_text.dart';
import '../../model/account_model.dart';
import '../home/cubit/account_cubit/cubit.dart';
import '../home/cubit/account_cubit/states.dart';

class ReorderAccountsScreen extends StatefulWidget {
  final int categoryId;
  final String serviceName;

  const ReorderAccountsScreen({
    super.key,
    required this.categoryId,
    required this.serviceName,
  });

  @override
  State<ReorderAccountsScreen> createState() => _ReorderAccountsScreenState();
}

class _ReorderAccountsScreenState extends State<ReorderAccountsScreen> {
  // This list will hold the accounts for this screen only
  late List<Account> _accountsForService;

  @override
  void initState() {
    super.initState();
    // Initialize the local list from the Cubit's state
    final accountState = context.read<AccountCubit>().state;
    if (accountState is AccountLoaded) {
      _accountsForService = accountState.accounts
          .where((a) => a.categoryId == widget.categoryId && a.serviceName == widget.serviceName)
          .toList();
    } else {
      _accountsForService = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${AppLocalizations.of(context)!.reorderScreenTitle} ${widget.serviceName}"),
      ),
      body: ReorderableListView.builder(
        itemCount: _accountsForService.length,
        itemBuilder: (context, index) {
          final account = _accountsForService[index];
          return Animate(
            key: ValueKey(account.id), // Key must be on the outer widget
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
                          CustomText(account.username,
                              style: Theme.of(context).textTheme.titleMedium,maxLines: 2,),
                          CustomText(account.serviceName,
                              style: Theme.of(context).textTheme.bodySmall),
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
          // --- THE FIX IS HERE ---
          // 1. Update the local UI state IMMEDIATELY
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            final item = _accountsForService.removeAt(oldIndex);
            _accountsForService.insert(newIndex, item);
          });

          // 2. In the background, tell the Cubit to save the new order
          context.read<AccountCubit>().persistAccountReorder(_accountsForService);
        },
      ),
    );
  }
}
