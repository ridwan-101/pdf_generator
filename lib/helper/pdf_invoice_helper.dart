import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf_generator/helper/pdf_helper.dart';
import 'package:pdf_generator/model/customer.dart';
import 'package:pdf_generator/model/invoice.dart';
import 'package:pdf_generator/model/supplier.dart';
import 'package:pdf_generator/utlis.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:pdf_generator/utlis.dart';

class PdfInvoicePdfHelper {
  static Future<File> generate(Invoice invoice) async {
    final pdf = pw.Document();
    final font = await rootBundle.load("assets/open-sans.ttf");
    final ttf = pw.Font.ttf(font);

    pdf.addPage(pw.MultiPage(
      build: (context) => [
        // pw.Text('Rdiwan', style: pw.TextStyle(font: ttf)),
        buildHeader(invoice, ttf),
        pw.SizedBox(height: 3 * PdfPageFormat.cm),
        buildTitle(invoice, ttf),
        buildInvoice(invoice, ttf),
        pw.Divider(),
        buildTotal(invoice, ttf),
      ],
      footer: (context) => buildFooter(invoice),
    ));

    return PdfHelper.saveDocument(name: 'my_invoice.pdf', pdf: pdf);
  }

  static pw.Widget buildHeader(Invoice invoice, pw.Font ttf) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 1 * PdfPageFormat.cm),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              buildSupplierAddress(invoice.supplier, ttf),
              pw.Container(
                height: 50,
                width: 50,
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: invoice.info.number,
                ),
              ),
            ],
          ),
          // pw.SizedBox(height: 1 * PdfPageFormat.cm),
          // pw.Row(
          //   crossAxisAlignment: pw.CrossAxisAlignment.end,
          //   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          //   children: [
          //     buildCustomerAddress(invoice.customer, ttf),
          //     buildInvoiceInfo(invoice.info, ttf),
          //   ],
          // ),
        ],
      );

  static pw.Widget buildCustomerAddress(Customer customer, pw.Font ttf) =>
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(customer.name,
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 20)),
          pw.Text(customer.address),
        ],
      );

  static pw.Widget buildInvoiceInfo(InvoiceInfo info, pw.Font tff) {
    final paymentTerms = '${info.dueDate.difference(info.date).inDays} days';
    final titles = <String>[
      'Invoice Number:',
      'Invoice Date:',
      'Payment Terms:',
      'Due Date:'
    ];
    final data = <String>[
      info.number,
      // Utils.formatDate(info.date),
      paymentTerms,
      // Utils.formatDate(info.dueDate),
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: List.generate(titles.length, (index) {
        final title = titles[index];
        final value = data[index];

        return buildText(title: title, value: value, width: 200);
      }),
    );
  }

  static pw.Widget buildSupplierAddress(Supplier supplier, pw.Font ttf) =>
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(supplier.name,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttf)),
          pw.SizedBox(height: 1 * PdfPageFormat.mm),
          pw.Text(supplier.address),
        ],
      );

  static pw.Widget buildTitle(Invoice invoice, pw.Font ttf) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'First PDF',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 0.8 * PdfPageFormat.cm),
          pw.Text(invoice.info.description),
          pw.SizedBox(height: 0.8 * PdfPageFormat.cm),
        ],
      );

  static pw.Widget buildInvoice(Invoice invoice, pw.Font ttf) {
    final headers = [
      'Description',
      'Date',
      'Quantity',
      'Unit Price',
      'VAT',
      'Total'
    ];
    final data = invoice.items.map((item) {
      final total = item.unitPrice * item.quantity * (1 + item.vat);

      return [
        item.description,
        // Utils.formatDate(item.date),
        '${item.quantity}',
        '\$ ${item.unitPrice}',
        '${item.vat} %',
        '\$ ${total.toStringAsFixed(2)}',
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget buildTotal(Invoice invoice, pw.Font ttf) {
    final netTotal = invoice.items
        .map((item) => item.unitPrice * item.quantity)
        .reduce((item1, item2) => item1 + item2);
    final vatPercent = invoice.items.first.vat;
    final vat = netTotal * vatPercent;
    final total = netTotal + vat;

    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Row(
        children: [
          pw.Spacer(flex: 6),
          pw.Expanded(
            flex: 4,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                buildText(
                  title: 'Net total',
                  value: Utils.formatPrice(netTotal),
                  unite: true,
                ),
                buildText(
                  title: 'Vat ${vatPercent * 100} %',
                  value: Utils.formatPrice(vat),
                  unite: true,
                ),
                pw.Divider(),
                buildText(
                  title: 'Total amount due',
                  titleStyle: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  value: Utils.formatPrice(total),
                  unite: true,
                ),
                pw.SizedBox(height: 2 * PdfPageFormat.mm),
                pw.Container(height: 1, color: PdfColors.grey400),
                pw.SizedBox(height: 0.5 * PdfPageFormat.mm),
                pw.Container(height: 1, color: PdfColors.grey400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget buildFooter(Invoice invoice) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Divider(),
          pw.SizedBox(height: 2 * PdfPageFormat.mm),
          buildSimpleText(title: 'Address', value: invoice.supplier.address),
          pw.SizedBox(height: 1 * PdfPageFormat.mm),
          buildSimpleText(title: 'Paypal', value: invoice.supplier.paymentInfo),
        ],
      );

  static buildSimpleText({
    required String title,
    required String value,
  }) {
    final style = pw.TextStyle(fontWeight: pw.FontWeight.bold);

    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(title, style: style),
        pw.SizedBox(width: 2 * PdfPageFormat.mm),
        pw.Text(value),
      ],
    );
  }

  static buildText({
    required String title,
    required String value,
    double width = double.infinity,
    pw.TextStyle? titleStyle,
    bool unite = false,
  }) {
    final style = titleStyle ?? pw.TextStyle(fontWeight: pw.FontWeight.bold);

    return pw.Container(
      width: width,
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Text(title, style: style)),
          pw.Text(value, style: unite ? style : null),
        ],
      ),
    );
  }
}
