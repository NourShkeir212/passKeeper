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

  // Initialize controllers empty. They will be populated in _initializeForm.
  final _otherServiceController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _recoveryController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = true; // For showing a loading indicator

  static const List<String> _services = [
    'Gmail',
    'Outlook',
    'Hotmail',
    'Facebook',
    'Instagram',
    'X',
    'WhatsApp',
    'Telegram',
    'Other...'
  ];

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to safely call async code after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  Future<void> _initializeForm() async {
    final isEditMode = widget.accountToEdit != null;

    // For "Add" mode, we're ready immediately.
    if (!isEditMode) {
      setState(() => _isLoading = false);
      return;
    }

    // For "Edit" mode, we must ensure the vault is unlocked first.
    final encryptionService = EncryptionService();
    if (!encryptionService.isInitialized) {
      final password = await showMasterPasswordDialog(context);
      if (password == null || password.isEmpty) {
        Navigator.of(context).pop(); // User cancelled
        return;
      }

      final success = await context.read<AuthCubit>().verifyMasterPassword(password);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(AppLocalizations.of(context)!.errorIncorrectPassword), backgroundColor: Colors.red));
        Navigator.of(context).pop(); // Close on failure
        return;
      }
    }

    // Now that the service is guaranteed to be initialized, populate the fields
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

    // Turn off loading and rebuild the UI with the populated data
    setState(() => _isLoading = false);
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

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final encryptionService = EncryptionService();
    final authCubit = context.read<AuthCubit>();

    // The vault unlock check is repeated here just in case the session timed out.
    if (!encryptionService.isInitialized) {
      final password = await showMasterPasswordDialog(context);
      if (password == null || password.isEmpty) return;
      final success = await authCubit.verifyMasterPassword(password);
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(AppLocalizations.of(context)!.errorIncorrectPassword), backgroundColor: Colors.red));
        }
        return;
      }
    }

    final userId = await SessionManager.getUserId();
    if (userId == null) return;

    final encryptedPassword = encryptionService.encryptText(_passwordController.text);
    final finalServiceName = _selectedService == 'Other...' ? _otherServiceController.text : _selectedService!;

    final accountData = {
      'userId': userId,
      'categoryId': _selectedCategoryId!,
      'serviceName': finalServiceName,
      'username': _usernameController.text,
      'password': encryptedPassword,
      'recoveryAccount': _recoveryController.text,
      'phoneNumbers': _phoneController.text,
    };

    if (widget.accountToEdit != null) {
      final updatedAccount = widget.accountToEdit!.copyWith(
        categoryId: _selectedCategoryId!, serviceName: finalServiceName,
        username: _usernameController.text, password: encryptedPassword,
        recoveryAccount: _recoveryController.text, phoneNumbers: _phoneController.text,
      );
      context.read<AccountCubit>().updateAccount(updatedAccount);
    } else {
      context.read<AccountCubit>().addAccount(Account.fromMap(accountData));
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, categoryState) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
                top: 20, left: 20, right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10))),
                    const SizedBox(height: 20),
                    CustomText(widget.accountToEdit != null ? AppLocalizations.of(context)!.accountFormEditTitle : AppLocalizations.of(context)!.accountFormAddTitle, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 20),
          
                    if (categoryState is CategoryLoaded)
                      DropdownButtonFormField<int>(
                        decoration:  InputDecoration(labelText: AppLocalizations.of(context)!.accountFormCategoryHint, prefixIcon: Icon(AppIcons.category)),
                        value: _selectedCategoryId,
                        items: [
                           DropdownMenuItem(value: -1, child: Text(AppLocalizations.of(context)!.accountFormCreateCategory)),
                          ...categoryState.categories.map((Category cat) => DropdownMenuItem<int>(value: cat.id, child: Text(cat.name))).toList(),
                        ],
                        onChanged: (newValue) {
                          if (newValue == -1) { _showCreateCategoryDialog(); }
                          else { setState(() => _selectedCategoryId = newValue); }
                        },
                        validator: (value) => value == null || value == -1 ? AppLocalizations.of(context)!.validationCategoryNameEmpty : null,
                      ),
          
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration:  InputDecoration(labelText: AppLocalizations.of(context)!.accountFormEnterServiceName, prefixIcon: Icon(AppIcons.service)),
                      value: _selectedService,
                      items: _services.map((String service) => DropdownMenuItem<String>(value: service, child: CustomText(service))).toList(),
                      onChanged: (newValue) => setState(() => _selectedService = newValue),
                      validator: (value) => value == null ? AppLocalizations.of(context)!.validationEnterServiceName : null,
                    ),
          
                    if (_selectedService == 'Other...')
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: CustomTextField(controller: _otherServiceController, labelText: AppLocalizations.of(context)!.accountFormServiceNameHint, prefixIcon: AppIcons.edit, validator: (value) => value!.isEmpty ? 'Please enter a name' : null),
                      ),
          
                    const SizedBox(height: 10),
                    CustomTextField(controller: _usernameController, labelText: AppLocalizations.of(context)!.accountFormUsernameHint, prefixIcon: AppIcons.user),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: _passwordController,
                      labelText: AppLocalizations.of(context)!.accountDetailsPassword,
                      prefixIcon: AppIcons.lock,
                      isPassword: !_isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ?  AppIcons.eyeSlash : AppIcons.eye),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(controller: _recoveryController, labelText: AppLocalizations.of(context)!.accountDetailsRecoveryEmail, prefixIcon: AppIcons.email),
                    const SizedBox(height: 10),
                    CustomTextField(controller: _phoneController, labelText: AppLocalizations.of(context)!.accountDetailsPhone, prefixIcon: AppIcons.phone),
                    const SizedBox(height: 20),
                    CustomElevatedButton(onPressed: _onSave, text: AppLocalizations.of(context)!.accountFormSaveButton),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- HELPER DIALOGS ---

  void _showCreateCategoryDialog() {
    final categoryNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title:  Text(AppLocalizations.of(context)!.accountFormCreateCategory),
        content: CustomTextField(controller: categoryNameController, labelText: AppLocalizations.of(context)!.accountFormCategoryHint, prefixIcon: AppIcons.createFolder),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child:  Text(AppLocalizations.of(context)!.dialogCancel)),
          TextButton(
            onPressed: () {
              if (categoryNameController.text.isNotEmpty) {
                context.read<CategoryCubit>().addCategory(categoryNameController.text);
                Navigator.pop(dialogContext);
              }
            },
            child:  Text(AppLocalizations.of(context)!.dialogCreate),
          ),
        ],
      ),
    );
  }


}