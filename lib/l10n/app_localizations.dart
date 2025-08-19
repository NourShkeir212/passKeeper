import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'PassKeeper'**
  String get appTitle;

  /// No description provided for @initialScreenLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get initialScreenLoading;

  /// No description provided for @lockScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'is Locked'**
  String get lockScreenTitle;

  /// No description provided for @lockScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to unlock your vault'**
  String get lockScreenSubtitle;

  /// No description provided for @unlockButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock with Fingerprint'**
  String get unlockButton;

  /// No description provided for @loginScreenWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginScreenWelcome;

  /// No description provided for @loginScreenUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get loginScreenUsernameHint;

  /// No description provided for @loginScreenPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginScreenPasswordHint;

  /// No description provided for @loginScreenLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginScreenLoginButton;

  /// No description provided for @loginScreenNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginScreenNoAccount;

  /// No description provided for @loginScreenSignUpLink.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get loginScreenSignUpLink;

  /// No description provided for @signUpScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signUpScreenTitle;

  /// No description provided for @signUpScreenUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get signUpScreenUsernameHint;

  /// No description provided for @signUpScreenPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signUpScreenPasswordHint;

  /// No description provided for @signUpScreenCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signUpScreenCreateButton;

  /// No description provided for @signUpScreenHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get signUpScreenHaveAccount;

  /// No description provided for @signUpScreenLoginLink.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get signUpScreenLoginLink;

  /// No description provided for @signUpScreenPasswordRuleLength.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get signUpScreenPasswordRuleLength;

  /// No description provided for @signUpScreenPasswordRuleLetters.
  ///
  /// In en, this message translates to:
  /// **'Contains letters (a-z, A-Z)'**
  String get signUpScreenPasswordRuleLetters;

  /// No description provided for @signUpScreenPasswordRuleNumbers.
  ///
  /// In en, this message translates to:
  /// **'Contains numbers (0-9)'**
  String get signUpScreenPasswordRuleNumbers;

  /// No description provided for @signUpScreenPasswordRuleSpecial.
  ///
  /// In en, this message translates to:
  /// **'Contains a special character (e.g., !@#\$)'**
  String get signUpScreenPasswordRuleSpecial;

  /// No description provided for @homeScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'My Accounts'**
  String get homeScreenTitle;

  /// No description provided for @homeScreenSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get homeScreenSearchHint;

  /// No description provided for @homeScreenAllChipTitle.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get homeScreenAllChipTitle;

  /// No description provided for @homeScreenEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Vault is Empty'**
  String get homeScreenEmptyTitle;

  /// No description provided for @homeScreenEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the \'+\' button to add your first secure account.'**
  String get homeScreenEmptySubtitle;

  /// No description provided for @homeScreenNoResults.
  ///
  /// In en, this message translates to:
  /// **'No accounts found for \'{query}\''**
  String homeScreenNoResults(String query);

  /// No description provided for @homeScreenAccountCount.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =0{No accounts} =1{1 account} other{{count} accounts}}'**
  String homeScreenAccountCount(int count);

  /// No description provided for @accountCardEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get accountCardEdit;

  /// No description provided for @accountCardDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get accountCardDelete;

  /// No description provided for @accountDetailsUsernameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Email / Username'**
  String get accountDetailsUsernameOrEmail;

  /// No description provided for @accountDetailsPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get accountDetailsPassword;

  /// No description provided for @accountDetailsRecoveryEmail.
  ///
  /// In en, this message translates to:
  /// **'Recovery Email'**
  String get accountDetailsRecoveryEmail;

  /// No description provided for @accountDetailsPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Numbers'**
  String get accountDetailsPhone;

  /// No description provided for @accountDetailsCopied.
  ///
  /// In en, this message translates to:
  /// **'{title} copied to clipboard'**
  String accountDetailsCopied(String title);

  /// No description provided for @accountFormAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Account'**
  String get accountFormAddTitle;

  /// No description provided for @accountFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Account'**
  String get accountFormEditTitle;

  /// No description provided for @accountFormCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get accountFormCategoryHint;

  /// No description provided for @accountFormCreateCategory.
  ///
  /// In en, this message translates to:
  /// **'Create New Category...'**
  String get accountFormCreateCategory;

  /// No description provided for @accountFormServiceNameHint.
  ///
  /// In en, this message translates to:
  /// **'Service Name'**
  String get accountFormServiceNameHint;

  /// No description provided for @accountFormEnterServiceName.
  ///
  /// In en, this message translates to:
  /// **'Enter Service Name'**
  String get accountFormEnterServiceName;

  /// No description provided for @accountFormUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Username or Email'**
  String get accountFormUsernameHint;

  /// No description provided for @accountFormPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get accountFormPasswordHint;

  /// No description provided for @accountFormRecoveryHint.
  ///
  /// In en, this message translates to:
  /// **'Recovery Account (Optional)'**
  String get accountFormRecoveryHint;

  /// No description provided for @accountFormPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Phone Numbers (Optional)'**
  String get accountFormPhoneHint;

  /// No description provided for @accountFormSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get accountFormSaveButton;

  /// No description provided for @settingsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsScreenTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLangEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLangEnglish;

  /// No description provided for @settingsLangArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get settingsLangArabic;

  /// No description provided for @settingsLangAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get settingsLangAuto;

  /// No description provided for @settingsSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecurity;

  /// No description provided for @settingsBiometricTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Biometric Lock'**
  String get settingsBiometricTitle;

  /// No description provided for @settingsBiometricSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint/Face ID to unlock the app.'**
  String get settingsBiometricSubtitle;

  /// No description provided for @settingsChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get settingsChangePassword;

  /// No description provided for @settingsDataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get settingsDataManagement;

  /// No description provided for @settingsImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import from Excel'**
  String get settingsImportTitle;

  /// No description provided for @settingsImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restore accounts from a backup file.'**
  String get settingsImportSubtitle;

  /// No description provided for @settingsExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export to Excel'**
  String get settingsExportTitle;

  /// No description provided for @settingsExportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save a copy of your accounts to a file.'**
  String get settingsExportSubtitle;

  /// No description provided for @settingsDeleteAllData.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get settingsDeleteAllData;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settingsLogout;

  /// No description provided for @settingsAutoLockTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-Lock Timer'**
  String get settingsAutoLockTitle;

  /// No description provided for @settingsAutoLockMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 Minute}other{{count} Minutes}}'**
  String settingsAutoLockMinutes(int count);

  /// No description provided for @settingsAutoLockGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-Lock'**
  String get settingsAutoLockGroupTitle;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Update your App password'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordSubHeader.
  ///
  /// In en, this message translates to:
  /// **'Your new password must be secure and different from the old one.'**
  String get changePasswordSubHeader;

  /// No description provided for @changePasswordCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get changePasswordCurrent;

  /// No description provided for @errorChangePasswordCurrent.
  ///
  /// In en, this message translates to:
  /// **'Incorrect Current Password'**
  String get errorChangePasswordCurrent;

  /// No description provided for @changePasswordNew.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get changePasswordNew;

  /// No description provided for @changePasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get changePasswordConfirm;

  /// No description provided for @changePasswordSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get changePasswordSaveButton;

  /// No description provided for @manageCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategoriesTitle;

  /// No description provided for @manageCategoriesEmptySubTitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the \'+\' button to add your first category'**
  String get manageCategoriesEmptySubTitle;

  /// No description provided for @manageCategoriesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No categories created yet.'**
  String get manageCategoriesEmptyTitle;

  /// No description provided for @manageCategoriesAddDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Category'**
  String get manageCategoriesAddDialogTitle;

  /// No description provided for @manageCategoriesEditDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get manageCategoriesEditDialogTitle;

  /// No description provided for @manageCategoriesSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get manageCategoriesSelect;

  /// No description provided for @manageCategoriesSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get manageCategoriesSelectAll;

  /// No description provided for @manageCategoriesSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} Selected'**
  String manageCategoriesSelected(int count);

  /// No description provided for @dialogConfirmDeleteMulti.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {count} categories? All accounts within them will also be deleted.'**
  String dialogConfirmDeleteMulti(int count);

  /// No description provided for @manageCategoriesNameHint.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get manageCategoriesNameHint;

  /// No description provided for @dialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancel;

  /// No description provided for @dialogCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get dialogCreate;

  /// No description provided for @dialogSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get dialogSave;

  /// No description provided for @dialogDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get dialogDelete;

  /// No description provided for @dialogUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get dialogUnlock;

  /// No description provided for @dialogConfirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get dialogConfirmDeleteTitle;

  /// No description provided for @dialogConfirmDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this account? This action cannot be undone.'**
  String get dialogConfirmDeleteAccount;

  /// No description provided for @dialogConfirmDeleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this category? All accounts within it will also be deleted.'**
  String get dialogConfirmDeleteCategory;

  /// No description provided for @dialogConfirmDeleteAllDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get dialogConfirmDeleteAllDataTitle;

  /// No description provided for @dialogConfirmDeleteAllDataContent.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your accounts and categories. This action cannot be undone.'**
  String get dialogConfirmDeleteAllDataContent;

  /// No description provided for @dialogDeleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete Forever'**
  String get dialogDeleteForever;

  /// No description provided for @dialogUnlockVaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Vault'**
  String get dialogUnlockVaultTitle;

  /// No description provided for @dialogUnlockVaultSave.
  ///
  /// In en, this message translates to:
  /// **'Please enter your master password to save this account.'**
  String get dialogUnlockVaultSave;

  /// No description provided for @dialogUnlockVaultView.
  ///
  /// In en, this message translates to:
  /// **'Enter your master password to reveal your accounts for this session.'**
  String get dialogUnlockVaultView;

  /// No description provided for @dialogUnlockToContinue.
  ///
  /// In en, this message translates to:
  /// **'Please enter your master password to continue.'**
  String get dialogUnlockToContinue;

  /// No description provided for @feedbackAccountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully! Please login.'**
  String get feedbackAccountCreated;

  /// No description provided for @feedbackAccountSaved.
  ///
  /// In en, this message translates to:
  /// **'Account saved'**
  String get feedbackAccountSaved;

  /// No description provided for @feedbackPasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully!'**
  String get feedbackPasswordChanged;

  /// No description provided for @feedbackImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Import complete. Added: {successCount}, Skipped (duplicates): {skippedCount}, Failed: {failCount}.'**
  String feedbackImportSuccess(
    int successCount,
    int skippedCount,
    int failCount,
  );

  /// No description provided for @feedbackExporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting...'**
  String get feedbackExporting;

  /// No description provided for @feedbackImporting.
  ///
  /// In en, this message translates to:
  /// **'Importing...'**
  String get feedbackImporting;

  /// No description provided for @validationEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get validationEnterUsername;

  /// No description provided for @validationEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get validationEnterPassword;

  /// No description provided for @validationPasswordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty'**
  String get validationPasswordEmpty;

  /// No description provided for @validationPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get validationPasswordTooShort;

  /// No description provided for @validationPasswordRules.
  ///
  /// In en, this message translates to:
  /// **'Must contain letters, numbers, and a special character'**
  String get validationPasswordRules;

  /// No description provided for @validationPasswordsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationPasswordsNoMatch;

  /// No description provided for @validationSelectService.
  ///
  /// In en, this message translates to:
  /// **'Please select a service'**
  String get validationSelectService;

  /// No description provided for @validationEnterServiceName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get validationEnterServiceName;

  /// No description provided for @validationSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get validationSelectCategory;

  /// No description provided for @validationCategoryNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get validationCategoryNameEmpty;

  /// No description provided for @errorIncorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get errorIncorrectPassword;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorUsernameExists.
  ///
  /// In en, this message translates to:
  /// **'Username already exists. Please choose another.'**
  String get errorUsernameExists;

  /// No description provided for @errorImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String errorImportFailed(String error);

  /// No description provided for @errorExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String errorExportFailed(String error);

  /// No description provided for @errorSheetNotFound.
  ///
  /// In en, this message translates to:
  /// **'Could not find a sheet named \'Accounts\' in the Excel file.'**
  String get errorSheetNotFound;

  /// No description provided for @errorUserNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'User is not logged in.'**
  String get errorUserNotLoggedIn;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorGeneric;

  /// No description provided for @categoryUncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get categoryUncategorized;

  /// No description provided for @importNoFileSelected.
  ///
  /// In en, this message translates to:
  /// **'No file selected.'**
  String get importNoFileSelected;

  /// No description provided for @exportShareText.
  ///
  /// In en, this message translates to:
  /// **'My PassKeeper Account Backup'**
  String get exportShareText;

  /// No description provided for @excelHeaderCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get excelHeaderCategory;

  /// No description provided for @excelHeaderServiceName.
  ///
  /// In en, this message translates to:
  /// **'Service Name'**
  String get excelHeaderServiceName;

  /// No description provided for @excelHeaderUsername.
  ///
  /// In en, this message translates to:
  /// **'Username/Email'**
  String get excelHeaderUsername;

  /// No description provided for @excelHeaderPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get excelHeaderPassword;

  /// No description provided for @excelHeaderRecovery.
  ///
  /// In en, this message translates to:
  /// **'Recovery Account'**
  String get excelHeaderRecovery;

  /// No description provided for @excelHeaderPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Numbers'**
  String get excelHeaderPhone;

  /// No description provided for @dialogUnlockToExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock to Export'**
  String get dialogUnlockToExportTitle;

  /// No description provided for @dialogUnlockToExportContent.
  ///
  /// In en, this message translates to:
  /// **'Please enter your master password to export your accounts.'**
  String get dialogUnlockToExportContent;

  /// No description provided for @dialogUnlockToImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock to Import'**
  String get dialogUnlockToImportTitle;

  /// No description provided for @dialogUnlockToImportContent.
  ///
  /// In en, this message translates to:
  /// **'Please enter your master password to import your accounts.'**
  String get dialogUnlockToImportContent;

  /// No description provided for @biometricPromptReason.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to access your vault'**
  String get biometricPromptReason;

  /// No description provided for @onboardingPage1Title.
  ///
  /// In en, this message translates to:
  /// **'Secure & Offline'**
  String get onboardingPage1Title;

  /// No description provided for @onboardingPage1Body.
  ///
  /// In en, this message translates to:
  /// **'Your data is encrypted and stored only on your device. You are in complete control.'**
  String get onboardingPage1Body;

  /// No description provided for @onboardingPage2Title.
  ///
  /// In en, this message translates to:
  /// **'Organize Everything'**
  String get onboardingPage2Title;

  /// No description provided for @onboardingPage2Body.
  ///
  /// In en, this message translates to:
  /// **'Group your accounts into custom categories that you create and manage.'**
  String get onboardingPage2Body;

  /// No description provided for @onboardingPage3Title.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get onboardingPage3Title;

  /// No description provided for @onboardingPage3Body.
  ///
  /// In en, this message translates to:
  /// **'Easily export your vault to an Excel file and import it on any device. Your data goes where you go.'**
  String get onboardingPage3Body;

  /// No description provided for @onboardingPage4Title.
  ///
  /// In en, this message translates to:
  /// **'Decoy Vault'**
  String get onboardingPage4Title;

  /// No description provided for @onboardingPage4Body.
  ///
  /// In en, this message translates to:
  /// **'Create a second, fake vault with its own password. In an emergency, you can reveal the decoy vault while your real data stays completely hidden.'**
  String get onboardingPage4Body;

  /// No description provided for @onboardingSkipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkipButton;

  /// No description provided for @onboardingDoneButton.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get onboardingDoneButton;

  /// No description provided for @aboutScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'About PassKeeper'**
  String get aboutScreenTitle;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About & Contact us'**
  String get aboutTitle;

  /// No description provided for @aboutScreenVersion.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get aboutScreenVersion;

  /// No description provided for @aboutScreenDescription.
  ///
  /// In en, this message translates to:
  /// **'Take control of your digital identity. PassKeeper is a simple and secure password manager that works completely offline, providing a private vault on your device. Your data stays with you, and only you'**
  String get aboutScreenDescription;

  /// No description provided for @aboutScreenContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact & Connect'**
  String get aboutScreenContactTitle;

  /// No description provided for @aboutScreenContactEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get aboutScreenContactEmail;

  /// No description provided for @aboutScreenContactFacebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get aboutScreenContactFacebook;

  /// No description provided for @aboutScreenContactWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get aboutScreenContactWhatsApp;

  /// No description provided for @passwordGeneratorTitle.
  ///
  /// In en, this message translates to:
  /// **'Password Generator'**
  String get passwordGeneratorTitle;

  /// No description provided for @passwordGeneratorLength.
  ///
  /// In en, this message translates to:
  /// **'Length:'**
  String get passwordGeneratorLength;

  /// No description provided for @passwordGeneratorUppercase.
  ///
  /// In en, this message translates to:
  /// **'Uppercase (A-Z)'**
  String get passwordGeneratorUppercase;

  /// No description provided for @passwordGeneratorNumbers.
  ///
  /// In en, this message translates to:
  /// **'Numbers (0-9)'**
  String get passwordGeneratorNumbers;

  /// No description provided for @passwordGeneratorSymbols.
  ///
  /// In en, this message translates to:
  /// **'Symbols (!@#\$)'**
  String get passwordGeneratorSymbols;

  /// No description provided for @passwordGeneratorUseButton.
  ///
  /// In en, this message translates to:
  /// **'Use Password'**
  String get passwordGeneratorUseButton;

  /// No description provided for @passwordGeneratorWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get passwordGeneratorWeak;

  /// No description provided for @passwordGeneratorMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get passwordGeneratorMedium;

  /// No description provided for @passwordGeneratorStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get passwordGeneratorStrong;

  /// No description provided for @passwordGeneratorVeryStrong.
  ///
  /// In en, this message translates to:
  /// **'Very Strong'**
  String get passwordGeneratorVeryStrong;

  /// No description provided for @passwordGeneratorTooltip.
  ///
  /// In en, this message translates to:
  /// **'Generate Password'**
  String get passwordGeneratorTooltip;

  /// No description provided for @expandedTextShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get expandedTextShowLess;

  /// No description provided for @expandedTextShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get expandedTextShowMore;

  /// No description provided for @dialogConfirmLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get dialogConfirmLogoutTitle;

  /// No description provided for @dialogConfirmLogoutContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get dialogConfirmLogoutContent;

  /// No description provided for @dialogLogoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get dialogLogoutButton;

  /// No description provided for @deleteAccountScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountScreenTitle;

  /// No description provided for @deleteAccountWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you absolutely sure?'**
  String get deleteAccountWarningTitle;

  /// No description provided for @deleteAccountWarningBody.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible. All of your saved accounts, categories, and settings will be permanently deleted. We cannot recover this data for you.'**
  String get deleteAccountWarningBody;

  /// No description provided for @deleteAccountConfirmationPrompt.
  ///
  /// In en, this message translates to:
  /// **'To confirm, please enter your master password.'**
  String get deleteAccountConfirmationPrompt;

  /// No description provided for @mirrorAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Decoy Account'**
  String get mirrorAccountTitle;

  /// No description provided for @mirrorAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set a Decoy Password'**
  String get mirrorAccountSubtitle;

  /// No description provided for @mirrorAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'This is an optional, second password. If you are ever forced to open your vault, you can enter this password to show a fake set of accounts, keeping your real data safe.'**
  String get mirrorAccountDescription;

  /// No description provided for @mirrorAccountDecoyUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Decoy Username'**
  String get mirrorAccountDecoyUsernameHint;

  /// No description provided for @mirrorAccountDecoyPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Decoy Password'**
  String get mirrorAccountDecoyPasswordHint;

  /// No description provided for @mirrorAccountCompleteButton.
  ///
  /// In en, this message translates to:
  /// **'Complete Setup'**
  String get mirrorAccountCompleteButton;

  /// No description provided for @mirrorAccountSkipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get mirrorAccountSkipButton;

  /// No description provided for @mirrorAccountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Decoy account created successfully!'**
  String get mirrorAccountSuccess;

  /// No description provided for @decoyVaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Decoy Vault'**
  String get decoyVaultTitle;

  /// No description provided for @decoyVaultActive.
  ///
  /// In en, this message translates to:
  /// **'Decoy Account Active'**
  String get decoyVaultActive;

  /// No description provided for @decoyVaultReset.
  ///
  /// In en, this message translates to:
  /// **'Reset Decoy Vault'**
  String get decoyVaultReset;

  /// No description provided for @decoyVaultCreate.
  ///
  /// In en, this message translates to:
  /// **'Create a Decoy Vault'**
  String get decoyVaultCreate;

  /// No description provided for @decoyVaultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add an extra layer of security.'**
  String get decoyVaultSubtitle;

  /// No description provided for @decoyResetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Decoy Vault'**
  String get decoyResetConfirmTitle;

  /// No description provided for @decoyResetConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset your decoy vault? All fake accounts will be permanently deleted.'**
  String get decoyResetConfirmContent;

  /// No description provided for @decoyResetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get decoyResetButton;

  /// No description provided for @decoyAccountSocial.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get decoyAccountSocial;

  /// No description provided for @decoyAccountEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get decoyAccountEmail;

  /// No description provided for @decoyAccountShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get decoyAccountShopping;

  /// No description provided for @decoyAccountServices.
  ///
  /// In en, this message translates to:
  /// **'Service Accounts'**
  String get decoyAccountServices;

  /// No description provided for @decoyAccountWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get decoyAccountWork;

  /// No description provided for @decoyAccountUserName.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get decoyAccountUserName;

  /// No description provided for @decoyCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Customize Your Decoy Vault'**
  String get decoyCreateTitle;

  /// No description provided for @decoyCreateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set a unique username and password, then choose how many fake accounts you want to generate.'**
  String get decoyCreateSubtitle;

  /// No description provided for @decoyCreateGeneratedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Generated Accounts'**
  String get decoyCreateGeneratedAccounts;

  /// No description provided for @decoyCreateGmail.
  ///
  /// In en, this message translates to:
  /// **'Email Accounts'**
  String get decoyCreateGmail;

  /// No description provided for @decoyCreateFacebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook Accounts'**
  String get decoyCreateFacebook;

  /// No description provided for @decoyCreateInstagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram Accounts'**
  String get decoyCreateInstagram;

  /// No description provided for @decoyCreateShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping Accounts'**
  String get decoyCreateShopping;

  /// No description provided for @decoyCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create Decoy Vault'**
  String get decoyCreateButton;

  /// No description provided for @validationGmailRequired.
  ///
  /// In en, this message translates to:
  /// **'You must generate at least one email account for the decoy vault.'**
  String get validationGmailRequired;

  /// No description provided for @lockScreenOr.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get lockScreenOr;

  /// No description provided for @lockScreenPasswordUnlock.
  ///
  /// In en, this message translates to:
  /// **'Enter Master Password'**
  String get lockScreenPasswordUnlock;

  /// No description provided for @lockScreenUnlockButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get lockScreenUnlockButton;

  /// No description provided for @dialogDisableBiometricsContent.
  ///
  /// In en, this message translates to:
  /// **'If you disable biometrics, the app will open directly to your real vault . You will lose the ability to open your decoy vault.'**
  String get dialogDisableBiometricsContent;

  /// No description provided for @dialogDisableButton.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get dialogDisableButton;

  /// No description provided for @dialogDisableBiometricsTitle.
  ///
  /// In en, this message translates to:
  /// **'Disable Biometrics?'**
  String get dialogDisableBiometricsTitle;

  /// No description provided for @reorderToolTip.
  ///
  /// In en, this message translates to:
  /// **'Reorder Accounts'**
  String get reorderToolTip;

  /// No description provided for @reorderScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorderScreenTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
