class DeleteAccountResponse {
  final bool success;
  final String message;
  final DeleteCounts deleted;

  DeleteAccountResponse({
    required this.success,
    required this.message,
    required this.deleted,
  });

  factory DeleteAccountResponse.fromJson(Map<String, dynamic> json) {
    return DeleteAccountResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      deleted: DeleteCounts.fromJson(
        (json['deleted'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }
}

class DeleteCounts {
  final int tableTestData;
  final int tableClients;

  DeleteCounts({
    required this.tableTestData,
    required this.tableClients,
  });

  factory DeleteCounts.fromJson(Map<String, dynamic> json) {
    return DeleteCounts(
      tableTestData: _toInt(json['table_test_data']),
      tableClients: _toInt(json['table_clients']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}