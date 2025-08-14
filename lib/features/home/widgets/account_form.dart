import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/services/encryption_service.dart';
import '../../../core/services/session_manager.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/custom_elevated_button.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/master_password_dialog.dart';
import '../../../l10n/app_localizations.dart';
import '../../../model/account_model.dart';
import '../../../model/category_model.dart';
import '../../auth/cubit/auth_cubit/cubit.dart';
import '../cubit/account_cubit/cubit.dart';
import '../cubit/account_form/account_form_cubit.dart';
import '../cubit/account_form/account_form_state.dart';
import '../cubit/category_cubit/cubit.dart';
import '../cubit/category_cubit/states.dart';
import 'password_generator_dialog.dart';





class AccountForm extends StatelessWidget {
  final Account? accountToEdit;
  const AccountForm({super.key, this.accountToEdit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AccountFormCubit(),
      child: _AccountFormView(accountToEdit: accountToEdit),
    );
  }
}

class _AccountFormView extends StatefulWidget {
  final Account? accountToEdit;
  const _AccountFormView({this.accountToEdit});

  @override
  State<_AccountFormView> createState() => __AccountFormViewState();
}

class __AccountFormViewState extends State<_AccountFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _otherServiceController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _recoveryController;
  late final TextEditingController _phoneController;

  bool _isLoading = true;

  static const List<String> _services = [
    'Gmail', 'Outlook', 'Hotmail', 'Facebook',
    'Instagram', 'X', 'WhatsApp', 'Telegram', 'Other...'
  ];

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _otherServiceController = TextEditingController();
    _usernameController = TextEditingController();
    _recoveryController = TextEditingController();
    _phoneController = TextEditingController();

    _passwordController.addListener(() {
      context.read<AccountFormCubit>().updatePasswordStrength(
          _passwordController.text);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  Future<void> _initializeForm() async {
    final isEditMode = widget.accountToEdit != null;
    if (!isEditMode) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final encryptionService = EncryptionService();
    if (!encryptionService.isInitialized) {
      final password = await showMasterPasswordDialog(context);
      if (password == null || password.isEmpty) {
        if (mounted) Navigator.of(context).pop();
        return;
      }
      final success = await context.read<AuthCubit>().verifyMasterPassword(
          password);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.errorIncorrectPassword),
            backgroundColor: Colors.red));
        Navigator.of(context).pop();
        return;
      }
    }
    _populateFieldsForEdit();
  }

  void _populateFieldsForEdit() {
    final account = widget.accountToEdit!;
    context.read<AccountFormCubit>().selectCategory(account.categoryId);

    final service = _services.contains(account.serviceName) ? account
        .serviceName : 'Other...';
    context.read<AccountFormCubit>().selectService(service);

    _otherServiceController.text =
    !_services.contains(account.serviceName) ? account.serviceName : '';
    _usernameController.text = account.username;
    _passwordController.text =
        EncryptionService().decryptText(account.password);
    _recoveryController.text = account.recoveryAccount ?? '';
    _phoneController.text = account.phoneNumbers ?? '';

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _otherServiceController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _recoveryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onSave(int? selectedCategoryId, String? selectedService) async {
    if (!_formKey.currentState!.validate()) return;

    final encryptionService = EncryptionService();
    final authCubit = context.read<AuthCubit>();

    if (!encryptionService.isInitialized) {
      final password = await showMasterPasswordDialog(context);
      if (password == null || password.isEmpty) return;
      final success = await authCubit.verifyMasterPassword(password);
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
              AppLocalizations.of(context)!.errorIncorrectPassword),
              backgroundColor: Colors.red));
        }
        return;
      }
    }

    final userId = await SessionManager.getUserId();
    if (userId == null) return;

    final encryptedPassword = encryptionService.encryptText(
        _passwordController.text);
    final finalServiceName = selectedService == 'Other...'
        ? _otherServiceController.text
        : selectedService!;

    if (widget.accountToEdit != null) {
      final updatedAccount = widget.accountToEdit!.copyWith(
        categoryId: selectedCategoryId,
        serviceName: finalServiceName,
        username: _usernameController.text,
        password: encryptedPassword,
        recoveryAccount: _recoveryController.text,
        phoneNumbers: _phoneController.text,
      );
      context.read<AccountCubit>().updateAccount(updatedAccount);
    } else {
      final newAccount = Account(
        userId: userId,
        categoryId: selectedCategoryId!,
        serviceName: finalServiceName,
        username: _usernameController.text,
        password: encryptedPassword,
        recoveryAccount: _recoveryController.text,
        phoneNumbers: _phoneController.text,
      );
      context.read<AccountCubit>().addAccount(newAccount);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return BlocBuilder<AccountFormCubit, AccountFormState>(
      builder: (context, formState) {
        return BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, categoryState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                    top: 20,
                    left: 20,
                    right: 20,
                    bottom: MediaQuery
                        .of(context)
                        .viewInsets
                        .bottom + 20),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(10))),
                        const SizedBox(height: 20),
                        CustomText(
                            widget.accountToEdit != null
                                ? l10n.accountFormEditTitle
                                : l10n.accountFormAddTitle,
                            style: Theme
                                .of(context)
                                .textTheme
                                .headlineSmall),
                        const SizedBox(height: 20),
                        if (categoryState is CategoryLoaded)
                          DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                                fillColor: Theme.of(context).scaffoldBackgroundColor,
                                labelText: l10n.accountFormCategoryHint,
                                prefixIcon:  Icon(AppIcons.category,color: Theme.of(context).colorScheme.primary,)),
                            value: formState.selectedCategoryId,
                            items: [
                              DropdownMenuItem(
                                  value: -1,
                                  child: Text(l10n.accountFormCreateCategory)),
                              ...categoryState.categories.map((Category cat) =>
                                  DropdownMenuItem<int>(
                                      value: cat.id, child: Text(cat.name))),
                            ],
                            onChanged: (newValue) {
                              if (newValue == -1) {
                                _showCreateCategoryDialog();
                              } else {
                                context.read<AccountFormCubit>().selectCategory(
                                    newValue);
                              }
                            },
                            validator: (value) =>
                            value == null || value == -1
                                ? l10n.validationSelectCategory
                                : null,
                          ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            fillColor: Theme.of(context).scaffoldBackgroundColor,
                              labelText: l10n.accountFormServiceNameHint,
                              prefixIcon:  Icon(AppIcons.service,color:  Theme.of(context).colorScheme.primary,),
                          ),
                          value: formState.selectedService,
                          items: _services
                              .map((String service) =>
                              DropdownMenuItem<String>(
                                  value: service, child: CustomText(service)))
                              .toList(),
                          onChanged: (newValue) =>
                              context.read<AccountFormCubit>().selectService(
                                  newValue),
                          validator: (value) =>
                          value == null ? l10n.validationSelectService : null,
                        ),
                        if (formState.selectedService == 'Other...')
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: CustomTextField(
                                controller: _otherServiceController,
                                labelText: l10n.accountFormEnterServiceName,
                                prefixIcon: AppIcons.edit,
                                validator: (value) =>
                                value!.isEmpty
                                    ? l10n.validationEnterServiceName
                                    : null),
                          ),
                        const SizedBox(height: 10),
                        CustomTextField(
                            controller: _usernameController,
                            labelText: l10n.accountFormUsernameHint,
                            prefixIcon: AppIcons.user),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _passwordController,
                                labelText: l10n.accountDetailsPassword,
                                prefixIcon: AppIcons.lock,
                                isPassword: !formState.isPasswordVisible,
                                suffixIcon: IconButton(
                                  icon: Icon(formState.isPasswordVisible
                                      ? AppIcons.eyeSlash
                                      : AppIcons.eye),
                                  onPressed: () =>
                                      context
                                          .read<AccountFormCubit>()
                                          .togglePasswordVisibility(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Iconsax.magicpen),
                              tooltip: l10n.passwordGeneratorTooltip,
                              onPressed: () async {
                                final newPassword = await showDialog<String>(
                                  context: context,
                                  builder: (
                                      _) => const PasswordGeneratorDialog(),
                                );
                                if (newPassword != null &&
                                    newPassword.isNotEmpty) {
                                  _passwordController.text = newPassword;
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _PasswordStrengthIndicator(
                          strength: formState.passwordStrength,
                          strengthText: _getStrengthText(context,
                              formState.passwordStrength),
                        ),
                        SizedBox(height: _recoveryController.text == ""
                            ? 10
                            : 15),
                        CustomTextField(
                            controller: _recoveryController,
                            labelText: l10n.accountFormRecoveryHint,
                            prefixIcon: AppIcons.email),
                        const SizedBox(height: 10),
                        CustomTextField(
                            controller: _phoneController,
                            labelText: l10n.accountFormPhoneHint,
                            prefixIcon: AppIcons.phone),
                        const SizedBox(height: 20),
                        CustomElevatedButton(
                            onPressed: () =>
                                _onSave(
                                    formState.selectedCategoryId,
                                    formState.selectedService
                                ),
                            text: l10n.accountFormSaveButton
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  void _showCreateCategoryDialog() {
    final l10n = AppLocalizations.of(context)!;
    final categoryNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) =>
          AlertDialog(
            title: Text(l10n.manageCategoriesAddDialogTitle),
            content: CustomTextField(
                controller: categoryNameController,
                labelText: l10n.manageCategoriesNameHint,
                prefixIcon: AppIcons.createFolder),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(l10n.dialogCancel)),
              TextButton(
                onPressed: () {
                  if (categoryNameController.text.isNotEmpty) {
                    context
                        .read<CategoryCubit>()
                        .addCategory(categoryNameController.text);
                    Navigator.pop(dialogContext);
                  }
                },
                child: Text(l10n.dialogCreate),
              ),
            ],
          ),
    );
  }
}

