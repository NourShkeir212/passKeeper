import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../features/auth/cubit/auth_cubit/cubit.dart';
import '../../l10n/app_localizations.dart';
import '../../model/account_model.dart';
import '../../model/category_model.dart';
import '../widgets/master_password_dialog.dart';
import 'database_services.dart';
import 'encryption_service.dart';
import 'navigation_service.dart';
import 'session_manager.dart';

class ExcelService {
  final DatabaseService _databaseService = DatabaseService();
  final EncryptionService _encryptionService = EncryptionService();

  /// Helper to get localizations without needing a context passed down.
  AppLocalizations get _l10n {
    final context = NavigationService.navigatorKey.currentContext!;
    return AppLocalizations.of(context)!;
  }

  /// Exports accounts to an Excel file and opens a "Save As" dialog.
  Future<String> exportAccountsToExcel() async {
    final userId = SessionManager.currentVaultUserId;
    if (userId == null) throw Exception(_l10n.errorUserNotLoggedIn);

    if (!_encryptionService.isInitialized) {
      final context = NavigationService.navigatorKey.currentContext!;
      final password = await showMasterPasswordDialog(
        context,
        title: _l10n.dialogUnlockToExportTitle,
        content: _l10n.dialogUnlockToExportContent,
      );
      if (password == null || password.isEmpty) return "Export cancelled.";

      final authCubit = context.read<AuthCubit>();
      final success = await authCubit.verifyMasterPassword(password);
      if (!success) {
        throw Exception(_l10n.errorIncorrectPassword);
      }
    }

    final profileTag = SessionManager.currentSessionProfileTag;
    final accounts = await _databaseService.getAccounts(userId, profileTag);
    final categories = await _databaseService.getCategories(userId, profileTag);
    final categoryMap = {for (var cat in categories) cat.id: cat.name};

    final excel = Excel.createExcel();
    final Sheet sheet = excel['Accounts'];

    final List<String> headers = [
      _l10n.excelHeaderCategory, _l10n.excelHeaderServiceName,
      _l10n.excelHeaderUsername, _l10n.excelHeaderPassword,
      _l10n.excelHeaderRecovery, _l10n.excelHeaderPhone,
      _l10n.excelHeaderCustomFields,
    ];
    sheet.appendRow(headers.map((e) => TextCellValue(e)).toList());

    for (final account in accounts) {
      final decryptedPassword = _encryptionService.decryptText(
          account.password);
      final List<String> rowData = [
        categoryMap[account.categoryId] ?? 'N/A',
        account.serviceName, account.username, decryptedPassword,
        account.recoveryAccount ?? '', account.phoneNumbers ?? '',
        jsonEncode(account.customFields),
      ];
      sheet.appendRow(rowData.map((e) => TextCellValue(e)).toList());
    }

    final fileBytes = excel.encode();
    if (fileBytes != null) {
      final directory = await getTemporaryDirectory();
      final String filePath = '${directory.path}/PassKeeper_Backup_${DateTime
          .now().toIso8601String()}.xlsx';
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      await Share.shareXFiles([XFile(filePath)], text: _l10n.exportShareText);
    }
    return "Export successful!"; // TODO: Localize
  }

  /// Orchestrates the process of importing accounts from a user-selected Excel file.
  Future<String> importAccountsFromExcel() async {
    try {
      final sheet = await _pickAndParseExcelSheet();
      if (sheet == null) {
        return _l10n.importNoFileSelected;
      }

      final headers = sheet
          .row(0)
          .map((cell) => cell?.value.toString() ?? '')
          .toList();
      if (headers.length < 6) throw Exception("Invalid Excel format.");

      final standardHeaderCount = 6;
      final customFieldHeaderKeys = headers.sublist(standardHeaderCount);

      final userId = SessionManager.currentVaultUserId;
      if (userId == null) throw Exception(_l10n.errorUserNotLoggedIn);
      final profileTag = SessionManager.currentSessionProfileTag;

      final categoryMap = await _getCategoryMap(userId, profileTag);
      int successCount = 0;
      int skippedCount = 0;
      int failCount = 0;

      for (var i = 1; i < sheet.maxRows; i++) {
        final row = sheet.row(i);
        try {
          final categoryName = row
              .elementAtOrNull(0)
              ?.value
              .toString() ?? '';
          final serviceName = row
              .elementAtOrNull(1)
              ?.value
              .toString() ?? '';
          final username = row
              .elementAtOrNull(2)
              ?.value
              .toString() ?? '';
          final password = row
              .elementAtOrNull(3)
              ?.value
              .toString() ?? '';
          final recoveryAccount = row
              .elementAtOrNull(4)
              ?.value
              .toString();
          final phoneNumbers = row
              .elementAtOrNull(5)
              ?.value
              .toString();

          if (serviceName.isEmpty || username.isEmpty) {
            failCount++;
            continue;
          }

          final bool alreadyExists = await _databaseService.accountExists(
            userId: userId, serviceName: serviceName,
            username: username, profileTag: profileTag,
          );
          if (alreadyExists) {
            skippedCount++;
            continue;
          }

          Map<String, String> customFields = {};
          final customFieldsJson = row
              .elementAtOrNull(6)
              ?.value
              .toString();
          if (customFieldsJson != null && customFieldsJson.isNotEmpty) {
            try {
              customFields =
              Map<String, String>.from(jsonDecode(customFieldsJson));
            } catch (e) {
              print("Could not parse custom fields for row $i: $e");
            }
          }

          final categoryId = await _findOrCreateCategory(
              userId, categoryName, profileTag, categoryMap);
          final encryptedPassword = _encryptionService.encryptText(password);

          final newAccount = Account(
            userId: userId,
            categoryId: categoryId,
            serviceName: serviceName,
            username: username,
            password: encryptedPassword,
            recoveryAccount: recoveryAccount,
            phoneNumbers: phoneNumbers,
            customFields: customFields,
            profileTag: profileTag,
          );
          await _databaseService.insertAccount(newAccount);
          successCount++;
        } catch (e) {
          failCount++;
          print("Error processing row $i: $e");
        }
      }
      return _l10n.feedbackImportSuccess(successCount, skippedCount, failCount);
    } catch (e) {
      return _l10n.errorImportFailed(
          e.toString().replaceFirst("Exception: ", ""));
    }
  }

  // --- PRIVATE HELPER METHODS ---

  Future<Sheet?> _pickAndParseExcelSheet() async {
    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['xlsx']);
    if (result == null || result.files.single.path == null) return null;
    final file = File(result.files.single.path!);
    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables['Accounts'];
    if (sheet == null) throw Exception(_l10n.errorSheetNotFound);
    return sheet;
  }

  Future<Map<String, int>> _getCategoryMap(int userId,
      String profileTag) async {
    final existingCategories = await _databaseService.getCategories(
        userId, profileTag);
    return {
      for (var cat in existingCategories) cat.name.toLowerCase(): cat.id!
    };
  }

  Future<int> _findOrCreateCategory(int userId, String categoryName,
      String profileTag, Map<String, int> categoryMap) async {
    final name = categoryName.isEmpty
        ? _l10n.categoryUncategorized
        : categoryName;
    final lowerCaseName = name.toLowerCase();
    if (categoryMap.containsKey(lowerCaseName)) {
      return categoryMap[lowerCaseName]!;
    } else {
      final newCategory = Category(
          userId: userId, name: name, profileTag: profileTag);
      final categoryId = await _databaseService.insertCategory(newCategory);
      categoryMap[lowerCaseName] = categoryId;
      return categoryId;
    }
  }
}