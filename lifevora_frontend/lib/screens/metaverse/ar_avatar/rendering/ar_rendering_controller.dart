import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Manages the WebView bridge to the Three.js 3D avatar scene.
/// Provides methods to send mood/progress commands to the JS layer.
///
/// Since webview_flutter is not always available on all platforms,
/// this class also works as a standalone widget that embeds the
/// scene directly or provides a fallback if WebView can't load.
class ArRenderingController {
  /// JavaScript to inject into the WebView to set mood.
  static String setMoodJs(String mood) {
    return "if(window.setMood) window.setMood('$mood');";
  }

  /// JavaScript to inject into the WebView to set progress.
  static String setProgressJs(double progress) {
    return "if(window.setProgress) window.setProgress($progress);";
  }

  /// Load the avatar scene HTML from assets as a data URI.
  static Future<String> loadSceneHtml() async {
    try {
      final html = await rootBundle.loadString(
        'assets/ar_avatar/avatar_scene.html',
      );
      return html;
    } catch (e) {
      debugPrint('ArRenderingController.loadSceneHtml error: $e');
      rethrow;
    }
  }

  /// Create a data URI from HTML content (for WebView loading).
  static String htmlToDataUri(String html) {
    final encoded = base64Encode(utf8.encode(html));
    return 'data:text/html;base64,$encoded';
  }
}
