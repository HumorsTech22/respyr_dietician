import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:respyr_dietitian/core/utils/text_style.dart';
import 'package:respyr_dietitian/features/diet_log/data/model/food_item_model.dart';

class MealLoggedCard extends StatelessWidget {
  final String title;
  final String timeRange;
  final List<FoodItemModel> foods;

  const MealLoggedCard({
    super.key,
    required this.title,
    required this.timeRange,
    required this.foods,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(title: title, timeRange: timeRange),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _MealMacroGoal(),
                const SizedBox(height: 20),
                Column(
                  children:
                      foods
                          .map(
                            (food) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: _FoodDetails(food: food),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String timeRange;

  const _Header({required this.title, required this.timeRange});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: poppinsTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                timeRange,
                style: poppinsTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF308BF9),
            ),
          ),
        ],
      ),
    );
  }
}

class _MealMacroGoal extends StatelessWidget {
  const _MealMacroGoal();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7AD),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            width: 25,
            height: 25,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const CircularProgressIndicator(
                  value: 0.75,
                  strokeWidth: 2,
                  backgroundColor: Color(0xFFF5F7FA),
                  color: Color(0xFF3FAF58),
                ),
                Center(
                  child: SvgPicture.asset(
                    "assets/images/common/trophy.svg",
                    height: 15,
                    width: 15,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF252525),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text('Meal Macro goal', style: poppinsTextStyle(fontSize: 12)),
          Text('•', style: poppinsTextStyle(fontSize: 12)),
          Text(
            '75% completed',
            style: poppinsTextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const Icon(Icons.keyboard_arrow_right, color: Colors.black),
        ],
      ),
    );
  }
}

class _FoodDetails extends StatelessWidget {
  final FoodItemModel food;

  const _FoodDetails({required this.food});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border:
                food.missed
                    ? Border.all(color: const Color(0xFFDA5747), width: 1)
                    : null,
          ),
          child:
              food.otherItems && food.otherFoodItems != null
                  ? _OtherItemsSection(food: food)
                  : _NormalFoodSection(food: food),
        ),
        if (food.missed)
          Positioned(
            top: -9,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "You've Missed",
                style: poppinsTextStyle(
                  fontSize: 12,
                  color: const Color(0xFFDA5747),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _NormalFoodSection extends StatelessWidget {
  final FoodItemModel food;

  const _NormalFoodSection({required this.food});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          food.icon,
          color: food.missed ? const Color(0xFFDA5747) : Colors.black,
        ),
        const SizedBox(width: 10),
        Text(
          '${food.number}',
          style: poppinsTextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color:
                food.missed ? const Color(0xFFDA5747) : const Color(0xFF252525),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FoodRow(food: food),
              if (food.suggest && food.suggestions != null) ...[
                const SizedBox(height: 8),
                _OrDivider(),
                const SizedBox(height: 10),
                for (var alt in food.suggestions!)
                  _FoodRow(
                    food: alt,
                    isSuggestion: true,
                    parentMissed: food.missed,
                    parentSuggest: food.suggest,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _OtherItemsSection extends StatelessWidget {
  final FoodItemModel food;

  const _OtherItemsSection({required this.food});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Other items',
            style: poppinsTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF535359),
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children:
                food.otherFoodItems!
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _FoodRow(food: item),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }
}

class _FoodRow extends StatelessWidget {
  final FoodItemModel food;
  final bool isSuggestion;
  final bool parentMissed;
  final bool parentSuggest;

  const _FoodRow({
    required this.food,
    this.isSuggestion = false,
    this.parentMissed = false,
    this.parentSuggest = false,
  });

  @override
  Widget build(BuildContext context) {
    const black = Color(0xFF252525);
    const suggestionGray = Color(0xFFA1A1A1);
    const blue = Color(0xFF308BF9);

    final Color textColor;
    final Color iconColor;

    if (isSuggestion) {
      if (parentSuggest) {
        textColor = parentMissed ? black : suggestionGray;
        iconColor = parentMissed ? blue : suggestionGray;
      } else {
        textColor = black;
        iconColor = blue;
      }
    } else {
      textColor = black;
      iconColor = blue;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                food.name ?? "",
                style: poppinsTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            if (!food.otherItems) ...[
              const SizedBox(width: 5),
              Text(
                food.kcal ?? "",
                style: poppinsTextStyle(fontSize: 12, color: textColor),
              ),
            ],
          ],
        ),
        const SizedBox(height: 5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              food.details ?? "",
              style: poppinsTextStyle(fontSize: 10, color: textColor),
            ),
            const SizedBox(width: 5),
            SvgPicture.asset(
              "assets/images/common/detail_icon.svg",
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
            if (food.subDetails != null) ...[
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  food.subDetails!,
                  style: poppinsTextStyle(fontSize: 10, color: textColor),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('or', style: poppinsTextStyle(fontSize: 12)),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
