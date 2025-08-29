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

  // A simple helper to avoid passing context everywhere.
  AppLocalizations get _l10n =>
      AppLocalizations.of(NavigationService.navigatorKey.currentContext!)!;

  //============================================================================
  //== EXPORT ACCOUNTS
  //============================================================================

  /// Orchestrates exporting accounts to an Excel file.
  Future<String> exportAccounts() async {
    final userId = SessionManager.currentVaultUserId;
    if (userId == null) throw Exception(_l10n.errorUserNotLoggedIn);

    // 1. Ensure encryption is ready, prompting for password if needed.
    final isReady = await _ensureEncryptionServiceIsReady();
    if (!isReady) return _l10n.exportCancelled;

    // 2. Fetch and prepare all necessary data.
    final exportData = await _prepareExportData(userId);

    // 3. Build the Excel file in memory.
    final excel = _buildExcelFile(exportData);

    // 4. Save the file to disk and trigger the share dialog.
    await _saveAndShareFile(excel.encode());

    return _l10n.exportSuccess;
  }

  /// Job: Prompts for master password if the encryption service isn't initialized.
  Future<bool> _ensureEncryptionServiceIsReady() async {
    if (_encryptionService.isInitialized) return true;

    final context = NavigationService.navigatorKey.currentContext!;
    final password = await showMasterPasswordDialog(
      context,
      title: _l10n.dialogUnlockToExportTitle,
      content: _l10n.dialogUnlockToExportContent,
    );

    if (password == null || password.isEmpty) return false;

    final success = await context.read<AuthCubit>().verifyMasterPassword(
        password);
    if (!success) throw Exception(_l10n.errorIncorrectPassword);

    return true;
  }

  /// Job: Fetches accounts and categories from the database for exporting.
  Future<({List<Account> accounts, Map<int,
      String> categoryMap})> _prepareExportData(int userId) async {
    final profileTag = SessionManager.currentSessionProfileTag;
    final accounts = await _databaseService.getAccounts(userId, profileTag);
    final categories = await _databaseService.getCategories(userId, profileTag);
    final categoryMap = {for (var cat in categories) cat.id!: cat.name};
    return (accounts: accounts, categoryMap: categoryMap);
  }

  /// Job: Creates the Excel object and populates it with account data.
  Excel _buildExcelFile(
      ({List<Account> accounts, Map<int, String> categoryMap}) data) {
    final excel = Excel.createExcel();
    final sheet = excel['Accounts'];

    // Add Headers
    final headers = [
      _l10n.excelHeaderCategory, _l10n.excelHeaderServiceName,
      _l10n.excelHeaderUsername, _l10n.excelHeaderPassword,
      _l10n.excelHeaderRecovery, _l10n.excelHeaderPhone,
      _l10n.notes,
      _l10n.excelHeaderCustomFields,
    ];
    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    // Add Account Rows
    for (final account in data.accounts) {
      final rowData = [
        data.categoryMap[account.categoryId] ?? 'N/A',
        account.serviceName,
        account.username,
        _encryptionService.decryptText(account.password),
        account.recoveryAccount ?? '',
        account.phoneNumbers ?? '',
        jsonEncode(account.customFields),
        account.notes ?? ''
      ];
      sheet.appendRow(rowData.map((cell) => TextCellValue(cell)).toList());
    }
    return excel;
  }

  /// Job: Encodes the Excel file, saves it to a temporary directory, and shares it.
  Future<void> _saveAndShareFile(List<int>? fileBytes) async {
    if (fileBytes == null) return;

    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/PassKeeper_Backup_${DateTime
        .now()
        .toIso8601String()}.xlsx';
    await File(filePath).writeAsBytes(fileBytes);
    await Share.shareXFiles([XFile(filePath)], text: _l10n.exportShareText);
  }


  //============================================================================
  //== IMPORT ACCOUNTS
  //============================================================================

  /// Orchestrates importing accounts from an Excel file.
  Future<String> importAccounts() async {
    try {
      // 1. Let the user pick a file and perform initial parsing/validation.
      final sheet = await _pickAndParseExcelSheet();
      if (sheet == null) return _l10n.importNoFileSelected;

      // 2. Get session data and prepare for the import.
      final userId = SessionManager.currentVaultUserId;
      if (userId == null) throw Exception(_l10n.errorUserNotLoggedIn);
      final profileTag = SessionManager.currentSessionProfileTag;
      final categoryMap = await _getCategoryMap(userId, profileTag);

      // 3. Process all rows and get the results.
      final result = await _processSheetRows(
          sheet, userId, profileTag, categoryMap);

      return _l10n.feedbackImportSuccess(
          result.success, result.skipped, result.failed);
    } catch (e) {
      return _l10n.errorImportFailed(
          e.toString().replaceFirst("Exception: ", ""));
    }
  }

  /// Job: Iterates over sheet rows, delegates processing, and tracks results.
  Future<({int success, int skipped, int failed})> _processSheetRows(
      Sheet sheet, int userId, String profileTag,
      Map<String, int> categoryMap) async {
    int success = 0,
        skipped = 0,
        failed = 0;

    for (var i = 1; i < sheet.maxRows; i++) {
      try {
        final row = sheet.row(i);
        final rowData = _parseRowData(row);

        if (rowData.serviceName.isEmpty || rowData.username.isEmpty) {
          failed++;
          continue;
        }

        final bool alreadyExists = await _databaseService.accountExists(
          userId: userId,
          serviceName: rowData.serviceName,
          username: rowData.username,
          profileTag: profileTag,
        );

        if (alreadyExists) {
          skipped++;
          continue;
        }

        final newAccount = await _buildAccountFromRowData(
            rowData, userId, profileTag, categoryMap);
        await _databaseService.insertAccount(newAccount);
        success++;
      } catch (e) {
        failed++;
        print("Error processing row $i: $e");
      }
    }
    return (success: success, skipped: skipped, failed: failed);
  }

  /// Job: Converts a list of Excel cells into a structured record.
  ({String category, String serviceName, String username, String password, String? recovery, String? phone, String? customJson, String? note}) _parseRowData(
      List<Data?> row) {
    return (
    category: row
        .elementAtOrNull(0)
        ?.value
        .toString() ?? '',
    serviceName: row
        .elementAtOrNull(1)
        ?.value
        .toString() ?? '',
    username: row
        .elementAtOrNull(2)
        ?.value
        .toString() ?? '',
    password: row
        .elementAtOrNull(3)
        ?.value
        .toString() ?? '',
    recovery: row
        .elementAtOrNull(4)
        ?.value
        .toString(),
    phone: row
        .elementAtOrNull(5)
        ?.value
        .toString(),
    customJson: row
        .elementAtOrNull(6)
        ?.value
        .toString(),
    note: row
        .elementAtOrNull(7)
        ?.value
        .toString(),
    );
  }

  /// Job: Transforms parsed row data into a final `Account` object.
  Future<Account> _buildAccountFromRowData(
      ({String category, String serviceName, String username, String password, String? recovery, String? phone, String? customJson, String ?note}) rowData,
      int userId,
      String profileTag,
      Map<String, int> categoryMap,) async {
    final categoryId = await _findOrCreateCategory(
        userId, rowData.category, profileTag, categoryMap);

    Map<String, String> customFields = {};
    if (rowData.customJson != null && rowData.customJson!.isNotEmpty) {
      try {
        customFields =
        Map<String, String>.from(jsonDecode(rowData.customJson!));
      } catch (e) {
        print("Could not parse custom fields for ${rowData.serviceName}: $e");
      }
    }

    return Account(
      userId: userId,
      categoryId: categoryId,
      serviceName: rowData.serviceName,
      username: rowData.username,
      password: _encryptionService.encryptText(rowData.password),
      recoveryAccount: rowData.recovery,
      phoneNumbers: rowData.phone,
      customFields: customFields,
      notes: rowData.note,
      profileTag: profileTag,
    );
  }

  // --- COMMON AND IMPORT-SPECIFIC HELPERS ---

  /// Job: Prompts user to pick a file and parses it into an Excel Sheet object.
  Future<Sheet?> _pickAndParseExcelSheet() async {
    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['xlsx']);
    if (result?.files.single.path == null) return null;

    final bytes = await File(result!.files.single.path!).readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables['Accounts'];

    if (sheet == null) throw Exception(_l10n.errorSheetNotFound);
    if (sheet.maxRows == 0 || sheet
        .row(0)
        .length < 6) {
      throw Exception(
          "Invalid Excel format. Header row must contain at least 6 columns.");
    }

    return sheet;
  }

  /// Job: Fetches existing categories and maps their lowercase names to IDs.
  Future<Map<String, int>> _getCategoryMap(int userId,
      String profileTag) async {
    final categories = await _databaseService.getCategories(userId, profileTag);
    return {for (var cat in categories) cat.name.toLowerCase(): cat.id!};
  }

  /// Job: Finds a category ID from the map or creates a new one if it doesn't exist.
  Future<int> _findOrCreateCategory(int userId, String categoryName,
      String profileTag, Map<String, int> categoryMap) async {
    final name = categoryName.isEmpty
        ? _l10n.categoryUncategorized
        : categoryName;
    final lowerCaseName = name.toLowerCase();

    if (categoryMap.containsKey(lowerCaseName)) {
      return categoryMap[lowerCaseName]!;
    }

    final newCategory = Category(
        userId: userId, name: name, profileTag: profileTag);
    final categoryId = await _databaseService.insertCategory(newCategory);
    categoryMap[lowerCaseName] = categoryId; // Update map for subsequent rows
    return categoryId;
  }
}