import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/encryption_service.dart';
import '../../../core/services/session_manager.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/custom_elevated_button.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/custom_text_field.dart';
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



  late final TextEditingController _otherServiceController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _recoveryController;
  late final TextEditingController _phoneController;

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
    final isEditMode = widget.accountToEdit != null;
    final account = widget.accountToEdit;

    _selectedCategoryId = isEditMode ? account!.categoryId : null;

    if (isEditMode) {
      _selectedService = _services.contains(account!.serviceName)
          ? account.serviceName
          : 'Other...';
    }

    _otherServiceController = TextEditingController(text: isEditMode && !_services.contains(account!.serviceName) ? account.serviceName : '');
    _usernameController = TextEditingController(text: isEditMode ? account!.username : '');

    // --- THE FIX IS HERE ---
    // Decrypt the password before putting it in the controller for editing.
    final decryptedPassword = isEditMode ? EncryptionService().decryptText(account!.password) : '';
    _passwordController = TextEditingController(text: decryptedPassword);

    _recoveryController = TextEditingController(text: isEditMode ? account!.recoveryAccount : '');
    _phoneController = TextEditingController(text: isEditMode ? account!.phoneNumbers : '');
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
    final accountCubit = context.read<AccountCubit>();

    // --- NEW: Check if the vault is unlocked before saving ---
    if (!encryptionService.isInitialized) {
      final password = await _showMasterPasswordDialog(context);
      if (password == null || password.isEmpty) return; // User cancelled

      final success = await authCubit.verifyMasterPassword(password);
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Incorrect password"), backgroundColor: Colors.red),
          );
        }
        return; // Stop if password is wrong
      }
    }

    // --- The rest of the save logic can now proceed safely ---
    final userId = await SessionManager.getUserId();
    if (userId == null) return;

    // Re-encrypt the password before saving
    final encryptedPassword = encryptionService.encryptText(_passwordController.text);
    final finalServiceName = _selectedService == 'Other...' ? _otherServiceController.text : _selectedService!;

    if (widget.accountToEdit != null) {
      final updatedAccount = Account(
          id: widget.accountToEdit!.id,
          userId: userId,
          categoryId: _selectedCategoryId!,
          serviceName: finalServiceName,
          username: _usernameController.text,
          password: encryptedPassword,
          recoveryAccount: _recoveryController.text,
          phoneNumbers: _phoneController.text,
      );
      accountCubit.updateAccount(updatedAccount);
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
      accountCubit.addAccount(newAccount);
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<String?> _showMasterPasswordDialog(BuildContext context) {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Unlock Vault to Save"),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Please enter your master password to save this account."),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Master Password"),
                validator: (v) => v!.isEmpty ? 'Password cannot be empty' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(passwordController.text);
              }
            },
            child: const Text("Unlock"),
          ),
        ],
      ),
    );
  }
  void _showCreateCategoryDialog() {
    final categoryNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create New Category'),
        content: CustomTextField(controller: categoryNameController, labelText: 'Category Name', prefixIcon: AppIcons.createFolder),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (categoryNameController.text.isNotEmpty) {
                context.read<CategoryCubit>().addCategory(categoryNameController.text);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
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
                    CustomText(widget.accountToEdit != null ? "Edit Account" : "Add New Account", style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 20),

                    if (categoryState is CategoryLoaded)
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: "Category", prefixIcon: Icon(AppIcons.category)),
                        value: _selectedCategoryId,
                        items: [
                          const DropdownMenuItem(value: -1, child: Text("Create New Category...")),
                          ...categoryState.categories.map((Category cat) => DropdownMenuItem<int>(value: cat.id, child: Text(cat.name))).toList(),
                        ],
                        onChanged: (newValue) {
                          if (newValue == -1) { _showCreateCategoryDialog(); }
                          else { setState(() => _selectedCategoryId = newValue); }
                        },
                        validator: (value) => value == null || value == -1 ? 'Please select a category' : null,
                      ),
          
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: "Service Name", prefixIcon: Icon(AppIcons.service)),
                      value: _selectedService,
                      items: _services.map((String service) => DropdownMenuItem<String>(value: service, child: CustomText(service))).toList(),
                      onChanged: (newValue) => setState(() => _selectedService = newValue),
                      validator: (value) => value == null ? 'Please select a service' : null,
                    ),
          
                    if (_selectedService == 'Other...')
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: CustomTextField(controller: _otherServiceController, labelText: "Enter Service Name", prefixIcon: AppIcons.edit, validator: (value) => value!.isEmpty ? 'Please enter a name' : null),
                      ),
          
                    const SizedBox(height: 10),
                    CustomTextField(controller: _usernameController, labelText: "Username or Email", prefixIcon: AppIcons.user),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: _passwordController,
                      labelText: "Password",
                      prefixIcon: AppIcons.lock,
                      isPassword: !_isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ?  AppIcons.eyeSlash : AppIcons.eye),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(controller: _recoveryController, labelText: "Recovery Account (Optional)", prefixIcon: AppIcons.email),
                    const SizedBox(height: 10),
                    CustomTextField(controller: _phoneController, labelText: "Phone Numbers (Optional)", prefixIcon: AppIcons.phone),
                    const SizedBox(height: 20),
                    CustomElevatedButton(onPressed: _onSave, text: "Save"),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}