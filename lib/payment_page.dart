import 'package:flutter/material.dart';
import 'package:webviewx/webviewx.dart';

class PaymentPage extends StatefulWidget {
  final String paymentUrl;

  PaymentPage({required this.paymentUrl});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late WebViewXController webviewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
        backgroundColor: Color(0xFF343ABA),
      ),
      body: WebViewX(
        initialContent: widget.paymentUrl,
        initialSourceType: SourceType.URL,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        onWebViewCreated: (controller) {
          webviewController = controller;
        },
      ),
    );
  }
}
