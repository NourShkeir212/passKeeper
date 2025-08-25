// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PassKeeper';

  @override
  String get initialScreenLoading => 'Loading...';

  @override
  String get lockScreenTitle => 'is Locked';

  @override
  String get lockScreenSubtitle => 'Authenticate to unlock your vault';

  @override
  String get unlockButton => 'Unlock with Fingerprint';

  @override
  String get loginScreenWelcome => 'Welcome Back';

  @override
  String get loginScreenUsernameHint => 'Username';

  @override
  String get loginScreenPasswordHint => 'Password';

  @override
  String get loginScreenLoginButton => 'Login';

  @override
  String get loginScreenNoAccount => 'Don\'t have an account?';

  @override
  String get loginScreenSignUpLink => 'Sign Up';

  @override
  String get signUpScreenTitle => 'Create Account';

  @override
  String get signUpScreenUsernameHint => 'Username';

  @override
  String get signUpScreenPasswordHint => 'Password';

  @override
  String get signUpScreenCreateButton => 'Create Account';

  @override
  String get signUpScreenHaveAccount => 'Already have an account?';

  @override
  String get signUpScreenLoginLink => 'Login';

  @override
  String get signUpScreenPasswordRuleLength => 'At least 8 characters';

  @override
  String get signUpScreenPasswordRuleLetters => 'Contains letters (a-z, A-Z)';

  @override
  String get signUpScreenPasswordRuleNumbers => 'Contains numbers (0-9)';

  @override
  String get signUpScreenPasswordRuleSpecial =>
      'Contains a special character (e.g., !@#\$)';

  @override
  String get homeScreenTitle => 'My Accounts';

  @override
  String get homeScreenSearchHint => 'Search...';

  @override
  String get homeScreenAllChipTitle => 'All';

  @override
  String get homeScreenEmptyTitle => 'Your Vault is Empty';

  @override
  String get homeScreenEmptySubtitle =>
      'Tap the \'+\' button to add your first secure account.';

  @override
  String homeScreenNoResults(String query) {
    return 'No accounts found for \'$query\'';
  }

  @override
  String homeScreenAccountCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accounts',
      one: '1 account',
      zero: 'No accounts',
    );
    return '$_temp0';
  }

  @override
  String get accountCardEdit => 'Edit';

  @override
  String get accountCardDelete => 'Delete';

  @override
  String get accountDetailsUsernameOrEmail => 'Email / Username';

  @override
  String get accountDetailsPassword => 'Password';

  @override
  String get accountDetailsRecoveryEmail => 'Recovery Email';

  @override
  String get accountDetailsPhone => 'Phone Numbers';

  @override
  String accountDetailsCopied(String title) {
    return '$title copied to clipboard';
  }

  @override
  String get accountFormAddTitle => 'Add New Account';

  @override
  String get accountFormEditTitle => 'Edit Account';

  @override
  String get accountFormCategoryHint => 'Category';

  @override
  String get accountFormCreateCategory => 'Create New Category...';

  @override
  String get accountFormServiceNameHint => 'Service Name';

  @override
  String get accountFormEnterServiceName => 'Enter Service Name';

  @override
  String get accountFormUsernameHint => 'Username or Email';

  @override
  String get accountFormPasswordHint => 'Password';

  @override
  String get accountFormRecoveryHint => 'Recovery Account (Optional)';

  @override
  String get accountFormPhoneHint => 'Phone Number (Optional)';

  @override
  String get accountFormSaveButton => 'Save';

  @override
  String get settingsScreenTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsThemeSystem => 'System Default';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLangEnglish => 'English';

  @override
  String get settingsLangArabic => 'Arabic';

  @override
  String get settingsLangAuto => 'Auto';

  @override
  String get settingsSecurity => 'Security';

  @override
  String get settingsBiometricTitle => 'Enable Biometric Lock';

  @override
  String get settingsBiometricSubtitle =>
      'Use fingerprint/Face ID to unlock the app.';

  @override
  String get settingsChangePassword => 'Change Password';

  @override
  String get settingsDataManagement => 'Data Management';

  @override
  String get settingsImportTitle => 'Import from Excel';

  @override
  String get settingsImportSubtitle => 'Restore accounts from a backup file.';

  @override
  String get settingsExportTitle => 'Export to Excel';

  @override
  String get settingsExportSubtitle =>
      'Save a copy of your accounts to a file.';

  @override
  String get settingsDeleteAllData => 'Delete All Data';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsLogout => 'Logout';

  @override
  String get settingsAutoLockTitle => 'Auto-Lock Timer';

  @override
  String settingsAutoLockMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Minutes',
      one: '1 Minute',
    );
    return '$_temp0';
  }

  @override
  String get settingsAutoLockGroupTitle => 'Auto-Lock';

  @override
  String get changePasswordTitle => 'Update your App password';

  @override
  String get changePasswordSubHeader =>
      'Your new password must be secure and different from the old one.';

  @override
  String get changePasswordCurrent => 'Current Password';

  @override
  String get errorChangePasswordCurrent => 'Incorrect Current Password';

  @override
  String get changePasswordNew => 'New Password';

  @override
  String get changePasswordConfirm => 'Confirm New Password';

  @override
  String get changePasswordSaveButton => 'Save Changes';

  @override
  String get manageCategoriesTitle => 'Manage Categories';

  @override
  String get manageCategoriesEmptySubTitle =>
      'Tap the \'+\' button to add your first category';

  @override
  String get manageCategoriesEmptyTitle => 'No categories created yet.';

  @override
  String get manageCategoriesAddDialogTitle => 'Add New Category';

  @override
  String get manageCategoriesEditDialogTitle => 'Edit Category';

  @override
  String get manageCategoriesSelect => 'Select';

  @override
  String get manageCategoriesSelectAll => 'Select All';

  @override
  String manageCategoriesSelected(int count) {
    return '$count Selected';
  }

  @override
  String dialogConfirmDeleteMulti(int count) {
    return 'Are you sure you want to delete $count categories? All accounts within them will also be deleted.';
  }

  @override
  String get manageCategoriesNameHint => 'Category Name';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogCreate => 'Create';

  @override
  String get dialogSave => 'Save';

  @override
  String get dialogDelete => 'Delete';

  @override
  String get dialogUnlock => 'Unlock';

  @override
  String get dialogConfirmDeleteTitle => 'Confirm Deletion';

  @override
  String get dialogConfirmDeleteAccount =>
      'Are you sure you want to delete this account? This action cannot be undone.';

  @override
  String get dialogConfirmDeleteCategory =>
      'Are you sure you want to delete this category? All accounts within it will also be deleted.';

  @override
  String get dialogConfirmDeleteAllDataTitle => 'Are you sure?';

  @override
  String get dialogConfirmDeleteAllDataContent =>
      'This will permanently delete all your accounts and categories. This action cannot be undone.';

  @override
  String get dialogDeleteForever => 'Delete Forever';

  @override
  String get dialogUnlockVaultTitle => 'Unlock Vault';

  @override
  String get dialogUnlockVaultSave =>
      'Please enter your master password to save this account.';

  @override
  String get dialogUnlockVaultView =>
      'Enter your master password to reveal your accounts for this session.';

  @override
  String get dialogUnlockToContinue =>
      'Please enter your master password to continue.';

  @override
  String get feedbackAccountCreated =>
      'Account created successfully! Please login.';

  @override
  String get feedbackAccountSaved => 'Account saved';

  @override
  String get feedbackPasswordChanged => 'Password changed successfully!';

  @override
  String feedbackImportSuccess(
    int successCount,
    int skippedCount,
    int failCount,
  ) {
    return 'Import complete. Added: $successCount, Skipped (duplicates): $skippedCount, Failed: $failCount.';
  }

  @override
  String get feedbackExporting => 'Exporting...';

  @override
  String get feedbackImporting => 'Importing...';

  @override
  String get validationEnterUsername => 'Please enter a username / email';

  @override
  String get validationEnterPassword => 'Please enter a password';

  @override
  String get validationPasswordEmpty => 'Password cannot be empty';

  @override
  String get validationPasswordTooShort =>
      'Password must be at least 8 characters';

  @override
  String get validationPasswordRules =>
      'Must contain letters, numbers, and a special character';

  @override
  String get validationPasswordsNoMatch => 'Passwords do not match';

  @override
  String get validationSelectService => 'Please select a service';

  @override
  String get validationEnterServiceName => 'Please enter a name';

  @override
  String get validationSelectCategory => 'Please select a category';

  @override
  String get validationCategoryNameEmpty => 'Name cannot be empty';

  @override
  String get errorIncorrectPassword => 'Incorrect password';

  @override
  String get errorInvalidCredentials => 'Invalid username or password.';

  @override
  String get errorUsernameExists =>
      'Username already exists. Please choose another.';

  @override
  String errorImportFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String errorExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get errorSheetNotFound =>
      'Could not find a sheet named \'Accounts\' in the Excel file.';

  @override
  String get errorUserNotLoggedIn => 'User is not logged in.';

  @override
  String get errorGeneric => 'Something went wrong.';

  @override
  String get categoryUncategorized => 'Uncategorized';

  @override
  String get importNoFileSelected => 'No file selected.';

  @override
  String get exportShareText => 'My PassKeeper Account Backup';

  @override
  String get excelHeaderCategory => 'Category';

  @override
  String get excelHeaderServiceName => 'Service Name';

  @override
  String get excelHeaderUsername => 'Username/Email';

  @override
  String get excelHeaderPassword => 'Password';

  @override
  String get excelHeaderRecovery => 'Recovery Account';

  @override
  String get excelHeaderPhone => 'Phone Numbers';

  @override
  String get dialogUnlockToExportTitle => 'Unlock to Export';

  @override
  String get dialogUnlockToExportContent =>
      'Please enter your master password to export your accounts.';

  @override
  String get dialogUnlockToImportTitle => 'Unlock to Import';

  @override
  String get dialogUnlockToImportContent =>
      'Please enter your master password to import your accounts.';

  @override
  String get biometricPromptReason =>
      'Please authenticate to access your vault';

  @override
  String get onboardingPage1Title => 'Secure & Offline';

  @override
  String get onboardingPage1Body =>
      'Your data is encrypted and stored only on your device. You are in complete control.';

  @override
  String get onboardingPage2Title => 'Organize Everything';

  @override
  String get onboardingPage2Body =>
      'Group your accounts into custom categories that you create and manage.';

  @override
  String get onboardingPage3Title => 'Backup & Restore';

  @override
  String get onboardingPage3Body =>
      'Easily export your vault to an Excel file and import it on any device. Your data goes where you go.';

  @override
  String get onboardingPage4Title => 'Decoy Vault';

  @override
  String get onboardingPage4Body =>
      'Create a second, fake vault with its own password. In an emergency, you can reveal the decoy vault while your real data stays completely hidden.';

  @override
  String get onboardingSkipButton => 'Skip';

  @override
  String get onboardingDoneButton => 'Done';

  @override
  String get aboutScreenTitle => 'About PassKeeper';

  @override
  String get aboutTitle => 'About & Contact us';

  @override
  String get aboutScreenVersion => 'Version 1.0.0';

  @override
  String get aboutScreenDescription =>
      'Take control of your digital identity. PassKeeper is a simple and secure password manager that works completely offline, providing a private vault on your device. Your data stays with you, and only you';

  @override
  String get aboutScreenContactTitle => 'Contact & Connect';

  @override
  String get aboutScreenContactEmail => 'Email';

  @override
  String get aboutScreenContactFacebook => 'Facebook';

  @override
  String get aboutScreenContactWhatsApp => 'WhatsApp';

  @override
  String get passwordGeneratorTitle => 'Password Generator';

  @override
  String get passwordGeneratorLength => 'Length:';

  @override
  String get passwordGeneratorUppercase => 'Uppercase (A-Z)';

  @override
  String get passwordGeneratorNumbers => 'Numbers (0-9)';

  @override
  String get passwordGeneratorSymbols => 'Symbols (!@#\$)';

  @override
  String get passwordGeneratorUseButton => 'Use Password';

  @override
  String get passwordGeneratorWeak => 'Weak';

  @override
  String get passwordGeneratorMedium => 'Medium';

  @override
  String get passwordGeneratorStrong => 'Strong';

  @override
  String get passwordGeneratorVeryStrong => 'Very Strong';

  @override
  String get passwordGeneratorTooltip => 'Generate Password';

  @override
  String get expandedTextShowLess => 'Show Less';

  @override
  String get expandedTextShowMore => 'Show More';

  @override
  String get dialogConfirmLogoutTitle => 'Confirm Logout';

  @override
  String get dialogConfirmLogoutContent => 'Are you sure you want to log out?';

  @override
  String get dialogLogoutButton => 'Logout';

  @override
  String get deleteAccountScreenTitle => 'Delete Account';

  @override
  String get deleteAccountWarningTitle => 'Are you absolutely sure?';

  @override
  String get deleteAccountWarningBody =>
      'This action is irreversible. All of your saved accounts, categories, and settings will be permanently deleted. We cannot recover this data for you.';

  @override
  String get deleteAccountConfirmationPrompt =>
      'To confirm, please enter your master password.';

  @override
  String get mirrorAccountTitle => 'Create Decoy Account';

  @override
  String get mirrorAccountSubtitle => 'Set a Decoy Password';

  @override
  String get mirrorAccountDescription =>
      'This is an optional, second password. If you are ever forced to open your vault, you can enter this password to show a fake set of accounts, keeping your real data safe.';

  @override
  String get mirrorAccountDecoyUsernameHint => 'Decoy Username';

  @override
  String get mirrorAccountDecoyPasswordHint => 'Decoy Password';

  @override
  String get mirrorAccountCompleteButton => 'Complete Setup';

  @override
  String get mirrorAccountSkipButton => 'Skip for now';

  @override
  String get mirrorAccountSuccess => 'Decoy account created successfully!';

  @override
  String get decoyVaultTitle => 'Decoy Vault';

  @override
  String get decoyVaultActive => 'Decoy Account Active';

  @override
  String get decoyVaultReset => 'Reset Decoy Vault';

  @override
  String get decoyVaultCreate => 'Create a Decoy Vault';

  @override
  String get decoyVaultSubtitle => 'Add an extra layer of security.';

  @override
  String get decoyResetConfirmTitle => 'Reset Decoy Vault';

  @override
  String get decoyResetConfirmContent =>
      'Are you sure you want to reset your decoy vault? All fake accounts will be permanently deleted.';

  @override
  String get decoyResetButton => 'Reset';

  @override
  String get decoyAccountSocial => 'Social';

  @override
  String get decoyAccountEmail => 'Email';

  @override
  String get decoyAccountShopping => 'Shopping';

  @override
  String get decoyAccountServices => 'Service Accounts';

  @override
  String get decoyAccountWork => 'Work';

  @override
  String get decoyAccountUserName => 'Username';

  @override
  String get decoyCreateTitle => 'Customize Your Decoy Vault';

  @override
  String get decoyCreateSubtitle =>
      'Set a unique username and password, then choose how many fake accounts you want to generate.';

  @override
  String get decoyCreateGeneratedAccounts => 'Generated Accounts';

  @override
  String get decoyCreateGmail => 'Email Accounts';

  @override
  String get decoyCreateFacebook => 'Facebook Accounts';

  @override
  String get decoyCreateInstagram => 'Instagram Accounts';

  @override
  String get decoyCreateShopping => 'Shopping Accounts';

  @override
  String get decoyCreateButton => 'Create Decoy Vault';

  @override
  String get validationGmailRequired =>
      'You must generate at least one email account for the decoy vault.';

  @override
  String get lockScreenOr => 'OR';

  @override
  String get lockScreenPasswordUnlock => 'Enter Master Password';

  @override
  String get lockScreenUnlockButton => 'Unlock';

  @override
  String get dialogDisableBiometricsContent =>
      'If you disable biometrics, the app will open directly to your real vault . You will lose the ability to open your decoy vault.';

  @override
  String get dialogDisableButton => 'Disable';

  @override
  String get dialogDisableBiometricsTitle => 'Disable Biometrics?';

  @override
  String get reorderToolTip => 'Reorder Accounts';

  @override
  String get reorderScreenTitle => 'Reorder';

  @override
  String get decoyCreatePasswordHint =>
      'For your security, please choose a password that is different from your master password.';

  @override
  String get decoyPasswordMatchDialogTitle => 'Password Match';

  @override
  String get decoyPasswordMatchDialogContent =>
      'The decoy password cannot be the same as your real master password. Please choose a different one.';

  @override
  String get dialogOk => 'OK';

  @override
  String get errorPasswordMatchesDecoy =>
      'New password cannot be the same as your decoy password.';

  @override
  String get dialogConfirmExitTitle => 'Exit App?';

  @override
  String get dialogConfirmExitContent =>
      'Are you sure you want to close the app?';

  @override
  String get dialogExitButton => 'Exit';

  @override
  String get accountFormSelectEmailTitle => 'Select from';

  @override
  String get accountFormSelectCategoryTitle => 'Select a category';
}
