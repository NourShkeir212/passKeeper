// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'PassKeeper';

  @override
  String get initialScreenLoading => 'جار التحميل...';

  @override
  String get lockScreenTitle => 'مغلق';

  @override
  String get lockScreenSubtitle => 'استخدم بصمتك لفتح خزنتك';

  @override
  String get unlockButton => 'فتح باستخدام البصمة';

  @override
  String get loginScreenWelcome => 'أهلاً بعودتك';

  @override
  String get loginScreenUsernameHint => 'اسم المستخدم';

  @override
  String get loginScreenPasswordHint => 'كلمة المرور';

  @override
  String get loginScreenLoginButton => 'تسجيل الدخول';

  @override
  String get loginScreenNoAccount => 'ليس لديك حساب؟';

  @override
  String get loginScreenSignUpLink => 'أنشئ حساباً';

  @override
  String get signUpScreenTitle => 'إنشاء حساب';

  @override
  String get signUpScreenUsernameHint => 'اسم المستخدم';

  @override
  String get signUpScreenPasswordHint => 'كلمة المرور';

  @override
  String get signUpScreenCreateButton => 'إنشاء الحساب';

  @override
  String get signUpScreenHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get signUpScreenLoginLink => 'تسجيل الدخول';

  @override
  String get signUpScreenPasswordRuleLength => '8 أحرف على الأقل';

  @override
  String get signUpScreenPasswordRuleLetters => 'تحتوي على أحرف (a-z, A-Z)';

  @override
  String get signUpScreenPasswordRuleNumbers => 'تحتوي على أرقام (0-9)';

  @override
  String get signUpScreenPasswordRuleSpecial => 'تحتوي على رمز خاص (مثل !@#\$)';

  @override
  String get homeScreenTitle => 'حساباتي';

  @override
  String get homeScreenSearchHint => 'بحث...';

  @override
  String get homeScreenAllChipTitle => 'الكل';

  @override
  String get homeScreenEmptyTitle => 'خزنتك فارغة';

  @override
  String get homeScreenEmptySubtitle =>
      'اضغط على زر \'+\' لإضافة أول حساب آمن لك.';

  @override
  String homeScreenNoResults(String query) {
    return 'لم يتم العثور على حسابات لـ \'$query\'';
  }

  @override
  String homeScreenAccountCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حساب',
      many: '$count حسابًا',
      few: '$count حسابات',
      two: 'حسابان',
      one: 'حساب واحد',
      zero: 'لا توجد حسابات',
    );
    return '$_temp0';
  }

  @override
  String get accountCardEdit => 'تعديل';

  @override
  String get accountCardDelete => 'حذف';

  @override
  String get accountDetailsUsernameOrEmail => 'اسم المستخدم / البريد';

  @override
  String get accountDetailsPassword => 'كلمة المرور';

  @override
  String get accountDetailsRecoveryEmail => 'البريد الإلكتروني للاسترداد';

  @override
  String get accountDetailsPhone => 'أرقام الهواتف';

  @override
  String accountDetailsCopied(String title) {
    return 'تم نسخ $title إلى الحافظة';
  }

  @override
  String get accountFormAddTitle => 'إضافة حساب جديد';

  @override
  String get accountFormEditTitle => 'تعديل الحساب';

  @override
  String get accountFormCategoryHint => 'الفئة';

  @override
  String get accountFormCreateCategory => 'إنشاء فئة جديدة...';

  @override
  String get accountFormServiceNameHint => 'اسم الخدمة';

  @override
  String get accountFormEnterServiceName => 'أدخل اسم الخدمة';

  @override
  String get accountFormUsernameHint => 'اسم المستخدم أو البريد الإلكتروني';

  @override
  String get accountFormPasswordHint => 'كلمة المرور';

  @override
  String get accountFormRecoveryHint => 'حساب الاسترداد (اختياري)';

  @override
  String get accountFormPhoneHint => 'أرقام الهواتف (اختياري)';

  @override
  String get accountFormSaveButton => 'حفظ';

  @override
  String get settingsScreenTitle => 'الإعدادات';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get settingsThemeSystem => 'افتراضي النظام';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLangEnglish => 'English';

  @override
  String get settingsLangArabic => 'العربية';

  @override
  String get settingsLangAuto => 'تلقائي';

  @override
  String get settingsSecurity => 'الأمان';

  @override
  String get settingsBiometricTitle => 'تفعيل القفل بالبصمة';

  @override
  String get settingsBiometricSubtitle =>
      'استخدم بصمة الإصبع/الوجه لفتح التطبيق.';

  @override
  String get settingsChangePassword => 'تغيير كلمة المرور';

  @override
  String get settingsDataManagement => 'إدارة البيانات';

  @override
  String get settingsImportTitle => 'استيراد من Excel';

  @override
  String get settingsImportSubtitle => 'استعادة الحسابات من ملف نسخة احتياطية.';

  @override
  String get settingsExportTitle => 'تصدير إلى Excel';

  @override
  String get settingsExportSubtitle => 'حفظ نسخة من حساباتك في ملف.';

  @override
  String get settingsDeleteAllData => 'حذف كل البيانات';

  @override
  String get settingsAccount => 'الحساب';

  @override
  String get settingsLogout => 'تسجيل الخروج';

  @override
  String get settingsAutoLockTitle => 'مؤقت القفل التلقائي';

  @override
  String settingsAutoLockMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دقيقة',
      few: '$count دقائق',
      two: 'دقيقتان',
      one: 'دقيقة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get settingsAutoLockGroupTitle => 'القفل التلقائي';

  @override
  String get changePasswordTitle => 'تحديث كلمة المرور التطبيق';

  @override
  String get changePasswordSubHeader =>
      'كلمة السر الجديدة يجب أن تكون مختلفة و أقوى من القديمة';

  @override
  String get changePasswordCurrent => 'كلمة المرور الحالية';

  @override
  String get errorChangePasswordCurrent => 'كلمة المرور الحالية غير صحيحة';

  @override
  String get changePasswordNew => 'كلمة المرور الجديدة';

  @override
  String get changePasswordConfirm => 'تأكيد كلمة المرور الجديدة';

  @override
  String get changePasswordSaveButton => 'حفظ التغييرات';

  @override
  String get manageCategoriesTitle => 'إدارة الفئات';

  @override
  String get manageCategoriesEmptySubTitle =>
      'اضغط على زر \'+\' لإضافة أول فئة لك.';

  @override
  String get manageCategoriesEmptyTitle => 'لم يتم إنشاء فئات بعد.';

  @override
  String get manageCategoriesAddDialogTitle => 'إضافة فئة جديدة';

  @override
  String get manageCategoriesEditDialogTitle => 'تعديل الفئة';

  @override
  String get manageCategoriesSelect => 'تحديد';

  @override
  String get manageCategoriesSelectAll => 'تحديد الكل';

  @override
  String manageCategoriesSelected(int count) {
    return 'تم تحديد $count';
  }

  @override
  String dialogConfirmDeleteMulti(int count) {
    return 'هل أنت متأكد من رغبتك في حذف $count فئات؟ سيتم حذف جميع الحسابات الموجودة بداخلها أيضًا.';
  }

  @override
  String get manageCategoriesNameHint => 'اسم الفئة';

  @override
  String get dialogCancel => 'إلغاء';

  @override
  String get dialogCreate => 'إنشاء';

  @override
  String get dialogSave => 'حفظ';

  @override
  String get dialogDelete => 'حذف';

  @override
  String get dialogUnlock => 'فتح';

  @override
  String get dialogConfirmDeleteTitle => 'تأكيد الحذف';

  @override
  String get dialogConfirmDeleteAccount =>
      'هل أنت متأكد من رغبتك في حذف هذا الحساب؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get dialogConfirmDeleteCategory =>
      'هل أنت متأكد من رغبتك في حذف هذه الفئة؟ سيتم حذف جميع الحسابات الموجودة بداخلها أيضًا.';

  @override
  String get dialogConfirmDeleteAllDataTitle => 'هل أنت متأكد؟';

  @override
  String get dialogConfirmDeleteAllDataContent =>
      'سيؤدي هذا إلى حذف جميع حساباتك وفئاتك بشكل دائم. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get dialogDeleteForever => 'حذف نهائي';

  @override
  String get dialogUnlockVaultTitle => 'فتح الخزنة';

  @override
  String get dialogUnlockVaultSave =>
      'الرجاء إدخال كلمة المرور الرئيسية لحفظ هذا الحساب.';

  @override
  String get dialogUnlockVaultView =>
      'أدخل كلمة المرور الرئيسية الخاصة بك للكشف عن حساباتك المحفوظة لهذه الجلسة.';

  @override
  String get dialogUnlockToContinue =>
      'الرجاء إدخال كلمة المرور الرئيسية للمتابعة.';

  @override
  String get feedbackAccountCreated =>
      'تم إنشاء الحساب بنجاح! الرجاء تسجيل الدخول.';

  @override
  String get feedbackAccountSaved => 'تم حفظ الحساب';

  @override
  String get feedbackPasswordChanged => 'تم تغيير كلمة المرور بنجاح!';

  @override
  String feedbackImportSuccess(
    int successCount,
    int skippedCount,
    int failCount,
  ) {
    return 'اكتمل الاستيراد. تمت الإضافة: $successCount, تم التخطي (مكرر): $skippedCount, فشل: $failCount.';
  }

  @override
  String get feedbackExporting => 'جار التصدير...';

  @override
  String get feedbackImporting => 'جار الاستيراد...';

  @override
  String get validationEnterUsername => 'الرجاء إدخال اسم مستخدم';

  @override
  String get validationEnterPassword => 'الرجاء إدخال كلمة مرور';

  @override
  String get validationPasswordEmpty => 'لا يمكن أن تكون كلمة المرور فارغة';

  @override
  String get validationPasswordTooShort =>
      'يجب أن تكون كلمة المرور 8 أحرف على الأقل';

  @override
  String get validationPasswordRules => 'يجب أن تحتوي على أحرف وأرقام ورمز خاص';

  @override
  String get validationPasswordsNoMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get validationSelectService => 'الرجاء اختيار خدمة';

  @override
  String get validationEnterServiceName => 'الرجاء إدخال اسم';

  @override
  String get validationSelectCategory => 'الرجاء اختيار فئة';

  @override
  String get validationCategoryNameEmpty => 'لا يمكن أن يكون الاسم فارغًا';

  @override
  String get errorIncorrectPassword => 'كلمة المرور غير صحيحة';

  @override
  String get errorInvalidCredentials =>
      'اسم المستخدم أو كلمة المرور غير صالحة.';

  @override
  String get errorUsernameExists =>
      'اسم المستخدم موجود بالفعل. الرجاء اختيار اسم آخر.';

  @override
  String errorImportFailed(String error) {
    return 'فشل الاستيراد: $error';
  }

  @override
  String errorExportFailed(String error) {
    return 'فشل التصدير: $error';
  }

  @override
  String get errorSheetNotFound =>
      'لا يمكن العثور على صفحة باسم \'Accounts\' في ملف Excel.';

  @override
  String get errorUserNotLoggedIn => 'المستخدم لم يسجل دخوله.';

  @override
  String get errorGeneric => 'حدث خطأ ما.';

  @override
  String get categoryUncategorized => 'غير مصنف';

  @override
  String get importNoFileSelected => 'لم يتم اختيار ملف.';

  @override
  String get exportShareText => 'نسخة احتياطية لحسابات PassKeeper';

  @override
  String get excelHeaderCategory => 'الفئة';

  @override
  String get excelHeaderServiceName => 'اسم الخدمة';

  @override
  String get excelHeaderUsername => 'اسم المستخدم/البريد الإلكتروني';

  @override
  String get excelHeaderPassword => 'كلمة المرور';

  @override
  String get excelHeaderRecovery => 'حساب الاسترداد';

  @override
  String get excelHeaderPhone => 'أرقام الهواتف';

  @override
  String get dialogUnlockToExportTitle => 'فتح الخزنة للتصدير';

  @override
  String get dialogUnlockToExportContent =>
      'الرجاء إدخال كلمة المرور الرئيسية لتصدير حساباتك.';

  @override
  String get dialogUnlockToImportTitle => 'فتح الخزنة للإستيراد';

  @override
  String get dialogUnlockToImportContent =>
      'الرجاء إدخال كلمة المرور الرئيسية لإستيراد حساباتك.';

  @override
  String get biometricPromptReason => 'يرجى المصادقة للوصول إلى خزنتك';

  @override
  String get onboardingPage1Title => 'آمن وبدون انترنت';

  @override
  String get onboardingPage1Body =>
      'بياناتك مشفرة ومخزنة على جهازك فقط. أنت المتحكم الوحيد.';

  @override
  String get onboardingPage2Title => 'نظّم كل شيء';

  @override
  String get onboardingPage2Body =>
      'قسّم حساباتك إلى فئات مخصصة تقوم بإنشائها وإدارتها بنفسك.';

  @override
  String get onboardingPage3Title => 'النسخ الاحتياطي والاستعادة';

  @override
  String get onboardingPage3Body =>
      'قم بتصدير خزنتك بسهولة إلى ملف Excel واستوردها على أي جهاز. بياناتك تذهب معك أينما ذهبت.';

  @override
  String get onboardingSkipButton => 'تخطي';

  @override
  String get onboardingDoneButton => 'تم';

  @override
  String get aboutScreenTitle => 'حول تطبيق PassKeeper';

  @override
  String get aboutTitle => 'حول عنا / تواصل معنا';

  @override
  String get aboutScreenVersion => 'الإصدار 1.0.0';

  @override
  String get aboutScreenDescription =>
      'تحكّم بهويتك الرقمية. PassKeeper هو مدير كلمات مرور بسيط وآمن يعمل بالكامل بدون انترنت، ويوفر لك خزنة خاصة على جهازك. بياناتك تبقى معك، ولك وحدك.';

  @override
  String get aboutScreenContactTitle => 'تواصل معنا';

  @override
  String get aboutScreenContactEmail => 'البريد الإلكتروني';

  @override
  String get aboutScreenContactFacebook => 'فيسبوك';

  @override
  String get aboutScreenContactWhatsApp => 'واتساب';

  @override
  String get passwordGeneratorTitle => 'مولّد كلمات المرور';

  @override
  String get passwordGeneratorLength => 'الطول:';

  @override
  String get passwordGeneratorUppercase => 'أحرف كبيرة (A-Z)';

  @override
  String get passwordGeneratorNumbers => 'أرقام (0-9)';

  @override
  String get passwordGeneratorSymbols => 'رموز (!@#\$)';

  @override
  String get passwordGeneratorUseButton => 'استخدام كلمة المرور';

  @override
  String get passwordGeneratorWeak => 'ضعيفة';

  @override
  String get passwordGeneratorMedium => 'متوسطة';

  @override
  String get passwordGeneratorStrong => 'قوية';

  @override
  String get passwordGeneratorVeryStrong => 'قوية جداً';

  @override
  String get passwordGeneratorTooltip => 'إنشاء كلمة مرور';

  @override
  String get expandedTextShowLess => 'إظهار أقل';

  @override
  String get expandedTextShowMore => 'إظهار اكثر';

  @override
  String get dialogConfirmLogoutTitle => 'تأكيد تسجيل الخروج';

  @override
  String get dialogConfirmLogoutContent =>
      'هل أنت متأكد من رغبتك في تسجيل الخروج؟';

  @override
  String get dialogLogoutButton => 'تسجيل الخروج';

  @override
  String get deleteAccountScreenTitle => 'حذف الحساب';

  @override
  String get deleteAccountWarningTitle => 'هل أنت متأكد تماماً؟';

  @override
  String get deleteAccountWarningBody =>
      'لا يمكن التراجع عن هذا الإجراء. سيتم حذف جميع حساباتك وفئاتك وإعداداتك المحفوظة بشكل دائم. لا يمكننا استعادة هذه البيانات لك.';

  @override
  String get deleteAccountConfirmationPrompt =>
      'للتأكيد، الرجاء إدخال كلمة المرور الرئيسية الخاصة بك.';
}
