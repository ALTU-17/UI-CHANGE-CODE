import 'package:flutter/material.dart';

// Add this helper class
class TextSanitizer {
  // Remove HTML/PHP tags and decode HTML entities
  static String cleanText(String text) {
    if (text.isEmpty) return text;

    // First, decode HTML entities like &nbsp;, &lt;, &gt;, &amp;, etc.
    String cleaned = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&rsquo;', "'")
        .replaceAll('&lsquo;', "'")
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"')
        .replaceAll('&mdash;', '—')
        .replaceAll('&ndash;', '–');

    // Remove PHP tags <?php ... ?> and <? ... ?>
    RegExp phpPattern = RegExp(r'<\?php.*?\?>', caseSensitive: false, dotAll: true);
    cleaned = cleaned.replaceAll(phpPattern, '');

    RegExp shortPhpPattern = RegExp(r'<\?.*?\?>', caseSensitive: false, dotAll: true);
    cleaned = cleaned.replaceAll(shortPhpPattern, '');

    // Remove HTML tags
    RegExp htmlPattern = RegExp(r'<[^>]*>');
    cleaned = cleaned.replaceAll(htmlPattern, '');

    // Remove script tags and their content
    RegExp scriptPattern = RegExp(r'<script.*?>.*?</script>', caseSensitive: false, dotAll: true);
    cleaned = cleaned.replaceAll(scriptPattern, '');

    // Remove style tags and their content
    RegExp stylePattern = RegExp(r'<style.*?>.*?</style>', caseSensitive: false, dotAll: true);
    cleaned = cleaned.replaceAll(stylePattern, '');

    // Clean up extra whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    return cleaned;
  }

  // Alternative: Use a more aggressive approach to remove any <? ?> tags
  static String removePhpTags(String text) {
    return text.replaceAll(RegExp(r'<\?.*?\?>'), '').trim();
  }
}