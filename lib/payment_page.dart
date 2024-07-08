import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webviewx/webviewx.dart';

class PaymentPage extends StatefulWidget {
  final String paymentUrl;
  final String jobSlug;
  final String applicationSlug;

  PaymentPage({required this.paymentUrl, required this.jobSlug, required this.applicationSlug});

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
        onPageFinished: (src) async {
          Uri uri = Uri.parse(src);
          if (uri.queryParameters['success'] == 'false') {
            await unhireFreelancer(widget.jobSlug, widget.applicationSlug);
          }
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

  Future<void> unhireFreelancer(String jobSlug, String applicationSlug) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Authentication error. Please log in again.")));
      return;
    }

    final response = await http.delete(
      Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/hire/$jobSlug/$applicationSlug'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Unhired successfully.")));
    } else {
      var responseBody = json.decode(response.body);
      var error = responseBody['message'];
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }
}
