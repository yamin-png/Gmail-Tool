import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(      title: 'MyApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'MyApp Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  String get getTitle => title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final WebViewController _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..setNavigationDelegate(
      NavigationDelegate(),
    );
  String welcomeText = 'Welcome';
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  bool isGmailLoading = false;
  bool is2FALoading = false;

  void clearData() async {
    final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      //clear cache webview
      await _controller.clearCache();
      if (kDebugMode) {
        print("Cache Cleared");
      }
      //clear history webview
      await _controller.runJavaScript('localStorage.clear();');

      if (kDebugMode) {
        print("History Cleared");
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Data Cleared'),
          duration: Duration(seconds: 1),
        ));
      }
    }

  Future<void> navigateToWebView(String url, String title) async {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text(title),
            ),
            body: WebViewWidget(
              controller: _controller..loadRequest(Uri.parse(url)),
            ),
          ),
        ),
      );
    }
  
  Future<void> _openGmail() async {
    isGmailLoading = true;
    setState(() {});
    await navigateToWebView('https://mail.google.com/mail/u/0/', "Gmail");
    isGmailLoading = false;
    setState(() {});
  }

  Future<void> _openFacebook() async {
    is2FALoading = true;
    setState(() {});
    await navigateToWebView('https://www.facebook.com/', "Facebook");
    is2FALoading = false;
    setState(() {});
  }
  Future<void> _open2FA() async {
    is2FALoading = true;
    setState(() {});
    await navigateToWebView('https://2fa-auth.com/', "2FA");
    is2FALoading = false;
    setState(() {});
  }

  Future<void> _handleRefresh() async {
    refreshIndicatorKey.currentState?.show(); 
    // Simulate a network request or any process that takes time
    await Future.delayed(const Duration(seconds: 1));
  }

  Widget buildStickyButtonBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(onPressed: _openGmail, icon: const Icon(Icons.mail)),

            IconButton(onPressed: _open2FA, icon: const Icon(Icons.lock)),
            IconButton(onPressed: clearData, icon: const Icon(Icons.delete)),
            IconButton(onPressed: _openFacebook, icon: const Icon(Icons.facebook)),
          ],
        ),
      ),
    );
  }
  @override
Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.getTitle),
        ),
        body: Stack(
          children: [
            RefreshIndicator(
              key: refreshIndicatorKey,
              onRefresh: _handleRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        style: GoogleFonts.pacifico(
                          fontSize: 48,
                          color: Colors.deepPurple,
                        ),
                        duration: const Duration(milliseconds: 500),
                        child: Text(welcomeText),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            buildStickyButtonBar(),
          ],
        ));
  }
}
