import 'dart:io';

import 'package:bang_soil/services/database_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CsvExportService {
  static const List<String> _columns = [
    'id', 'created_at',
    'nm410', 'nm435', 'nm460', 'nm485', 'nm510', 'nm535',
    'nm560', 'nm585', 'nm610', 'nm645', 'nm680', 'nm705',
    'nm730', 'nm760', 'nm810', 'nm860', 'nm900', 'nm940',
    'as72651_temp', 'as72652_temp', 'as72653_temp',
  ];

  Future<void> exportToCSV() async {
    final rows = await DatabaseService.instance.getAllReadings();

    if (rows.isEmpty) {
      throw Exception('Tidak ada data untuk diekspor');
    }

    final buffer = StringBuffer();
    buffer.writeln(_columns.join(','));

    for (final row in rows) {
      final values = _columns.map((col) {
        final val = row[col];
        if (val == null) return '';
        final str = val.toString();
        if (str.contains(',') || str.contains('"') || str.contains('\n')) {
          return '"${str.replaceAll('"', '""')}"';
        }
        return str;
      });
      buffer.writeln(values.join(','));
    }

    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-')
        .substring(0, 19);
    final file = File('${dir.path}/soil_bang_$timestamp.csv');
    await file.writeAsString(buffer.toString());

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/csv')],
        subject: 'SOIL-BANG Sensor Export $timestamp',
      ),
    );
  }
}
