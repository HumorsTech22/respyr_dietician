import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';


class ClientProfileService {
  final String baseUrl = "https://humorstech.com/dietitian/api/app/get_clients_by_dietician.php";

  Future<List<ClientProfileModel>> getClientsByDietician(
      String dieticianId) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "dietician_id": dieticianId,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['success'] == true) {
          final List dataList = decoded['data'];

          return dataList
              .map((json) =>
              ClientProfileModel.fromJson(json))
              .toList();
        } else {
          throw Exception(decoded['message'] ?? "API error");
        }
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to fetch clients: $e");
    }
  }
}