import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

class CsvExporter {
  /// Exports rows of data to CSV file and triggers browser download in Flutter Web.
  /// Includes UTF-8 BOM (\uFEFF) for compatibility with Microsoft Excel and spreadsheet tools.
  static void exportToCsv({
    required String filename,
    required List<List<dynamic>> rows,
  }) {
    final String rawCsvContent = const ListToCsvConverter().convert(rows);
    // Add UTF-8 Byte Order Mark (BOM) to ensure spreadsheet software like MS Excel
    // decodes UTF-8 characters and symbols properly.
    final String csvContent = '\uFEFF$rawCsvContent';

    final cleanFilename = filename.toLowerCase().endsWith('.csv')
        ? filename
        : '$filename.csv';

    if (kIsWeb) {
      final bytes = html.Blob([csvContent], 'text/csv;charset=utf-8');
      final url = html.Url.createObjectUrlFromBlob(bytes);
      html.AnchorElement(href: url)
        ..setAttribute('download', cleanFilename)
        ..click();
      // Revoke the object URL after a short delay to allow browser download initiation
      Future.delayed(const Duration(seconds: 2), () {
        html.Url.revokeObjectUrl(url);
      });
    } else {
      debugPrint('Exporting CSV outside web environment ($cleanFilename): $csvContent');
    }
  }
}
