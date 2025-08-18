import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/encryption_service.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/master_password_dialog.dart';
import '../../../l10n/app_localizations.dart';
import '../../../model/account_model.dart';
import '../../auth/cubit/auth_cubit/cubit.dart';

class AccountCard extends StatefulWidget {
  final Account account;
  final VoidCallback onTap;

  const AccountCard({
    super.key,
    required this.account,
    required this.onTap,
  });

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  bool _isPasswordVisible = false;
  Future<void> _handlePasswordVisibility() async {
    final encryptionService = EncryptionService();
    final authCubit = context.read<AuthCubit>();

    if (encryptionService.isInitialized) {
      setState(() {
        _isPasswordVisible = !_isPasswordVisible;
      });
      return;
    }

    final password = await showMasterPasswordDialog(context);
    if (password != null && password.isNotEmpty) {
      final success = await authCubit.verifyMasterPassword(password);
      if (success && mounted) {
        setState(() {
          _isPasswordVisible = true;
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(AppLocalizations.of(context)!.errorIncorrectPassword), backgroundColor: Colors.red),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    // --- Handler function for the copy action ---
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.2),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(15.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(
                context,
                icon: AppIcons.user,
                text: widget.account.username,
              ),
              const SizedBox(height: 12),
              _buildPasswordRow(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context,
      {required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).textTheme.bodySmall?.color),
        const SizedBox(width: 12),
        Expanded(
          child: CustomText(text,maxLines: 2,),
        ),
      ],
    );
  }

  Widget _buildPasswordRow(BuildContext context) {
    void handleCopyAction(String title, String value) async {
      final encryptionService = EncryptionService();
      String textToCopy = value;

      // If trying to copy the password and the vault is locked, prompt for master password
      if (title == "Password" && !encryptionService.isInitialized) {
        final password = await showMasterPasswordDialog(context);
        if (password == null || password.isEmpty) return; // User cancelled

        final success = await context.read<AuthCubit>().verifyMasterPassword(
            password);
        if (!success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Incorrect password"),
              backgroundColor: Colors.red));
          return; // Stop on failure
        }
      }

      // If the value is a password, make sure to decrypt it before copying
      if (title == "Password") {
        textToCopy = encryptionService.decryptText(widget.account.password);
      }

      Clipboard.setData(ClipboardData(text: textToCopy));
    }
    final encryptionService = EncryptionService();
    return Row(
      children: [
        Icon(AppIcons.lock,
            size: 20, color: Theme
                .of(context)
                .textTheme
                .bodySmall
                ?.color),
        const SizedBox(width: 12),
        Expanded(
          child: CustomText(
            maxLines: 2,
            _isPasswordVisible && encryptionService.isInitialized
                ? encryptionService.decryptText(widget.account.password)
                : '••••••••••',
            style: const TextStyle(
                fontFamily: 'monospace', letterSpacing: 1.5, fontSize: 16),
          ),
        ),
        IconButton(
          icon: Icon(
              _isPasswordVisible ? AppIcons.eyeSlash : AppIcons.eye
          ),
          onPressed: _handlePasswordVisibility,
          splashRadius: 20,
        ),
        IconButton(
          icon: const Icon(AppIcons.copy, size: 20),
          onPressed: () =>
              handleCopyAction("Password", widget.account.password),
        ),

      ],
    );
  }


}