// --- HELPER WIDGETS AND FUNCTIONS for Password Strength ---
class _PasswordStrengthIndicator extends StatelessWidget {
  final double strength;
  final String strengthText;

  const _PasswordStrengthIndicator(
      {required this.strength, required this.strengthText});

  Color _getStrengthColor(double strength) {
    if (strength < 0.5) return Colors.red;
    if (strength < 0.75) return Colors.orange;
    if (strength < 1.0) return Colors.lightGreen;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    if (strength == 0.0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: strength,
          backgroundColor: Colors.grey[300],
          color: _getStrengthColor(strength),
          minHeight: 6,
          borderRadius: BorderRadius.circular(5),
        ),
        const SizedBox(height: 4),
        CustomText(
          strengthText,
          style: TextStyle(color: _getStrengthColor(strength), fontSize: 12),
        ),
      ],
    );
  }
}

String _getStrengthText(BuildContext context, double strength) {
  // TODO: Localize these strings
  if (strength < 0.5) return AppLocalizations.of(context)!.passwordGeneratorWeak;
  if (strength < 0.75) return AppLocalizations.of(context)!.passwordGeneratorMedium;
  if (strength < 1.0) return AppLocalizations.of(context)!.passwordGeneratorStrong;
  return AppLocalizations.of(context)!.passwordGeneratorVeryStrong;
}