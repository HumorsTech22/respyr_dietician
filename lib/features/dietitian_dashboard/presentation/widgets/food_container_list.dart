import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:respyr_dietitian/core/utils/text_style.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/data/model/dietitian_dashboard_meal_model.dart';

class FoodContainerList extends StatelessWidget {
  final List<DietitianDashboardFoodItem> foodItems;
  final Color iconColor;

  const FoodContainerList({
    super.key,
    required this.foodItems,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    // Show only first 3 items if list is long
    final visibleItems =
        foodItems.length > 3 ? foodItems.take(3).toList() : foodItems;

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visibleItems.length,
          separatorBuilder: (_, __) => const SizedBox(height: 0),
          itemBuilder: (context, index) {
            final item = visibleItems[index];
            return foodContainer(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/images/dietitian_dashboard/dish_svg.svg",
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "${index + 1}",
                      style: poppinsTextStyle(
                        color: iconColor,
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: poppinsTextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item.portion,
                                  style: poppinsTextStyle(
                                    color: const Color(0xFF252525),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              InkWell(
                                onTap: () => _showFoodInfoDialog(context, item),
                                child: Icon(
                                  Icons.info_outline,
                                  size: 12,
                                  color: iconColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "${item.calories} kcal",
                      style: poppinsTextStyle(
                        color: const Color(0xFF535359),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // 🔹 Show “View All” button if there are more than 3 items
        if (foodItems.length > 3)
          TextButton(
            onPressed: () => _showAllFoodItemsDialog(context),
            child: Text(
              "View All",
              style: poppinsTextStyle(
                color: iconColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  /// Show full list in a dialog
  void _showAllFoodItemsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("All Food Items"),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: foodItems.length,
                itemBuilder: (context, index) {
                  final item = foodItems[index];
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text(item.portion),
                    trailing: Text("${item.calories} kcal"),
                    onTap: () => _showFoodInfoDialog(context, item),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
    );
  }

  /// Show detailed info for one food item
  void _showFoodInfoDialog(
    BuildContext context,
    DietitianDashboardFoodItem item,
  ) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(item.name),
            content: Text(
              "Portion: ${item.portion}\n"
              "Protein: ${item.protein} g\n"
              "Carbs: ${item.carbs} g\n"
              "Fat: ${item.fat} g\n"
              "Calories: ${item.calories} kcal",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
    );
  }

  Widget foodContainer({required Widget child}) {
    return Opacity(
      opacity: 0.50,
      child: Container(
        width: double.infinity,
        height: 85,
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.white, Colors.white.withOpacity(0)],
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}
