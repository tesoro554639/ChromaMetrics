import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

class CsvExporter {
  /// Exports rows of data to CSV file and triggers browser download in Flutter Web
  static void exportToCsv({
    required String filename,
    required List<List<dynamic>> rows,
  }) {
    final String csvContent = const ListToCsvConverter().convert(rows);

    if (kIsWeb) {
      final bytes = html.Blob([csvContent], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(bytes);
      html.AnchorElement(href: url)
        ..setAttribute('download', '$filename.csv')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      debugPrint('Exporting CSV outside web environment: $csvContent');
    }
  }
}
