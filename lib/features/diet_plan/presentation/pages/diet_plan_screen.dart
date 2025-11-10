// features/diet_plan/presentation/pages/diet_plan_screen.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:respyr_dietitian/features/log_food/data/repository/api_backed_log_food_repository.dart';
import 'package:respyr_dietitian/features/log_food/presentation/cubit/log_food_cubit.dart';
import 'package:respyr_dietitian/features/log_food/presentation/cubit/test_timer_cubit/test_timer_cubit.dart';
import 'package:respyr_dietitian/features/log_food/presentation/pages/log_food_pages.dart';

// INSERT API you already have
import '../../../log_food/data/repository/insert_food_log_api.dart';
// NEW fetch file
import 'package:respyr_dietitian/features/log_food/data/repository/fetch_food_log_api.dart';

import '../widgets/log_food_sheet.dart';

class DietPlanScreen extends StatefulWidget {
  final String dieticianId;
  final String profileId;
  final String dietPlanId;
  const DietPlanScreen({super.key, required this.dieticianId, required this.profileId, required this.dietPlanId});

  @override
  State<DietPlanScreen> createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends State<DietPlanScreen> {
  bool loading = true;
  String? error;
  Map<String, dynamic> diet = {};
  String activeDay = 'monday';



  // Logged keys cache for "today"
  Set<String> loggedKeys = <String>{};
  DateTime currentDate = DateTime.now(); // using today's date for fetch

  static const List<String> _weekdayOrder = [
    'monday','tuesday','wednesday','thursday','friday','saturday','sunday',
  ];

  List<String> visibleDays = [];
  final Map<String, GlobalKey> _chipKeys = {
    for (final d in _weekdayOrder) d: GlobalKey()
  };

  @override
  void initState() {
    super.initState();
    activeDay = _todayName();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await fetchDiet();
    await _fetchLoggedForToday(); // after diet so UI has content
  }

  String _todayName() {
    final wd = DateTime.now().weekday; // Monday=1 ... Sunday=7
    return _weekdayOrder[wd - 1];
  }

  Future<void> fetchDiet() async {
    try {
      final uri = Uri.parse(
        'https://humorstech.com/dietitian/api/app/get_diet_plan.php',
      );


      print( widget.dieticianId);
      print( widget.profileId);
      print( widget.dietPlanId);






      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          "login_id": widget.dieticianId,
          "profile_id": widget.profileId,
          "diet_plan_id": widget.dietPlanId,
        }),
      );

      final body = utf8.decode(res.bodyBytes);
      final top = json.decode(body) as Map<String, dynamic>;



      print(res.body);



      if (res.statusCode != 200 || top['success'] != true) {
        throw Exception('Server error');
      }

      final dataArr = (top['data'] as List?) ?? [];
      if (dataArr.isEmpty) {
        throw Exception('No data');
      }

      final data0 = dataArr.first as Map<String, dynamic>;
      final dynDietJson = data0['diet_json'];

      late final Map<String, dynamic> parsedDiet;
      if (dynDietJson is Map) {
        parsedDiet = Map<String, dynamic>.from(dynDietJson);
      } else if (dynDietJson is String) {
        parsedDiet = json.decode(dynDietJson) as Map<String, dynamic>;
      } else {
        throw Exception('Unexpected diet_json type: ${dynDietJson.runtimeType}');
      }

      final keys = parsedDiet.keys.map((e) => e.toString().toLowerCase()).toSet();
      final daysInOrder = _weekdayOrder.where((d) => keys.contains(d)).toList(growable: false);

      final defaultDay = _todayName();
      final picked = daysInOrder.contains(defaultDay)
          ? defaultDay
          : (daysInOrder.isNotEmpty ? daysInOrder.first : 'monday');

