import 'package:flutter/material.dart';
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';

 class WebViewScreen extends StatefulWidget {
  final String? url;
  final String title;
  final String? file;
  final Future<bool> Function()? onClose;
  final FutureOr<NavigationDecision> Function(NavigationRequest)? 
  navigationDelegate;

  const WebViewScreen({
    super.key,
    required this.url,
    required this.title,
    this.file,
    this.navigationDelegate,
    this.onClose
  });
  
   @override
   WebViewScreenState createState() => WebViewScreenState();
 }

 class WebViewScreenState extends State<WebViewScreen> {
  late WebViewController _controller;
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) WebView.platform = AndroidWebView( );

  }
  
  @override
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: WillPopScope(
          onWillPop: widget.onClose,
          child: Stack(
            children: <Widget>[
              webView(),
              isLoading ? Center(
                child: CircularProgressIndicator() //url loading
              ) 
              : Stack(),
            ]
          ),
        ),
      ),
    );
  }

  WebView webView(){
    return WebView(
      initialUrl: widget.file 
      == null ? Uri.encodeFull(widget.url!) : ( 'about:blank' ),
      onPageFinished: (finish) {
        setState(() => isLoading = !true );
      },

      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: ( WebViewController webviewController ){
        _controller = webviewController;
        if(widget.file != null){
          loadHtmlFromAssets(widget.file!);
        }
      },

      navigationDelegate: widget.navigationDelegate, // callback
    );
  }
  
  loadHtmlFromAssets(String file) async {
    String html = await rootBundle.loadString(file.toString( ));
    _controller.loadUrl( Uri.dataFromString(
        ( html ),
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());

    ////////////////////////////////////////////////////////////
    
  }
 }