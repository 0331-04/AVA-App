import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ClaimService {
  Future<List<Map<String, dynamic>>> getClaims({
    required String accessToken,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/claims');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final list = data['data'];
      if (list is List) {
        return List<Map<String, dynamic>>.from(list);
      }
      return [];
    } else {
      throw Exception(data['message'] ?? 'Failed to load claims');
    }
  }

  Future<Map<String, dynamic>> submitClaim({
    required String accessToken,
    required Map<String, dynamic> vehicle,
    required String incidentDate,
    required String incidentDescription,
    required String incidentType,
    required num estimatedAmount,
    required Map<String, dynamic> incidentLocation,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/claims/submit');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'vehicle': vehicle,
        'incidentDate': incidentDate,
        'incidentDescription': incidentDescription,
        'incidentType': incidentType,
        'estimatedAmount': estimatedAmount,
        'incidentLocation': incidentLocation,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to submit claim');
    }
  }
}
