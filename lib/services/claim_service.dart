import 'dart:convert';
import 'dart:io';
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
    Map<String, dynamic>? damageAnalysis,
    String? photoPath,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/claims/submit');

    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $accessToken';

    request.fields['vehicleMake'] = (vehicle['make'] ?? '').toString();
    request.fields['vehicleModel'] = (vehicle['model'] ?? '').toString();
    request.fields['vehicleYear'] = (vehicle['year'] ?? '').toString();
    request.fields['vehicleLicensePlate'] = (vehicle['licensePlate'] ?? '').toString();
    request.fields['vehicleVin'] = (vehicle['vin'] ?? '').toString();
    request.fields['vehicleColor'] = (vehicle['color'] ?? '').toString();

    request.fields['incidentDate'] = incidentDate;
    request.fields['incidentDescription'] = incidentDescription;
    request.fields['incidentType'] = incidentType;
    request.fields['estimatedAmount'] = estimatedAmount.toString();

    request.fields['incidentAddress'] = (incidentLocation['address'] ?? '').toString();
    request.fields['incidentCity'] = (incidentLocation['city'] ?? '').toString();

    if (damageAnalysis != null) {
      request.fields['damageAnalysis'] = jsonEncode(damageAnalysis);
    }

    if (photoPath != null && photoPath.isNotEmpty) {
      final file = File(photoPath);
      if (await file.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('photos', photoPath),
        );
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    Map<String, dynamic> data = {};
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception(
        'Backend returned non-JSON response (status ${response.statusCode}). Check backend terminal logs.'
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to submit claim');
    }
  }

  Future<Map<String, dynamic>> analyzeImage({
    required String accessToken,
    required String imagePath,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/ml/analyze');

    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $accessToken';

    request.files.add(
      await http.MultipartFile.fromPath('image', imagePath),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    Map<String, dynamic> data = {};
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception(
        'Backend returned non-JSON response (status ${response.statusCode}). Check backend terminal logs.'
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to analyze image');
    }
  }

}
