import 'package:flutter/material.dart';

class FoodItemModel {
  final IconData? icon;
  final int? number;
  final String? name;
  final String? kcal;
  final String? details;
  final String? subDetails;
  final bool missed;
  final bool suggest;
  final bool otherItems;
  final List<FoodItemModel>? suggestions;
  final List<FoodItemModel>? otherFoodItems;

  FoodItemModel({
    this.icon,
    this.number,
    this.name,
    this.kcal,
    this.details,
    this.subDetails,
    this.missed = false,
    this.suggest = false,
    this.otherItems = false,
    this.suggestions,
    this.otherFoodItems,
  });
}
