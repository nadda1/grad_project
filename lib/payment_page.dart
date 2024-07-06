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
        key: ValueKey('payment_webview'),
        initialContent: widget.paymentUrl,
        initialSourceType: SourceType.URL,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        onWebViewCreated: (controller) {
          webviewController = controller;
        },
        onPageStarted: (src) {
          print('Page started loading: $src');
        },
        onPageFinished: (src) {
          print('Page finished loading: $src');
        },
        onWebResourceError: (error) {
          print('Web resource error: ${error.description}');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to load the payment page'),
          ));
        },
        javascriptMode: JavascriptMode.unrestricted,
        webSpecificParams: WebSpecificParams(),
        mobileSpecificParams: MobileSpecificParams(
          navigationDelegate: (navigation) async {
            return NavigationDecision.navigate;
          },
        ),
      ),
    );
  }
}
