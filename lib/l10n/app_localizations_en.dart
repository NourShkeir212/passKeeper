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
  String get lockScreenTitle => 'PassKeeper is Locked';

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
  String get homeScreenEmptyTitle => 'Your Vault is Empty';

  @override
  String get homeScreenEmptySubtitle =>
      'Tap the \'+\' button to add your first secure account.';

  @override
  String homeScreenNoResults(String query) {
    return 'No accounts found for \'$query\'';
  }

  @override
  String get accountCardEdit => 'Edit';

  @override
  String get accountCardDelete => 'Delete';

  @override
  String get accountDetailsUsername => 'Username';

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
  String get accountFormPhoneHint => 'Phone Numbers (Optional)';

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
  String get changePasswordTitle => 'Change Password';

  @override
  String get changePasswordCurrent => 'Current Password';

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
  String get validationEnterUsername => 'Please enter a username';

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
  String get onboardingSkipButton => 'Skip';

  @override
  String get onboardingDoneButton => 'Done';

  @override
  String get aboutScreenTitle => 'About PassKeeper';

  @override
  String get aboutTitle => 'About us';

  @override
  String get aboutScreenVersion => 'Version 1.0.0';

  @override
  String get aboutScreenDescription =>
      'A secure, offline-first password manager built with Flutter to keep your digital life safe and organized.';

  @override
  String get aboutScreenContactTitle => 'Contact & Connect';

  @override
  String get aboutScreenContactEmail => 'Email';

  @override
  String get aboutScreenContactFacebook => 'Facebook';

  @override
  String get aboutScreenContactWhatsApp => 'WhatsApp';
}
