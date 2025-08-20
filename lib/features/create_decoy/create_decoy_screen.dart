import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/encryption_service.dart';
import '../../core/theme/app_icons.dart';
import '../../core/widgets/custom_elevated_button.dart';
import '../../core/widgets/custom_text.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../l10n/app_localizations.dart';
import '../../model/user_model.dart';
import '../auth/cubit/auth_cubit/cubit.dart';
import '../auth/cubit/auth_cubit/states.dart';
import '../settings/cubit/cubit.dart';

class CreateDecoyScreen extends StatefulWidget {
  final User realUser;
  const CreateDecoyScreen({super.key, required this.realUser});

  @override
  State<CreateDecoyScreen> createState() => _CreateDecoyScreenState();
}

class _CreateDecoyScreenState extends State<CreateDecoyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _decoyUsernameController = TextEditingController();
  final _decoyPasswordController = TextEditingController();

  bool _isPasswordVisible = false;

  int _gmailCount = 2;
  int _facebookCount = 1;
  int _instagramCount = 1;
  int _shoppingCount = 1;
  int _servicesCount = 2;

  @override
  void dispose() {
    _decoyUsernameController.dispose();
    _decoyPasswordController.dispose();
    super.dispose();
  }
  void _showPasswordMatchDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.decoyPasswordMatchDialogTitle),
        content: Text(l10n.decoyPasswordMatchDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.dialogOk),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.mirrorAccountTitle),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomText(l10n.decoyCreateTitle, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                CustomText(l10n.decoyCreateSubtitle, textAlign: TextAlign.center, maxLines: 10),
                const Divider(height: 32),
      
                CustomTextField(
                  controller: _decoyUsernameController,
                  labelText: l10n.mirrorAccountDecoyUsernameHint,
                  prefixIcon: Icons.person_add_alt_1,
                  validator: (value) => value!.isEmpty ? l10n.validationEnterUsername : null,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: CustomText(
                    maxLines: 3,
                    l10n.decoyCreatePasswordHint,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                CustomTextField(
                  controller: _decoyPasswordController,
                  labelText: l10n.mirrorAccountDecoyPasswordHint,
                  prefixIcon: AppIcons.lock,
                  isPassword: !_isPasswordVisible,
                  validator: (value) => value!.isEmpty ? l10n.validationPasswordEmpty : null,
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? AppIcons.eyeSlash : AppIcons.eye),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 32),
      
                CustomText(l10n.decoyCreateGeneratedAccounts, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _buildCounterTile(title: l10n.decoyCreateGmail, count: _gmailCount, onChanged: (c) => setState(() => _gmailCount = c)),
                _buildCounterTile(title: l10n.decoyCreateFacebook, count: _facebookCount, onChanged: (c) => setState(() => _facebookCount = c)),
                _buildCounterTile(title: l10n.decoyCreateInstagram, count: _instagramCount, onChanged: (c) => setState(() => _instagramCount = c)),
                _buildCounterTile(title: l10n.decoyCreateShopping, count: _shoppingCount, onChanged: (c) => setState(() => _shoppingCount = c)),
                _buildCounterTile(title: l10n.decoyAccountServices, count: _servicesCount, onChanged: (c) => setState(() => _servicesCount = c)),
                const SizedBox(height: 32),
      
                BlocConsumer<AuthCubit, AuthState>(
                  listener: (context, state) {
                    if (state is AuthMirrorSuccess) {
                      context.read<SettingsCubit>().loadSettings();
                      Navigator.of(context).pop();
                    } else if (state is AuthFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error), backgroundColor: Colors.red));
                    }
                  },
                  builder: (context, state) {
                    return CustomElevatedButton(
                      onPressed: () {
                        // First, validate the text fields
                        if (_formKey.currentState!.validate()) {
                          final decoyPassword = _decoyPasswordController.text;
                          final hashedDecoyPassword = EncryptionService().hashPassword(decoyPassword);

                          // --- Validate the account counts ---
                          if (_gmailCount == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.validationGmailRequired),
                                backgroundColor: Theme.of(context).colorScheme.error,
                              ),
                            );
                            return; // Stop the process if validation fails
                          }
                          // If all checks pass, proceed to create the account
                          if (hashedDecoyPassword == widget.realUser.password) {
                            _showPasswordMatchDialog();
                          } else {
                            context.read<AuthCubit>().createMirrorAccount(
                                realUserId: widget.realUser.id!,
                                decoyUsername: _decoyUsernameController.text.trim(),
                                decoyPassword: decoyPassword,
                                customization: {
                                  'gmail': _gmailCount,
                                  'facebook': _facebookCount,
                                  'instagram': _instagramCount,
                                  'shopping': _shoppingCount,
                                  'services' :_servicesCount
                                });
                          }
                        }
                      },
                      text: l10n.decoyCreateButton,
                      isLoading: state is AuthLoading,
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCounterTile({required String title, required int count, required ValueChanged<int> onChanged}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: CustomText(title,maxLines: 2,overflow: TextOverflow.ellipsis,)),
            Row(
              children: [
                IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: count > 0 ? () => onChanged(count - 1) : null),
                CustomText(count.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => onChanged(count + 1)),
              ],
            )
          ],
        ),
      ),
    );
  }
}