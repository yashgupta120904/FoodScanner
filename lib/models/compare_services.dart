import 'dart:convert';
import 'package:http/http.dart' as http;

class CompareService {
  // Update this URL to your Python server's address and port
  static const String baseUrl = 'https://e907-103-121-234-140.ngrok-free.app';

  /// Tests connection to the API server using the /health endpoint
  static Future<bool> testConnection() async {
    try {
      print('Testing connection to: $baseUrl/health');
      final response = await http.get(Uri.parse('$baseUrl/health'));
      print('Test connection response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Test connection failed: $e');
      return false;
    }
  }

  /// Compares two food items using the Python backend
  ///
  /// [food1] and [food2] can be either product names or allergens
  static Future<Map<String, dynamic>> compareFood({
    required String food1,
    required String food2,
  }) async {
    try {
      print('Comparing foods: "$food1" and "$food2"');

      // Create multipart form request
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/compare'));

      // Add form fields
      request.fields['food1'] = food1;
      request.fields['food2'] = food2;

      print('Sending form request to: ${request.url}');

      // Send the request
      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);

      print('Form Response status: ${response.statusCode}');
      if (response.body.isNotEmpty) {
        print('Form Response body preview: ${response.body.length > 100 ? response.body.substring(0, 100) + "..." : response.body}');
      }

      if (response.statusCode == 200) {
        try {
          final result = json.decode(response.body);
          // Check if the response contains an error from the server
          if (result.containsKey('error')) {
            return _createErrorResponse(
              result['error'].toString(),
              result['food1']?.toString() ?? food1,
              result['food2']?.toString() ?? food2,
              result['comparison_details']?.toString(),
            );
          }
          return result;
        } catch (e) {
          print('JSON decode error: $e');
          return _createErrorResponse('Failed to parse response: $e', food1, food2);
        }
      } else {
        return _createErrorResponse(
            'Server returned status code ${response.statusCode}',
            food1,
            food2,
            'Response: ${response.body}'
        );
      }
    } catch (e) {
      print('Exception in compareFood: $e');
      return _createErrorResponse('Connection error: $e', food1, food2);
    }
  }

  // Helper method to create consistent error responses
  static Map<String, dynamic> _createErrorResponse(
      String errorMessage,
      String food1,
      String food2, [
        String? details
      ]) {
    return {
      'error': errorMessage,
      'food1': food1,
      'food2': food2,
      'better_nutritional_value': 'Error',
      'comparison_details': details ?? 'Failed to compare items: $errorMessage',
      'potential_side_effects': []
    };
  }
}