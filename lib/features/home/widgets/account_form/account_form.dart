import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/services/encryption_service.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/master_password_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../model/account_model.dart';
import '../../../../model/category_model.dart';
import '../../../auth/cubit/auth_cubit/cubit.dart';
import '../../cubit/account_cubit/cubit.dart';
import '../../cubit/account_cubit/states.dart';
import '../../cubit/account_form/account_form_cubit.dart';
import '../../cubit/account_form/account_form_state.dart';
import '../../cubit/category_cubit/cubit.dart';
import '../../cubit/category_cubit/states.dart';
import '../password_generator_dialog.dart';
import 'dialogs/create_category_dialog.dart';
import 'dialogs/username_suggestion_dialog.dart';
import 'widgets/account_form_header.dart';
import 'widgets/category_and_service.dart';
import 'widgets/credential_fields.dart';
import 'widgets/custom_fields.dart';
import 'widgets/optional_fields.dart';
import 'widgets/password_strength.dart';
import 'widgets/save_button.dart';

// =================== AccountForm ===================
class AccountForm extends StatelessWidget {
  final Account? accountToEdit;
  const AccountForm({super.key, this.accountToEdit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AccountFormCubit(),
      child: _AccountFormView(accountToEdit: accountToEdit),
    );
  }
}

// =================== _AccountFormView ===================
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
  late final TextEditingController _notesController;

  final List<Map<String, TextEditingController>> _customFields = [];
  final int _maxCustomFields = 5;
  bool _isLoading = true;

  static const List<String> _services = [
    'Gmail', 'Outlook', 'Hotmail', 'MSN',
    'Instagram', 'Facebook', 'Other...'
  ];

  @override
  void initState() {
    super.initState();

    _otherServiceController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _recoveryController = TextEditingController();
    _phoneController = TextEditingController();
    _notesController = TextEditingController();

    _passwordController.addListener(() {
      context.read<AccountFormCubit>().updatePasswordStrength(_passwordController.text);
    });

    if (widget.accountToEdit != null) {
      _initCustomFields(widget.accountToEdit!.customFields);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeForm());
  }

  void _initCustomFields(Map<String, String> fields) {
    _customFields
      ..clear()
      ..addAll(fields.entries.map((e) => {
        'key': TextEditingController(text: e.key),
        'value': TextEditingController(text: e.value),
      }));
  }

  Future<void> _initializeForm() async {
    if (widget.accountToEdit == null) {
      setState(() => _isLoading = false);
      return;
    }

    final encryptionService = EncryptionService();
    if (!encryptionService.isInitialized) {
      final password = await showMasterPasswordDialog(context);
      if (password == null || password.isEmpty) return _closeForm();

      final success = await context.read<AuthCubit>().verifyMasterPassword(password);
      if (!success) return _showErrorAndClose(AppLocalizations.of(context)!.errorIncorrectPassword);
    }

    _populateFieldsForEdit();
  }

  void _populateFieldsForEdit() {
    final account = widget.accountToEdit!;
    final formCubit = context.read<AccountFormCubit>();

    formCubit.selectCategory(account.categoryId);

    final service = _services.contains(account.serviceName) ? account.serviceName : 'Other...';
    formCubit.selectService(service);

    _otherServiceController.text = service == 'Other...' ? account.serviceName : '';
    _usernameController.text = account.username;
    _passwordController.text = EncryptionService().decryptText(account.password);
    _recoveryController.text = account.recoveryAccount ?? '';
    _phoneController.text = account.phoneNumbers ?? '';
    _notesController.text = account.notes ?? '';
    _initCustomFields(account.customFields);

    setState(() => _isLoading = false);
  }

  void _closeForm() {
    if (mounted) Navigator.of(context).pop();
  }

  void _showErrorAndClose(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    for (final c in [
      _otherServiceController,
      _usernameController,
      _passwordController,
      _recoveryController,
      _phoneController,
      _notesController,
      ..._customFields.expand((f) => [f['key']!, f['value']!])
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _onSave(int? categoryId, String? service) async {
    if (!_formKey.currentState!.validate()) return;

    final encryptionService = EncryptionService();
    final authCubit = context.read<AuthCubit>();

    if (!encryptionService.isInitialized) {
      final password = await showMasterPasswordDialog(context);
      if (password == null || password.isEmpty) return;
      final success = await authCubit.verifyMasterPassword(password);
      if (!success) return _showError(AppLocalizations.of(context)!.errorIncorrectPassword);
    }

    final customFieldsMap = {
      for (var f in _customFields)
        if (f['key']!.text.isNotEmpty) f['key']!.text: f['value']!.text
    };

    final userId = await SessionManager.getUserId();
    if (userId == null) return;

    final encryptedPassword = encryptionService.encryptText(_passwordController.text);
    final serviceName = service == 'Other...' ? _otherServiceController.text : service!;

    if (widget.accountToEdit != null) {
      context.read<AccountCubit>().updateAccount(
        widget.accountToEdit!.copyWith(
          customFields: customFieldsMap,
          categoryId: categoryId,
          serviceName: serviceName,
          username: _usernameController.text,
          password: encryptedPassword,
          recoveryAccount: _recoveryController.text,
          phoneNumbers: _phoneController.text,
          notes: _notesController.text,
        ),
      );
    } else {
      final newAccount = Account(
        customFields: customFieldsMap,
        profileTag: SessionManager.currentSessionProfileTag,
        userId: userId,
        categoryId: categoryId!,
        serviceName: serviceName,
        username: _usernameController.text,
        password: encryptedPassword,
        recoveryAccount: _recoveryController.text,
        phoneNumbers: _phoneController.text,
        notes: _notesController.text,
      );
      context.read<AccountCubit>().addAccount(newAccount);
    }

    _closeForm();
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return BlocBuilder<AccountFormCubit, AccountFormState>(
      builder: (context, formState) {
        return BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, categoryState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AccountFormHeader(isEdit: widget.accountToEdit != null),
                        CategoryAndServiceFields(
                          formState: formState,
                          categoryState: categoryState,
                          otherServiceController: _otherServiceController,
                          services: _services,
                          onCreateCategory: ()=>showCreateCategoryDialog(context),
                        ),
                        CredentialFields(
                          formState: formState,
                          usernameController: _usernameController,
                          passwordController: _passwordController,
                          categoryState: categoryState,
                          onSuggestUsername: () async {
                            final selected = await showUsernameSuggestionDialog(context);
                            if (selected != null && selected.isNotEmpty) {
                              _usernameController.text = selected;
                            }
                          },
                        ),
                        OptionalFields(
                          recoveryController: _recoveryController,
                          phoneController: _phoneController,
                          notesController: _notesController,
                        ),
                        CustomFieldsSection(
                          customFields: _customFields,
                          maxCustomFields: _maxCustomFields,
                          onChanged: () => setState(() {}),
                        ),
                        SaveButton(
                          onPressed: () => _onSave(formState.selectedCategoryId, formState.selectedService),
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
}
