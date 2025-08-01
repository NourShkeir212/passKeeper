import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'database_services.dart';
import 'session_manager.dart';

class ExportService {
  final DatabaseService _databaseService = DatabaseService();

  Future<void> exportAccountsToExcel() async {
    // 1. Fetch all necessary data from the database
    final userId = await SessionManager.getUserId();
    if (userId == null) throw Exception("User not logged in.");

    final accounts = await _databaseService.getAccounts(userId);
    final categories = await _databaseService.getCategories(userId);

    // Create a quick lookup map for category names
    final categoryMap = {for (var cat in categories) cat.id: cat.name};

    // 2. Create the Excel document in memory
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Accounts'];

    // 3. Add the header row
    final List<String> headers = [
      'Category',
      'Service Name',
      'Username/Email',
      'Password',
      'Recovery Account',
      'Phone Numbers'
    ];
    sheet.appendRow(headers.map((e) => TextCellValue(e)).toList());

    // 4. Add data rows for each account
    for (final account in accounts) {
      final List<String> rowData = [
        categoryMap[account.categoryId] ?? 'N/A', // Look up category name
        account.serviceName,
        account.username,
        account.password, // IMPORTANT: This exports passwords in plain text.
        account.recoveryAccount ?? '',
        account.phoneNumbers ?? '',
      ];
      sheet.appendRow(rowData.map((e) => TextCellValue(e)).toList());
    }

    // 5. Save the file to a temporary directory and share it
    final fileBytes = excel.encode();
    if (fileBytes != null) {
      final directory = await getTemporaryDirectory();
      final String filePath = '${directory.path}/PassKeeper_Backup_${DateTime.now().toIso8601String()}.xlsx';
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      // Use the share_plus package to open the native share dialog
      await Share.shareXFiles([XFile(filePath)], text: 'My PassKeeper Account Backup');
    }
  }
}