      setState(() {
        diet = parsedDiet;
        visibleDays = daysInOrder;
        activeDay = picked;
        loading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _centerDayChip(activeDay);
      });
    } catch (e) {
      setState(() {
        error = 'Fetch Error: $e';
        loading = false;
      });
    }
  }

  Future<void> _fetchLoggedForToday() async {
    try {
      final keys = await FoodLogFetchApi.fetchLoggedKeys(
        dieticianId: widget.dieticianId,
        profileId: widget.profileId,
        dietPlanId: widget.dietPlanId,
        date: currentDate, // today
      );
      setState(() {
        loggedKeys = keys;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Fetch logged failed: $e");
      }
      // keep UI usable
    }
  }

  Future<void> _centerDayChip(String dayKey) async {
    final key = _chipKeys[dayKey];
    if (key?.currentContext != null) {
      await Scrollable.ensureVisible(
        key!.currentContext!,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (error != null) {
      return Scaffold(
        body: Center(child: Text(error!, textAlign: TextAlign.center)),
      );
    }

    final dayData = diet[activeDay] as Map<String, dynamic>?;
    final meals = (dayData?['meals'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        surfaceTintColor: const Color(0xFFF5F7FA),
        title: Text(
          'Diet Plan',
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.90,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Day chips (order fixed, center selected)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              child: Row(
                spacing: 10,
                children: visibleDays.map((d) {
                  final sel = d == activeDay;
                  return GestureDetector(
                    key: _chipKeys[d],
                    onTap: () async {
                      setState(() => activeDay = d);
                      await _centerDayChip(d);
                    },
                    child: Container(
                      decoration: ShapeDecoration(
                        color: sel ? const Color(0xFF308BF9) : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(
                        d[0].toUpperCase() + d.substring(1, 3), // Mon, Tue, ...
                        style: GoogleFonts.poppins(
                          color: sel ? Colors.white : const Color(0xFF252525),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Meals for selected day
            Expanded(
              child: ListView.builder(
                itemCount: meals.length,
                itemBuilder: (_, i) {
                  final m = meals[i];
                  final mealTitle = (m['time'] ?? '').toString(); // dietTitle
                  final items = (m['items'] as List? ?? const [])
                      .whereType<Map<String, dynamic>>()
                      .toList();
                  final mt = (m['totals'] as Map<String, dynamic>? ?? {});

                  return Card(
                    color: Colors.white,
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mealTitle,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF252525),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              height: 1.10,
                              letterSpacing: -0.72,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Food rows
                          ...List.generate(items.length, (idx) {
                            final it = items[idx];
                            final foodName = (it['name'] ?? '').toString();
                            final key = FoodLogFetchApi.makeKey(mealTitle, foodName);
                            final isLogged = loggedKeys.contains(key);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: dietPlanFoodItem(
                                index: idx + 1,
                                mealTitle: mealTitle,
                                foodName: foodName,
                                foodType: 'None',
                                foodScale: (it['portion'] ?? '').toString(),
                                foodCalories: (it['calories_kcal'] ?? '').toString(),
                                foodProtein: (it['protein'] ?? '').toString(),
                                foodFat: (it['fat'] ?? '').toString(),
                                foodCarbs: (it['carbs'] ?? '').toString(),
                                context: context,
                                isLogged: isLogged,
                                onLogged: () {
                                  // Update state immediately on success
                                  setState(() {
                                    loggedKeys = Set<String>.from(loggedKeys)..add(key);
                                  });
                                },
                                onAlreadyLogged: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Already logged")),
                                  );
                                },
                                dieticianId: widget.dieticianId,
                                profileId: widget.profileId,
                                dietPlanId: widget.dietPlanId,
                              ),
                            );
                          }),


                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Navigate to Log Food screen with repo built from today's meals
      // floatingActionButton: SafeArea(
      //   child: ElevatedButton(
      //     onPressed: () {
      //       final dayData = diet[activeDay] as Map<String, dynamic>?;
      //       final meals = (dayData?['meals'] as List? ?? const [])
      //           .whereType<Map<String, dynamic>>()
      //           .toList();
      //       final repo = ApiBackedLogFoodRepository.fromDayMeals(meals);
      //
      //       Navigator.of(context).push(
      //         MaterialPageRoute(
      //           builder: (_) => MultiBlocProvider(
      //             providers: [
      //               BlocProvider<LogFoodCubit>(create: (_) => LogFoodCubit(repo)),
      //               BlocProvider<TestTimerCubit>(create: (_) => TestTimerCubit()),
      //             ],
      //             child: const LogFoodPage(),
      //           ),
      //         ),
      //       );
      //     },
      //     style: ElevatedButton.styleFrom(
      //       backgroundColor: const Color(0xFF308BF9),
      //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      //     ),
      //     child: Row(
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         const Icon(Icons.keyboard_arrow_right_rounded, color: Colors.white),
      //         const SizedBox(width: 8),
      //         Text(
      //           "Log Food",
      //           style: GoogleFonts.poppins(
      //               color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}

/// Your existing row UI with minimal visual indicator added (green tick) and
/// duplicate-insert protection. No layout changes.
Widget dietPlanFoodItem({
  required int index,
  required String mealTitle,
  required String foodName,
  required String foodType,
  required String foodScale,
  required String foodCalories,
  required String foodProtein,
  required String foodFat,
  required String foodCarbs,
  required BuildContext context,
  required bool isLogged,
  required VoidCallback onLogged,
  required VoidCallback onAlreadyLogged,
  required String dieticianId,
  required String profileId,
  required String dietPlanId,
}) {
  Future<void> insertFoodLog() async {


    LogFoodSheet().showFoodBottomSheet(
      context: context,
      mealTitle: mealTitle,
      index: index,
      foodName: foodName,
      foodType: foodType,
      foodScale: foodScale,
      foodCalories: foodCalories,
      foodProtein: foodProtein,
      foodFat: foodFat,
      foodCarbs: foodCarbs,
      isLogged: isLogged,
      onLogged: () { onLogged(); },
      onAlreadyLogged: () { onAlreadyLogged(); },
      dieticianId: dieticianId,
      profileId: profileId,
      dietPlanId: dietPlanId,
    );


  }

  return GestureDetector(
    onTap: insertFoodLog,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 9),
              Text(
                index.toString(),
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.26,
                  letterSpacing: -0.30,
                ),
              ),
              const SizedBox(width: 22),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      foodName,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.26,
                        letterSpacing: -0.24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      foodScale,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 22),

              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [

                    Text(
                      "$foodCalories kcal",
                      textAlign: TextAlign.right,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF535359),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.24,
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}



