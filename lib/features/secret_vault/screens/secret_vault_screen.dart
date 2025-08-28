import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../l10n/app_localizations.dart';
import '../../../model/secret_item_model.dart';
import '../cubits/secret_vault_cubit.dart';
import '../cubits/secret_vault_states.dart';
import '../widgets/add_secret_item_dialog.dart';
import '../widgets/secret_item_card.dart';
import 'secret_vault_pin_screen.dart';

class SecretVaultScreen extends StatelessWidget {
  const SecretVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.secretVaultTitle),
        actions: [
          // --- NEW: Settings Menu ---
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'update_pin') {
                // Navigate to PIN screen in "setup" mode to create a new PIN
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<SecretVaultCubit>(),
                    child: const SecretVaultPinScreen(isSetup: true),
                  ),
                ));
              } else if (value == 'delete_vault') {
                _showDeleteVaultConfirmation(context);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'update_pin',
                child: Text('Update PIN'), // TODO: Localize
              ),
              const PopupMenuItem<String>(
                value: 'delete_vault',
                child: Text('Delete Vault', style: TextStyle(color: Colors.red)), // TODO: Localize
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<SecretVaultCubit, SecretVaultState>(
        builder: (context, state) {
          if (state is SecretVaultLoaded) {
            if (state.items.isEmpty) {
              return _buildEmptyState(context);
            }
            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return SecretItemCard(
                  item: item,
                  onEdit: () => _showAddEditDialog(context, itemToEdit: item),
                  onDelete: () => _showDeleteConfirmation(context, item.id!),
                );
              },
            );
          }
          // This should only be visible for a moment
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(AppIcons.add),
      ),
    );
  }
  void _showDeleteConfirmation(BuildContext context, int itemId) async {
    final l10n = AppLocalizations.of(context)!;
    final bool? didConfirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dialogConfirmDeleteTitle,style: TextStyle(color: Colors.red),),
        content:  Text(l10n.secretVaultConfirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.dialogDelete, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );

    // If the user confirmed, delete the item
    if (didConfirm == true && context.mounted) {
      context.read<SecretVaultCubit>().deleteSecretItem(itemId);
    }
  }


  void _showAddEditDialog(BuildContext context, {SecretItem? itemToEdit}) async {
    final bool? wasSaved = await showDialog<bool>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<SecretVaultCubit>(),
        child: AddSecretItemDialog(itemToEdit: itemToEdit),
      ),
    );

    // If the dialog returned true, reload the items
    if (wasSaved == true && context.mounted) {
      context.read<SecretVaultCubit>().loadSecretItems();
    }
  }

  void _showDeleteVaultConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dialogDeleteVaultTitle,style: TextStyle(color: Colors.red),),
        content: Text(l10n.dialogDeleteVaultContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<SecretVaultCubit>().deleteVault();
            },
            child: Text(
              l10n.dialogDelete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final svgPath = isDarkMode ? 'assets/svg/no_data_dark_mode.svg' : 'assets/svg/no_data_light_mode.svg';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(svgPath, height: 150),
            const SizedBox(height: 24),
            CustomText(
            l10n.secretVaultEmptyTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            CustomText(
              l10n.secretVaultEmptySubtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}