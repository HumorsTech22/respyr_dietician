import 'package:dio/dio.dart';
import '../model/client_profile_model.dart';

class ClientRepository {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://humorstech.com/humors_app/app_final/dieticianapp/api/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  Future<List<ClientProfileModel>> fetchClients(String dietitianId, String profileId) async {
    try {
      final response = await dio.post(
        'get_clients.php',
        data: FormData.fromMap({
          'dietitian_id': dietitianId,
          'profile_id': profileId,
        }),
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List dataList = response.data['data'];
        return dataList.map((e) => ClientProfileModel.fromJson(e)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load clients');
      }
    } catch (e) {
      throw Exception('Client fetch failed: $e');
    }
  }
}
