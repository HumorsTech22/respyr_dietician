import 'dart:convert';
import 'package:http/http.dart' as http;

class CountryModel {
  final int id;
  final String countryName;
  final String countryCode;
  final String telephoneCode;

  CountryModel({
    required this.id,
    required this.countryName,
    required this.countryCode,
    required this.telephoneCode,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      countryName: json['country_name']?.toString() ?? '',
      countryCode: json['country_code']?.toString() ?? '',
      telephoneCode: json['telephone_code']?.toString() ?? '',
    );
  }
}

class CountryResponse {
  final bool status;
  final String message;
  final List<CountryModel> data;

  CountryResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CountryResponse.fromJson(Map<String, dynamic> json) {
    return CountryResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is List
          ? (json['data'] as List)
          .map((e) => CountryModel.fromJson(e))
          .toList()
          : [],
    );
  }
}

class CountryService {
  static const String _url =
      "https://humorstech.com/dietitian/api/app/get_countries.php";

  static Future<CountryResponse> fetchCountries() async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          "Content-Type": "application/json",
        },
      );

      final Map<String, dynamic> jsonBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return CountryResponse.fromJson(jsonBody);
      }

      return CountryResponse(
        status: false,
        message:
        jsonBody['message']?.toString() ?? "Failed to fetch countries",
        data: [],
      );
    } catch (e) {
      return CountryResponse(
        status: false,
        message: "Something went wrong: $e",
        data: [],
      );
    }
  }
}