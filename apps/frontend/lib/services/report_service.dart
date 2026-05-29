import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportService {
  static Future<void> exportSeasonPDF({
    required String farmName,
    required int totalCrops,
    required int totalActivities,
    required double avgHealth,
    required int totalIrrigations,
    required int alertCount,
    required int lowStockCount,
    required BuildContext context,
  }) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFF22C55E),
                borderRadius: pw.BorderRadius.circular(8)),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
              pw.Text('تقرير الموسم الزراعي',
                  style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
              pw.SizedBox(height: 4),
              pw.Text(farmName.isNotEmpty ? farmName : 'مزرعتي',
                  style: pw.TextStyle(fontSize: 14, color: PdfColors.white)),
              pw.Text('تاريخ التقرير: ${DateTime.now().toIso8601String().split('T').first}',
                  style: pw.TextStyle(fontSize: 11, color: PdfColors.white)),
            ]),
          ),
          pw.SizedBox(height: 24),
          pw.Text('ملخص الموسم',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            children: [
              _row('المحاصيل النشطة', '$totalCrops'),
              _row('الأنشطة المسجلة', '$totalActivities'),
              _row('متوسط صحة المحاصيل', '${avgHealth.toStringAsFixed(1)}%'),
              _row('جلسات الري', '$totalIrrigations'),
              _row('إجمالي التنبيهات', '$alertCount'),
              _row('مخزون منخفض', '$lowStockCount'),
            ],
          ),
          pw.Spacer(),
          pw.Divider(color: PdfColors.grey300),
          pw.Text('تطبيق زراعتي • ${DateTime.now().year}',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey400)),
        ],
      ),
    ));

    final bytes = await pdf.save();
    await _share(bytes, 'season_report.pdf', 'application/pdf');
  }

  static Future<void> exportActivitiesCSV(
      List<Map<String, dynamic>> rows) async {
    final buf = StringBuffer();
    buf.writeln('التاريخ,النوع,الوصف,الحقل,المحصول');
    for (final r in rows) {
      final date  = (r['date'] as String? ?? '').split('T').first;
      final type  = r['type'] as String? ?? '';
      final desc  = (r['description'] as String? ?? '').replaceAll(',', '،');
      final field = (r['field'] as Map?)?['name'] as String? ?? '';
      final crop  = (r['crop'] as Map?)?['name'] as String? ?? '';
      buf.writeln('$date,$type,$desc,$field,$crop');
    }
    final bytes = buf.toString().codeUnits;
    await _share(bytes, 'activities_export.csv', 'text/csv');
  }

  static pw.TableRow _row(String label, String value) => pw.TableRow(children: [
    pw.Padding(padding: const pw.EdgeInsets.all(8),
        child: pw.Text(value, textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
    pw.Padding(padding: const pw.EdgeInsets.all(8),
        child: pw.Text(label, textAlign: pw.TextAlign.right)),
  ]);

  static Future<void> _share(List<int> bytes, String filename, String mime) async {
    final dir  = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(Uint8List.fromList(bytes));
    await Share.shareXFiles([XFile(file.path, mimeType: mime)], subject: filename);
  }
}
