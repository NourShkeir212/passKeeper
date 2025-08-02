import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:secure_accounts/core/services/session_manager.dart';
import 'package:share_plus/share_plus.dart';

import '../../model/account_model.dart';
import '../../model/category_model.dart';
import 'database_services.dart';

class ExcelService {
  final DatabaseService _databaseService = DatabaseService();

  // --- PUBLIC METHODS ---

  /// Orchestrates the process of importing accounts from a user-selected Excel file.
  ///
  /// Returns a user-friendly status message summarizing the import results.
  Future<String> importAccountsFromExcel() async {
    try {
      final sheet = await _pickAndParseExcelSheet();
      if (sheet == null) {
        return "No file selected or 'Accounts' sheet not found.";
      }

      final userId = await SessionManager.getUserId();
      if (userId == null) throw Exception("User is not logged in.");

      final categoryMap = await _getCategoryMap(userId);
      final results = await _processSheetRows(sheet, userId, categoryMap);

      return "Import complete. Added: ${results['success']}, Skipped: ${results['skipped']}, Failed: ${results['failed']}.";
    } catch (e) {
      print("Import failed: $e");
      return "Import failed: ${e.toString().replaceFirst("Exception: ", "")}";
    }
  }

  /// Orchestrates the process of exporting user accounts to an Excel file and sharing it.
  Future<void> exportAccountsToExcel() async {
    final userId = await SessionManager.getUserId();
    if (userId == null) throw Exception("User not logged in.");

    final accounts = await _databaseService.getAccounts(userId);
    final categories = await _databaseService.getCategories(userId);
    final categoryMap = {for (var cat in categories) cat.id: cat.name};

    final excel = Excel.createExcel();
    final Sheet sheet = excel['Accounts'];

    final List<String> headers = [
      'Category',
      'Service Name',
      'Username/Email',
      'Password',
      'Recovery Account',
      'Phone Numbers'
    ];
    sheet.appendRow(headers.map((e) => TextCellValue(e)).toList());

    for (final account in accounts) {
      final List<String> rowData = [
        categoryMap[account.categoryId] ?? 'N/A',
        account.serviceName,
        account.username,
        account.password,
        account.recoveryAccount ?? '',
        account.phoneNumbers ?? '',
      ];
      sheet.appendRow(rowData.map((e) => TextCellValue(e)).toList());
    }

    final fileBytes = excel.encode();
    if (fileBytes != null) {
      final directory = await getTemporaryDirectory();
      final String filePath =
          '${directory.path}/PassKeeper_Backup_${DateTime.now().toIso8601String()}.xlsx';
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      await Share.shareXFiles([XFile(filePath)],
          text: 'My PassKeeper Account Backup');
    }
  }

  // --- PRIVATE HELPER METHODS for IMPORT ---

  /// Handles file picking and parsing, returning the 'Accounts' sheet.
  Future<Sheet?> _pickAndParseExcelSheet() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null || result.files.single.path == null) {
      return null;
    }

    final file = File(result.files.single.path!);
    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    return excel.tables['Accounts'];
  }

  /// Fetches existing categories for a user and prepares a name-to-ID lookup map.
  Future<Map<String, int>> _getCategoryMap(int userId) async {
    final existingCategories = await _databaseService.getCategories(userId);
    return {
      for (var cat in existingCategories) cat.name.toLowerCase(): cat.id!
    };
  }

  /// Iterates through the sheet rows and processes each one, returning a summary.
  Future<Map<String, int>> _processSheetRows(
      Sheet sheet, int userId, Map<String, int> categoryMap) async {
    int successCount = 0;
    int skippedCount = 0;
    int failCount = 0;

    // Start from 1 to skip the header row
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
    return {
      'success': successCount,
      'skipped': skippedCount,
      'failed': failCount
    };
  }

  /// Processes a single row from the Excel file, including validation, duplicate checking,
  /// category handling, and insertion.
  Future<_RowProcessResult> _processAccountRow(
      List<Data?> row, int userId, Map<String, int> categoryMap) async {
    final categoryName = row.elementAtOrNull(0)?.value.toString() ?? '';
    final serviceName = row.elementAtOrNull(1)?.value.toString() ?? '';
    final username = row.elementAtOrNull(2)?.value.toString() ?? '';
    final password = row.elementAtOrNull(3)?.value.toString() ?? '';
    final recoveryAccount = row.elementAtOrNull(4)?.value.toString();
    final phoneNumbers = row.elementAtOrNull(5)?.value.toString();

    if (serviceName.isEmpty || username.isEmpty) {
      return _RowProcessResult.failed;
    }

    final bool alreadyExists = await _databaseService.accountExists(
      userId: userId,
      serviceName: serviceName,
      username: username,
    );
    if (alreadyExists) {
      return _RowProcessResult.skipped;
    }

    final categoryId =
    await _findOrCreateCategory(userId, categoryName, categoryMap);

    final newAccount = Account(
      userId: userId,
      categoryId: categoryId,
      serviceName: serviceName,
      username: username,
      password: password,
      recoveryAccount: recoveryAccount,
      phoneNumbers: phoneNumbers,
    );
    await _databaseService.insertAccount(newAccount);

    return _RowProcessResult.success;
  }

  /// Finds an existing category by name or creates a new one if it doesn't exist.
  Future<int> _findOrCreateCategory(
      int userId, String categoryName, Map<String, int> categoryMap) async {
    final name = categoryName.isEmpty ? "Uncategorized" : categoryName;
    final lowerCaseName = name.toLowerCase();

    if (categoryMap.containsKey(lowerCaseName)) {
      return categoryMap[lowerCaseName]!;
    } else {
      final newCategory = Category(userId: userId, name: name);
      final categoryId = await _databaseService.insertCategory(newCategory);
      categoryMap[lowerCaseName] = categoryId; // Update map for subsequent rows
      return categoryId;
    }
  }
}

/// Enum to represent the outcome of processing a single row.
enum _RowProcessResult {
  success,
  skipped,
  failed,
}