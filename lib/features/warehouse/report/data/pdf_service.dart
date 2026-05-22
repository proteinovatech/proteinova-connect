import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {

  static Future<void> generatePdf({
    required String title,
    required List<List<String>> tableData,
  }) async {

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            children: [

              pw.Text(
                title,
                style: pw.TextStyle(fontSize: 24),
              ),

              pw.SizedBox(height: 20),

              pw.TableHelper.fromTextArray(
                data: tableData,
              ),
            ],
          );
        },
      ),
    );

    final dir =
        await getApplicationDocumentsDirectory();

    final file = File(
      "${dir.path}/$title.pdf",
    );

    await file.writeAsBytes(
      await pdf.save(),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}