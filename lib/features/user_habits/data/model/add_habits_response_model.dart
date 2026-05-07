class AddHabitsResponseModel {
  final bool status;
  final String message;
  final AddHabitsDataModel? data;

  const AddHabitsResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory AddHabitsResponseModel.fromJson(Map<String, dynamic> json) {
    return AddHabitsResponseModel(
      status: json["status"] == true,
      message: json["message"]?.toString() ?? "Unknown response",
      data: json["data"] != null
          ? AddHabitsDataModel.fromJson(json["data"])
          : null,
    );
  }
}

class AddHabitsDataModel {
  final int id;
  final String profileId;
  final String goal;
  final String activity;
  final String foodType;
  final int epochTimestamp;

  const AddHabitsDataModel({
    required this.id,
    required this.profileId,
    required this.goal,
    required this.activity,
    required this.foodType,
    required this.epochTimestamp,
  });

  factory AddHabitsDataModel.fromJson(Map<String, dynamic> json) {
    return AddHabitsDataModel(
      id: int.tryParse(json["id"].toString()) ?? 0,
      profileId: json["profile_id"]?.toString() ?? "",
      goal: json["goal"]?.toString() ?? "",
      activity: json["activity"]?.toString() ?? "",
      foodType: json["food_type"]?.toString() ?? "",
      epochTimestamp: int.tryParse(json["epoch_timestamp"].toString()) ?? 0,
    );
  }
}