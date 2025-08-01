import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../core/services/database_services.dart';
import '../../core/services/navigation_service.dart';
import '../../core/services/session_manager.dart';
import '../../core/widgets/custom_elevated_button.dart';
import '../../core/widgets/custom_text.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../model/account_model.dart';
import '../../model/category_model.dart';
import '../auth/cubit/auth_cubit/cubit.dart';
import '../auth/cubit/auth_cubit/states.dart';
import '../auth/screens/sign_in/sign_in_screen.dart';
import 'cubit/account_cubit/cubit.dart';
import 'cubit/account_cubit/states.dart';
import 'cubit/category_cubit/cubit.dart';
import 'cubit/category_cubit/states.dart';
import 'widgets/account_card.dart';

final List<String> services = [
  'Gmail',
  'Outlook',
  'Hotmail',
  'Facebook',
  'Instagram',
  'Other...'
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AccountCubit(DatabaseService())..loadAccounts(),
        ),
        BlocProvider(
          create: (context) =>
          CategoryCubit(DatabaseService())..loadCategories(),
        ),
      ],
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOut) {
          NavigationService.pushAndRemoveUntil(const SignInScreen());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const CustomText('My Accounts'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () => context.read<AuthCubit>().logout(),
            )
          ],
        ),
        body: BlocBuilder<AccountCubit, AccountState>(
          builder: (context, accountState) {
            return BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, categoryState) {
                if (accountState is AccountLoading ||
                    categoryState is CategoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (accountState is AccountLoaded &&
                    categoryState is CategoryLoaded) {
                  if (accountState.accounts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shield_outlined,
                              size: 80,
                              color: Theme
                                  .of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color
                                  ?.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          const CustomText("Your vault is empty."),
                          const CustomText("Press '+' to add an account.",
                              style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    );
                  }

                  final groupedAccounts = groupBy(
                      accountState.accounts, (Account acc) => acc.categoryId);
                  final categories = categoryState.categories;

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final accountsInCategory = groupedAccounts[category.id] ??
                          [];

                      if (accountsInCategory.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                            child: CustomText(
                              category.name,
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                color:
                                Theme
                                    .of(context)
                                    .colorScheme
                                    .primary,
                              ),
                            ),
                          ),
                          ...accountsInCategory.map((account) {
                            return Slidable(
                              key: ValueKey(account.id),
                              startActionPane: ActionPane(
                                motion: const StretchMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (_) =>
                                        _showEditAccountForm(context, account),
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    icon: Icons.edit,
                                    label: 'Edit',
                                  ),
                                ],
                              ),
                              endActionPane: ActionPane(
                                motion: const StretchMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (_) =>
                                        _showDeleteConfirmation(
                                            context, account.id!),
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Delete',
                                  ),
                                ],
                              ),
                              child: AccountCard(
                                account: account,
                                onTap: () =>
                                    _showAccountDetails(context, account),
                              ),
                            ).animate().fadeIn().slideY(begin: 0.1);
                          }),
                        ],
                      );
                    },
                  );
                }
                return const Center(child: Text("Something went wrong."));
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddAccountForm(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showAddAccountForm(BuildContext context) {
    final accountCubit = context.read<AccountCubit>();
    final categoryCubit = context.read<CategoryCubit>();

    final formKey = GlobalKey<FormState>();
    int? selectedCategoryId;

    String? selectedService;
    final otherServiceController = TextEditingController();

    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final recoveryController = TextEditingController();
    final phoneController = TextEditingController();

    void showCreateCategoryDialog() {
      final categoryNameController = TextEditingController();
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Create New Category'),
          content: CustomTextField(
            controller: categoryNameController,
            labelText: 'Category Name',
            prefixIcon: Icons.create_new_folder_outlined,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (categoryNameController.text.isNotEmpty) {
                  categoryCubit.addCategory(categoryNameController.text);
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      builder: (ctx) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: accountCubit),
            BlocProvider.value(value: categoryCubit),
          ],
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return BlocBuilder<CategoryCubit, CategoryState>(
                builder: (context, categoryState) {
                  return Padding(
                    padding: EdgeInsets.only(
                        top: 20,
                        left: 20,
                        right: 20,
                        bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
                    child: Form(
                      key: formKey,
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
                            CustomText("Add New Account",
                                style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 20),
                            if (categoryState is CategoryLoaded)
                              DropdownButtonFormField<int>(
                                decoration: const InputDecoration(
                                    labelText: "Category",
                                    prefixIcon: Icon(Icons.category_outlined)),
                                value: selectedCategoryId,
                                items: [
                                  const DropdownMenuItem(
                                      value: -1,
                                      child: Text("Create New Category...")),
                                  ...categoryState.categories
                                      .map((Category cat) {
                                    return DropdownMenuItem<int>(
                                        value: cat.id, child: Text(cat.name));
                                  }).toList(),
                                ],
                                onChanged: (newValue) {
                                  if (newValue == -1) {
                                    showCreateCategoryDialog();
                                  } else {
                                    setModalState(
                                            () => selectedCategoryId = newValue);
                                  }
                                },
                                validator: (value) => value == null || value == -1
                                    ? 'Please select a category'
                                    : null,
                              ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                  labelText: "Service Name",
                                  prefixIcon: Icon(Icons.web_asset_outlined)),
                              value: selectedService,
                              items: services.map((String service) {
                                return DropdownMenuItem<String>(
                                    value: service, child: CustomText(service));
                              }).toList(),
                              onChanged: (newValue) =>
                                  setModalState(() => selectedService = newValue),
                              validator: (value) =>
                              value == null ? 'Please select a service' : null,
                            ),
                            if (selectedService == 'Other...')
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: CustomTextField(
                                  controller: otherServiceController,
                                  labelText: "Enter Service Name",
                                  prefixIcon: Icons.edit_note_outlined,
                                  validator: (value) =>
                                  value!.isEmpty ? 'Please enter a name' : null,
                                ),
                              ).animate().fadeIn(duration: 300.ms),
                            const SizedBox(height: 10),
                            CustomTextField(
                                controller: usernameController,
                                labelText: "Username or Email",
                                prefixIcon: Icons.person_outline),
                            const SizedBox(height: 10),
                            CustomTextField(
                                controller: passwordController,
                                labelText: "Password",
                                prefixIcon: Icons.lock_outline,
                                isPassword: true),
                            const SizedBox(height: 10),
                            CustomTextField(
                                controller: recoveryController,
                                labelText: "Recovery Account (Optional)",
                                prefixIcon: Icons.email_outlined),
                            const SizedBox(height: 10),
                            CustomTextField(
                                controller: phoneController,
                                labelText: "Phone Numbers (Optional)",
                                prefixIcon: Icons.phone_outlined),
                            const SizedBox(height: 20),
                            CustomElevatedButton(
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  final userId = await SessionManager.getUserId();
                                  if (userId != null &&
                                      selectedCategoryId != null) {
                                    final finalServiceName =
                                    selectedService == 'Other...'
                                        ? otherServiceController.text
                                        : selectedService!;

                                    final newAccount = Account(
                                      userId: userId,
                                      categoryId: selectedCategoryId!,
                                      serviceName: finalServiceName,
                                      username: usernameController.text,
                                      password: passwordController.text,
                                      recoveryAccount: recoveryController.text,
                                      phoneNumbers: phoneController.text,
                                    );
                                    context
                                        .read<AccountCubit>()
                                        .addAccount(newAccount);
                                    Navigator.of(ctx).pop();
                                  }
                                }
                              },
                              text: "Save",
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showEditAccountForm(BuildContext context, Account accountToEdit) {
    final accountCubit = context.read<AccountCubit>();
    final categoryCubit = context.read<CategoryCubit>();

    final formKey = GlobalKey<FormState>();
    int? selectedCategoryId = accountToEdit.categoryId;


    String? selectedService = services.contains(accountToEdit.serviceName)
        ? accountToEdit.serviceName
        : 'Other...';
    final otherServiceController = TextEditingController(
        text: services.contains(accountToEdit.serviceName)
            ? ''
            : accountToEdit.serviceName);

    final usernameController = TextEditingController(text: accountToEdit.username);
    final passwordController = TextEditingController(text: accountToEdit.password);
    final recoveryController =
    TextEditingController(text: accountToEdit.recoveryAccount);
    final phoneController =
    TextEditingController(text: accountToEdit.phoneNumbers);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      builder: (ctx) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: accountCubit),
            BlocProvider.value(value: categoryCubit),
          ],
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return BlocBuilder<CategoryCubit, CategoryState>(
                builder: (context, categoryState) {
                  return Padding(
                    padding: EdgeInsets.only(
                        top: 20,
                        left: 20,
                        right: 20,
                        bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
                    child: Form(
                      key: formKey,
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
                            CustomText("Edit Account",
                                style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 20),
                            if (categoryState is CategoryLoaded)
                              DropdownButtonFormField<int>(
                                decoration: const InputDecoration(
                                    labelText: "Category",
                                    prefixIcon: Icon(Icons.category_outlined)),
                                value: selectedCategoryId,
                                items:
                                categoryState.categories.map((Category cat) {
                                  return DropdownMenuItem<int>(
                                      value: cat.id, child: Text(cat.name));
                                }).toList(),
                                // --- FIX IS HERE ---
                                onChanged: (newValue) =>
                                    setModalState(() => selectedCategoryId = newValue),
                                validator: (value) =>
                                value == null ? 'Please select a category' : null,
                              ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                  labelText: "Service Name",
                                  prefixIcon: Icon(Icons.web_asset_outlined)),
                              value: selectedService,
                              items: services
                                  .map((String service) =>
                                  DropdownMenuItem<String>(
                                      value: service,
                                      child: CustomText(service)))
                                  .toList(),
                              // --- AND FIX IS HERE ---
                              onChanged: (newValue) =>
                                  setModalState(() => selectedService = newValue),
                              validator: (value) =>
                              value == null ? 'Please select a service' : null,
                            ),
                            if (selectedService == 'Other...')
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: CustomTextField(
                                  controller: otherServiceController,
                                  labelText: "Enter Service Name",
                                  prefixIcon: Icons.edit_note_outlined,
                                  validator: (value) => value!.isEmpty
                                      ? 'Please enter a name'
                                      : null,
                                ),
                              ).animate().fadeIn(duration: 300.ms),
                            const SizedBox(height: 10),
                            CustomTextField(
                                controller: usernameController,
                                labelText: "Username or Email",
                                prefixIcon: Icons.person_outline),
                            const SizedBox(height: 10),
                            CustomTextField(
                                controller: passwordController,
                                labelText: "Password",
                                prefixIcon: Icons.lock_outline,
                                isPassword: true),
                            const SizedBox(height: 10),
                            CustomTextField(
                                controller: recoveryController,
                                labelText: "Recovery Account (Optional)",
                                prefixIcon: Icons.email_outlined),
                            const SizedBox(height: 10),
                            CustomTextField(
                                controller: phoneController,
                                labelText: "Phone Numbers (Optional)",
                                prefixIcon: Icons.phone_outlined),
                            const SizedBox(height: 20),
                            CustomElevatedButton(
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  final finalServiceName =
                                  selectedService == 'Other...'
                                      ? otherServiceController.text
                                      : selectedService!;

                                  final updatedAccount = Account(
                                    id: accountToEdit.id,
                                    userId: accountToEdit.userId,
                                    categoryId: selectedCategoryId!,
                                    serviceName: finalServiceName,
                                    username: usernameController.text,
                                    password: passwordController.text,
                                    recoveryAccount: recoveryController.text,
                                    phoneNumbers: phoneController.text,
                                  );
                                  context
                                      .read<AccountCubit>()
                                      .updateAccount(updatedAccount);
                                  Navigator.of(ctx).pop();
                                }
                              },
                              text: "Save",
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showAccountDetails(BuildContext context, Account account) {
    // This state variable is scoped to this function and the modal.
    bool isPasswordVisible = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          // This builder gives us a special `setModalState` function
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomText(account.serviceName,
                      style: Theme
                          .of(context)
                          .textTheme
                          .headlineSmall),
                  const Divider(height: 32),
                  _buildDetailRow(
                      context, Icons.person_outline, "Username",
                      account.username),
                  _buildDetailRow(context, Icons.lock_outline, "Password",
                      isPasswordVisible ? account.password : '••••••••••',
                      trailing: IconButton(
                        icon: Icon(isPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        // --- THE FIX IS HERE ---
                        onPressed: () {
                          setModalState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      )),
                  if (account.recoveryAccount != null &&
                      account.recoveryAccount!.isNotEmpty)
                    _buildDetailRow(context, Icons.email_outlined,
                        "Recovery Email", account.recoveryAccount!),
                  if (account.phoneNumbers != null &&
                      account.phoneNumbers!.isNotEmpty)
                    _buildDetailRow(context, Icons.phone_outlined,
                        "Phone Numbers", account.phoneNumbers!),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String title,
      String value,
      {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme
              .of(context)
              .colorScheme
              .primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(title,
                    style: TextStyle(
                        fontSize: 12,
                        color:
                        Theme
                            .of(context)
                            .textTheme
                            .bodySmall
                            ?.color)),
                const SizedBox(height: 2),
                CustomText(value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          if (trailing != null) trailing,
          IconButton(
            icon: const Icon(Icons.copy, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                    SnackBar(content: Text('$title copied to clipboard')));
            },
          )
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int accountId) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const CustomText('Confirm Deletion'),
          content: const CustomText(
              'Are you sure you want to delete this account? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const CustomText('Cancel'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              child: CustomText('Delete',
                  style: TextStyle(color: Colors.red.shade700)),
              onPressed: () {
                context.read<AccountCubit>().deleteAccount(accountId);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }
}