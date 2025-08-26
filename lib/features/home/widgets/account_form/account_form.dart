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
import 'widgets/password_strength.dart';





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
  final List<Map<String, TextEditingController>> _customFields = [];
  final int _maxCustomFields = 5;

  bool _isLoading = true;

  static const List<String> _services = [
    'Gmail', 'Outlook', 'Hotmail', 'MSN',
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
    if (widget.accountToEdit != null) {
      widget.accountToEdit!.customFields.forEach((key, value) {
        _customFields.add({
          'key': TextEditingController(text: key),
          'value': TextEditingController(text: value),
        });
      });
    }
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
    // Populate the custom fields from the account data
    _customFields.clear();
    account.customFields.forEach((key, value) {
      _customFields.add({
        'key': TextEditingController(text: key),
        'value': TextEditingController(text: value),
      });
    });
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _otherServiceController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _recoveryController.dispose();
    _phoneController.dispose();
    for (var field in _customFields) {
      field['key']!.dispose();
      field['value']!.dispose();
    }
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
    final Map<String, String> customFieldsMap = {
      for (var field in _customFields)
        if (field['key']!.text.isNotEmpty)
          field['key']!.text: field['value']!.text
    };
    final userId = await SessionManager.getUserId();
    if (userId == null) return;

    final encryptedPassword = encryptionService.encryptText(
        _passwordController.text);
    final finalServiceName = selectedService == 'Other...'
        ? _otherServiceController.text
        : selectedService!;

    if (widget.accountToEdit != null) {
      final updatedAccount = widget.accountToEdit!.copyWith(
        customFields: customFieldsMap,
        categoryId: selectedCategoryId,
        serviceName: finalServiceName,
        username: _usernameController.text,
        password: encryptedPassword,
        recoveryAccount: _recoveryController.text,
        phoneNumbers: _phoneController.text,
      );
      context.read<AccountCubit>().updateAccount(updatedAccount,);
    } else {
      final profileTag = SessionManager.currentSessionProfileTag;
      final newAccount = Account(
        customFields: customFieldsMap,
        profileTag: profileTag,
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


  Future<void> _showUsernameSuggestionDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final categoryState = context
        .read<CategoryCubit>()
        .state;
    final accountState = context
        .read<AccountCubit>()
        .state;

    if (categoryState is! CategoryLoaded || accountState is! AccountLoaded)
      return;

    Category? selectedCategory;
    List<String> suggestions = [];

    final selectedUsername = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (ctx) {
        //StatefulBuilder to manage the state inside the modal
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final String title = selectedCategory == null
                ? l10n.accountFormSelectCategoryTitle
                : "${l10n.accountFormSelectEmailTitle} '${selectedCategory!
                .name}'";

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.5,
              maxChildSize: 0.8,
              builder: (BuildContext context,
                  ScrollController scrollController) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // --- Header with Drag Handle and Title ---
                      Container(width: 40, height: 5, decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10))),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          // Show a back button if a category is selected
                          if (selectedCategory != null)
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new),
                              onPressed: () =>
                                  setModalState(() => selectedCategory = null),
                            ),
                          Expanded(
                            child: CustomText(title, style: Theme
                                .of(context)
                                .textTheme
                                .titleLarge),
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      // --- Body with AnimatedSwitcher ---
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: selectedCategory == null
                          // Show Category List
                              ? ListView.builder(
                            key: const ValueKey('category_list'),
                            controller: scrollController,
                            itemCount: categoryState.categories.length,
                            itemBuilder: (context, index) {
                              final category = categoryState.categories[index];
                              return ListTile(
                                leading: const Icon(AppIcons.category),
                                title: Text(category.name),
                                onTap: () {
                                  suggestions = accountState.accounts
                                      .where((acc) =>
                                  acc.categoryId == category.id)
                                      .map((acc) => acc.username)
                                      .toSet().toList();

                                  if (suggestions.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text(
                                            "No usernames found in that category.")));
                                    return;
                                  }

                                  setModalState(() =>
                                  selectedCategory = category);
                                },
                              );
                            },
                          )
                          // Show Username List
                              : ListView.builder(
                            key: const ValueKey('username_list'),
                            controller: scrollController,
                            itemCount: suggestions.length,
                            itemBuilder: (context, index) {
                              final username = suggestions[index];
                              return ListTile(
                                leading: const Icon(AppIcons.user),
                                title: Text(username, maxLines: 1),
                                onTap: () => Navigator.of(ctx).pop(username),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );

    // If a username was selected, update the text field
    if (selectedUsername != null) {
      _usernameController.text = selectedUsername;
    }
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
                        _buildHeader(context),
                        _buildCategoryAndServiceFields(context),
                        _buildCredentialFields(context),
                        SizedBox(height: _recoveryController.text == ""
                            ? 10
                            : 15),
                        _buildOptionalFields(context),
                        _buildCustomFieldsSection(),
                        _buildSaveButton(context)
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


  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
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
      ],
    );
  }

  Widget _buildCategoryAndServiceFields(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<AccountFormCubit, AccountFormState>(
      buildWhen: (p, c) =>
      p.selectedCategoryId != c.selectedCategoryId ||
          p.selectedService != c.selectedService,
      builder: (context, formState) {
        return BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, categoryState) {
            return Column(
              children: [
                if (categoryState is CategoryLoaded)
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                        fillColor: Theme
                            .of(context)
                            .scaffoldBackgroundColor,
                        labelText: l10n.accountFormCategoryHint,
                        prefixIcon: Icon(AppIcons.category, color: Theme
                            .of(context)
                            .colorScheme
                            .primary,)),
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
                    fillColor: Theme
                        .of(context)
                        .scaffoldBackgroundColor,
                    labelText: l10n.accountFormServiceNameHint,
                    prefixIcon: Icon(AppIcons.service, color: Theme
                        .of(context)
                        .colorScheme
                        .primary,),
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
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCredentialFields(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<AccountFormCubit, AccountFormState>(
      builder: (context, formState) {
        return BlocBuilder<CategoryCubit, CategoryState>(
            builder: (context, categoryState) {
              return Column(
                children: [
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CustomTextField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!
                                  .validationEnterUsername;
                            }
                            return null;
                          },
                          controller: _usernameController,
                          labelText: l10n.accountFormUsernameHint,
                          prefixIcon: AppIcons.user,
                        ),
                      ),

                      // Only show the button if the category state is loaded and not empty
                      if (categoryState is CategoryLoaded &&
                          categoryState.categories.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Iconsax.magicpen),
                          onPressed: () =>
                              _showUsernameSuggestionDialog(context),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CustomTextField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.validationEnterPassword;
                            }
                            return null;
                          },
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
                            builder: (_) => const PasswordGeneratorDialog(),
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
                  PasswordStrengthIndicator(
                    strength: formState.passwordStrength,
                  ),
                ],
              );
            }
        );
      },
    );
  }

  Widget _buildOptionalFields(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
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
      ],
    );
  }

  Widget _buildCustomFieldsSection() {
    final l10n = AppLocalizations.of(context)!;
    final int fieldsLeft = _maxCustomFields - _customFields.length;

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- UPDATED HEADER ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(l10n.customFieldsTitle, style: Theme
                  .of(context)
                  .textTheme
                  .titleMedium),
              if (_customFields.length < _maxCustomFields)
                CustomText(
                  l10n.customFieldsLeft(fieldsLeft),
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodySmall,
                ),
            ],
          ),
          const SizedBox(height: 8),

          // List of the custom field widgets
          ..._customFields.map((field) {
            int index = _customFields.indexOf(field);
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: field['key']!,
                      labelText: l10n.customFieldsFieldName,
                      prefixIcon: Iconsax.tag,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: field['value']!,
                      labelText: l10n.customFieldsValue,
                      prefixIcon: Iconsax.keyboard,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(
                            Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () =>
                            setState(() => _customFields.removeAt(index)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          // "Add Field" Button
          if (_customFields.length < _maxCustomFields)
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.add, size: 20),
                label: Text(l10n.customFieldsAddButton),
                onPressed: () =>
                    setState(() =>
                        _customFields.add({
                          'key': TextEditingController(),
                          'value': TextEditingController(),
                        })),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: SizedBox(
        width: double.infinity,
        child: CustomElevatedButton(
          onPressed: () {
            final formState = context
                .read<AccountFormCubit>()
                .state;
            _onSave(formState.selectedCategoryId, formState.selectedService);
          },
          text: l10n.accountFormSaveButton,
        ),
      ),
    );
  }
}
