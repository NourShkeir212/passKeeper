import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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

  // Helper to get localizations without needing a context passed down
  AppLocalizations get _l10n {
    final context = NavigationService.navigatorKey.currentContext!;
    return AppLocalizations.of(context)!;
  }

  // --- PUBLIC METHODS ---

  /// Orchestrates the process of importing accounts from a user-selected Excel file.
  Future<String> importAccountsFromExcel(BuildContext context) async {
    try {
      final sheet = await _pickAndParseExcelSheet();
      if (sheet == null) {
        return AppLocalizations.of(context)!.importNoFileSelected;
      }

      final userId = await SessionManager.getUserId();
      if (userId == null) throw Exception(_l10n.errorUserNotLoggedIn);

      final categoryMap = await _getCategoryMap(userId);
      final results = await _processSheetRows(sheet, userId, categoryMap);

      return _l10n.feedbackImportSuccess(results['success']!, results['skipped']!, results['failed']!);
    } catch (e) {
      return _l10n.errorImportFailed(e.toString().replaceFirst("Exception: ", ""));
    }
  }

  /// Orchestrates the process of exporting user accounts to an Excel file and sharing it.
  Future<void> exportAccountsToExcel() async {
    final userId = await SessionManager.getUserId();
    if (userId == null) throw Exception(_l10n.errorUserNotLoggedIn);

    // Check if vault is unlocked before exporting
    if (!_encryptionService.isInitialized) {
      /// If the user hasn't unlocked the vault, we can't decrypt.
      /// We should prompt them for the password.
      final context = NavigationService.navigatorKey.currentContext!;
      final password = await showMasterPasswordDialog(
        context,
        title: AppLocalizations.of(context)!.dialogUnlockToExportTitle,
        content:AppLocalizations.of(context)!.dialogUnlockToExportContent,
      );
      if (password == null || password.isEmpty) return; // User cancelled

      final authCubit = context.read<AuthCubit>();
      final success = await authCubit.verifyMasterPassword(password);
      if (!success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_l10n.errorIncorrectPassword), backgroundColor: Colors.red),
          );
        }
        return; // Stop on failure
      }
    }
    final profileTag = SessionManager.currentSessionProfileTag;
    final accounts = await _databaseService.getAccounts(userId,profileTag);
    final categories = await _databaseService.getCategories(userId,profileTag);
    final categoryMap = {for (var cat in categories) cat.id: cat.name};

    final excel = Excel.createExcel();
    final Sheet sheet = excel['Accounts'];

    final List<String> headers = [
      _l10n.excelHeaderCategory, _l10n.excelHeaderServiceName,
      _l10n.excelHeaderUsername, _l10n.excelHeaderPassword,
      _l10n.excelHeaderRecovery, _l10n.excelHeaderPhone
    ];
    sheet.appendRow(headers.map((e) => TextCellValue(e)).toList());

    for (final account in accounts) {
      // Decrypt passwords before writing them to the Excel file.
      final decryptedPassword = _encryptionService.decryptText(account.password);

      final List<String> rowData = [
        categoryMap[account.categoryId] ?? 'N/A',
        account.serviceName,
        account.username,
        decryptedPassword, // Use the decrypted password
        account.recoveryAccount ?? '',
        account.phoneNumbers ?? '',
      ];
      sheet.appendRow(rowData.map((e) => TextCellValue(e)).toList());
    }
    final fileBytes = excel.encode();
    if (fileBytes != null) {
      final directory = await getTemporaryDirectory();
      final String filePath = '${directory.path}/PassKeeper_Backup_${DateTime.now().toIso8601String()}.xlsx';
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      await Share.shareXFiles([XFile(filePath)], text: _l10n.exportShareText);
    }
  }

  // --- PRIVATE HELPER METHODS for IMPORT ---

  Future<Sheet?> _pickAndParseExcelSheet() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx']);
    if (result == null || result.files.single.path == null) return null;

    final file = File(result.files.single.path!);
    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables['Accounts'];

    if (sheet == null) throw Exception(_l10n.errorSheetNotFound);
    return sheet;
  }

  Future<Map<String, int>> _getCategoryMap(int userId) async {
    final profileTag = SessionManager.currentSessionProfileTag;
    final existingCategories = await _databaseService.getCategories(userId,profileTag);
    return { for (var cat in existingCategories) cat.name.toLowerCase(): cat.id! };
  }

  Future<Map<String, int>> _processSheetRows(Sheet sheet, int userId, Map<String, int> categoryMap) async {
    int successCount = 0;
    int skippedCount = 0;
    int failCount = 0;

    for (var i = 1; i < sheet.maxRows; i++) {
      final row = sheet.row(i);
      try {
        final result = await _processAccountRow(row, userId, categoryMap);
        switch (result) {
          case _RowProcessResult.success:
            successCount++;
            break;
          case _RowProcessResult.skipped:
            skippedCount++;
            break;
          case _RowProcessResult.failed:
            failCount++;
            break;
        }
      } catch (e) {
        failCount++;
        print("Error processing row $i: $e");
      }
    }
    return {'success': successCount, 'skipped': skippedCount, 'failed': failCount};
  }

  Future<_RowProcessResult> _processAccountRow(List<Data?> row, int userId, Map<String, int> categoryMap) async {
    final categoryName = row.elementAtOrNull(0)?.value.toString() ?? '';
    final serviceName = row.elementAtOrNull(1)?.value.toString() ?? '';
    final username = row.elementAtOrNull(2)?.value.toString() ?? '';
    final password = row.elementAtOrNull(3)?.value.toString() ?? '';
    final recoveryAccount = row.elementAtOrNull(4)?.value.toString();
    final phoneNumbers = row.elementAtOrNull(5)?.value.toString();

    if (serviceName.isEmpty || username.isEmpty) {
      return _RowProcessResult.failed;
    }
    final profileTag = SessionManager.currentSessionProfileTag;
    final bool alreadyExists = await _databaseService.accountExists(
      profileTag: profileTag,
      userId: userId,
      serviceName: serviceName,
      username: username,
    );
    if (alreadyExists) {
      return _RowProcessResult.skipped;
    }

    final categoryId = await _findOrCreateCategory(userId, categoryName, categoryMap);

    // Encrypt the password from the Excel file before saving.
    final encryptedPassword = _encryptionService.encryptText(password);

    final newAccount = Account(
      profileTag: profileTag,
      userId: userId,
      categoryId: categoryId,
      serviceName: serviceName,
      username: username,
      password: encryptedPassword,
      recoveryAccount: recoveryAccount,
      phoneNumbers: phoneNumbers,
    );
    await _databaseService.insertAccount(newAccount);

    return _RowProcessResult.success;
  }

  Future<int> _findOrCreateCategory(int userId, String categoryName, Map<String, int> categoryMap) async {
    final name = categoryName.isEmpty ? _l10n.categoryUncategorized : categoryName;
    final lowerCaseName = name.toLowerCase();
    final profileTag = SessionManager.currentSessionProfileTag;
    if (categoryMap.containsKey(lowerCaseName)) {
      return categoryMap[lowerCaseName]!;
    } else {
      final newCategory = Category(userId: userId, name: name,profileTag: profileTag);
      final categoryId = await _databaseService.insertCategory(newCategory);
      categoryMap[lowerCaseName] = categoryId;
      return categoryId;
    }
  }
}

enum _RowProcessResult {
  success,
  skipped,
  failed,
}