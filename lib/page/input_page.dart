import 'package:flutter/material.dart';
import 'package:pdf_generator/model/supplier.dart';
import 'package:pdf_generator/page/pdf_page.dart';
import 'package:pdf_generator/widget/button_widget.dart';

class InvoiceInput extends StatefulWidget {
  const InvoiceInput({super.key});

  @override
  State<InvoiceInput> createState() => _InvoiceInputState();
}

class _InvoiceInputState extends State<InvoiceInput> {
  late TextEditingController controller1;
  late TextEditingController controller2;
  late TextEditingController controller3;

  @override
  void initState() {
    super.initState();
    controller1 = TextEditingController();
    controller2 = TextEditingController();
    controller3 = TextEditingController();
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example'),
      ),
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(hintText: 'Name'),
            controller: controller1,
          ),
          TextField(
            controller: controller2,
            decoration: const InputDecoration(hintText: 'Address'),
          ),
          TextField(
            controller: controller3,
            decoration: const InputDecoration(hintText: 'Personal Info'),
          ),
          const SizedBox(
            height: 20,
          ),
          ButtonWidget(
            text: 'Generate PDF',
            onClicked: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PdfPage(
                  supplier: Supplier(
                    name: controller1.text,
                    address: controller2.text,
                    paymentInfo: controller3.text,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
