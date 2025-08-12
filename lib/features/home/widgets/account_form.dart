import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../cubit/category_cubit/cubit.dart';
import '../cubit/category_cubit/states.dart';


class AccountForm extends StatefulWidget {
  final Account? accountToEdit;
  const AccountForm({super.key, this.accountToEdit});

  @override
  State<AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<AccountForm> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedCategoryId;
  String? _selectedService;
  bool _isPasswordVisible = false;

  final _otherServiceController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _recoveryController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = true;
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';

  static const List<String> _services = [
    'Gmail', 'Outlook', 'Hotmail', 'Facebook',
    'Instagram', 'X', 'WhatsApp', 'Telegram', 'Other...'
  ];

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  void _updatePasswordStrength() {
    if (!mounted) return;
    setState(() {
      _passwordStrength = _checkPasswordStrength(_passwordController.text);
      _passwordStrengthText = _getStrengthText(context, _passwordStrength);
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
      final success = await context.read<AuthCubit>().verifyMasterPassword(password);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.errorIncorrectPassword), backgroundColor: Colors.red));
        Navigator.of(context).pop();
        return;
      }
    }
    _populateFieldsForEdit();
  }

  void _populateFieldsForEdit() {
    final account = widget.accountToEdit!;
    _selectedCategoryId = account.categoryId;
    _selectedService = _services.contains(account.serviceName) ? account.serviceName : 'Other...';
    _otherServiceController.text = !_services.contains(account.serviceName) ? account.serviceName : '';
    _usernameController.text = account.username;
    _passwordController.text = EncryptionService().decryptText(account.password);
    _recoveryController.text = account.recoveryAccount ?? '';
    _phoneController.text = account.phoneNumbers ?? '';

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_updatePasswordStrength);
    _otherServiceController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _recoveryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final encryptionService = EncryptionService();
    final authCubit = context.read<AuthCubit>();

    if (!encryptionService.isInitialized) {
      final password = await showMasterPasswordDialog(context);
      if (password == null || password.isEmpty) return;
      final success = await authCubit.verifyMasterPassword(password);
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.errorIncorrectPassword), backgroundColor: Colors.red));
        }
        return;
      }
    }

    final userId = await SessionManager.getUserId();
    if (userId == null) return;

    final encryptedPassword = encryptionService.encryptText(_passwordController.text);
    final finalServiceName = _selectedService == 'Other...' ? _otherServiceController.text : _selectedService!;

    if (widget.accountToEdit != null) {
      final updatedAccount = widget.accountToEdit!.copyWith(
        categoryId: _selectedCategoryId!,
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
        categoryId: _selectedCategoryId!,
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

    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, categoryState) {
        return Padding(
          padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20),
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
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 20),
                  if (categoryState is CategoryLoaded)
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                          labelText: l10n.accountFormCategoryHint,
                          prefixIcon: const Icon(AppIcons.category)),
                      value: _selectedCategoryId,
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
                          setState(() => _selectedCategoryId = newValue);
                        }
                      },
                      validator: (value) => value == null || value == -1
                          ? l10n.validationSelectCategory
                          : null,
                    ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        labelText: l10n.accountFormServiceNameHint,
                        prefixIcon: const Icon(AppIcons.service)),
                    value: _selectedService,
                    items: _services
                        .map((String service) => DropdownMenuItem<String>(
                        value: service, child: CustomText(service)))
                        .toList(),
                    onChanged: (newValue) =>
                        setState(() => _selectedService = newValue),
                    validator: (value) =>
                    value == null ? l10n.validationSelectService : null,
                  ),
                  if (_selectedService == 'Other...')
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: CustomTextField(
                          controller: _otherServiceController,
                          labelText: l10n.accountFormEnterServiceName,
                          prefixIcon: AppIcons.edit,
                          validator: (value) =>
                          value!.isEmpty ? l10n.validationEnterServiceName : null),
                    ),
                  const SizedBox(height: 10),
                  CustomTextField(
                      controller: _usernameController,
                      labelText: l10n.accountFormUsernameHint,
                      prefixIcon: AppIcons.user),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: _passwordController,
                    labelText: l10n.accountDetailsPassword,
                    prefixIcon: AppIcons.lock,
                    isPassword: !_isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible
                          ? AppIcons.eyeSlash
                          : AppIcons.eye),
                      onPressed: () =>
                          setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _PasswordStrengthIndicator(
                    strength: _passwordStrength,
                    strengthText: _passwordStrengthText,
                  ),
                  const SizedBox(height: 10),
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
                      onPressed: _onSave, text: l10n.accountFormSaveButton),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCreateCategoryDialog() {
    final l10n = AppLocalizations.of(context)!;
    final categoryNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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

double _checkPasswordStrength(String password) {
  if (password.isEmpty) return 0.0;
  double score = 0;
  if (password.length >= 8) score += 0.25;
  if (RegExp(r'[a-z]').hasMatch(password) &&
      RegExp(r'[A-Z]').hasMatch(password)) score += 0.25;
  if (RegExp(r'[0-9]').hasMatch(password)) score += 0.25;
  if (RegExp(r'[^a-zA-Z0-9]').hasMatch(password)) score += 0.25;
  return score;
}

String _getStrengthText(BuildContext context, double strength) {
  // TODO: Localize these strings
  if (strength < 0.5) return AppLocalizations.of(context)!.passwordStrengthWeak;
  if (strength < 0.75) return AppLocalizations.of(context)!.passwordStrengthGood;
  if (strength < 1.0) return AppLocalizations.of(context)!.passwordStrengthStrong;
  return AppLocalizations.of(context)!.passwordStrengthVeryStrong;
}