

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PowerBIReportPage extends StatefulWidget {
  @override
  _PowerBIReportPageState createState() => _PowerBIReportPageState();
}

class _PowerBIReportPageState extends State<PowerBIReportPage> {
  late WebViewController webViewController;

  @override
  void initState() {
    super.initState();


    // Enable hybrid composition if on Android
    if (WebView.platform is AndroidWebView) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jobs Report'),
      ),
      body: WebView(
        initialUrl: 'https://app.powerbi.com/reportEmbed?reportId=af90fc48-eac6-4c7e-9504-99facece773e&autoAuth=true&ctid=77255288-5298-4ea5-81aa-a13e604c30ac&filterPaneEnabled=false',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          this.webViewController = webViewController;
        },
        initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow, // Allow autoplay for media content
        onPageFinished: (String url) {

        },
      ),
    );
  }
}
