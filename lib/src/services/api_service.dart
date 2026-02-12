import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/app_event.dart';

class ApiService {
  ApiService({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<bool> sendEvent(AppEvent event) async {
    final uri = Uri.parse('$baseUrl/api/v1/device-signals');
    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(event.toMap()),
    );
    return response.statusCode >= 200 && response.statusCode < 300;
  }
}
