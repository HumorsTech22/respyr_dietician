import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/client_diet_plan/bloc/weekly_tab_bloc.dart';
import 'package:respyr_dietitian/features/client_diet_plan/bloc/weekly_tab_event.dart';
import 'package:respyr_dietitian/features/client_diet_plan/bloc/weekly_tab_state.dart';
import 'package:respyr_dietitian/features/client_diet_plan/bloc/weekly_food_bloc.dart';
import 'package:respyr_dietitian/features/client_diet_plan/bloc/weekly_food_event.dart';
import 'package:respyr_dietitian/features/client_diet_plan/bloc/weekly_food_state.dart';
import 'package:respyr_dietitian/features/client_diet_plan/presentation/screens/diet_plan_screen.dart';
import 'package:respyr_dietitian/features/client_diet_plan/utils/diet_plan_date_helper.dart';
import 'package:respyr_dietitian/features/dashboard/presentation/widgets/loading_screen.dart';
import '../widgets/diet_plan_error_screen.dart';

class ClientDietPlan extends StatefulWidget {
  final ClientProfileModel clientProfileModel;

  const ClientDietPlan({
    super.key,
    required this.clientProfileModel,
  });

  @override
  State<ClientDietPlan> createState() => _ClientDietPlanState();
}

class _ClientDietPlanState extends State<ClientDietPlan> {
  int selectedDayIndex = 0;

  bool initialDaySelected = false;

  String selectedWeekStartDate = '';
  String selectedWeekEndDate = '';

  @override
  void initState() {
    super.initState();

    context.read<WeeklyTabBloc>().add(
      FetchWeeklyTabs(
        profileId: widget.clientProfileModel.profileId,
        dietitianId: widget.clientProfileModel.dietitianId,
      ),
    );
  }

  void _fetchFoodForWeek({
    required String weekStartDate,
    required String weekEndDate,
  }) {
    selectedWeekStartDate = weekStartDate;
    selectedWeekEndDate = weekEndDate;
    initialDaySelected = false;

    context.read<WeeklyFoodBloc>().add(
      FetchWeeklyFood(
        profileId: widget.clientProfileModel.profileId,
        dietitianId: widget.clientProfileModel.dietitianId,
        weekStartDate: weekStartDate,
        weekEndDate: weekEndDate,
      ),
    );
  }

  void _selectDay(int index) {
    setState(() {
      selectedDayIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeeklyTabBloc, WeeklyTabState>(
      builder: (context, state) {
        if (state is WeeklyTabLoading) {
          return LoadingScreen();
        }

        if (state is WeeklyTabError) {
          return DietPlanErrorScreen(errorMessage: state.message);
        }

        if (state is! WeeklyTabLoaded) {
          return const SizedBox();
        }

        final list = state.response.data;

        if (list.isEmpty) {
          return const Center(child: Text('No weekly data found'));
        }

        final latestWeek = list.first;

        if (selectedWeekStartDate != latestWeek.weekStartDate ||
            selectedWeekEndDate != latestWeek.weekEndDate) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _fetchFoodForWeek(
              weekStartDate: latestWeek.weekStartDate,
              weekEndDate: latestWeek.weekEndDate,
            );
          });
        }

        return BlocBuilder<WeeklyFoodBloc, WeeklyFoodState>(
          builder: (context, foodState) {
            if (foodState is WeeklyFoodLoading) {
              return LoadingScreen();
            }

            if (foodState is WeeklyFoodError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    foodState.message,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (foodState is! WeeklyFoodLoaded) {
              return const SizedBox();
            }

            final days = foodState.response.data?.foodJson.days ?? [];

            if (days.isEmpty) {
              return const Center(child: Text('No diet found'));
            }

            final weekStartDate =
                foodState.response.data?.weekStartDate ??
                    latestWeek.weekStartDate;

            if (!initialDaySelected) {
              selectedDayIndex = DietPlanDateHelper.findTodayDayIndex(
                weekStartDate,
                days.length,
              );

              initialDaySelected = true;
            }

            if (selectedDayIndex >= days.length) {
              selectedDayIndex = 0;
            }

            final selectedDay = days[selectedDayIndex];

            // return NewDietPlanScreen(
            // selectedDayIndex: selectedDayIndex,
            // days: days, weekStartDate: weekStartDate, onDaySelected: _selectDay, day: selectedDay,);


            // return Scaffold(
            //   backgroundColor: const Color(0xFFF5F7FA),
            //   appBar: dietPlanAppBar(),
            //   body: SafeArea(
            //     child: Column(
            //       children: [
            //         DaySelector(
            //           days: days,
            //           selectedDayIndex: selectedDayIndex,
            //           weekStartDate: weekStartDate,
            //           onDaySelected: _selectDay,
            //         ),
            //
            //
            //         SizedBox(height: 20,),
            //         Expanded(
            //             child: SingleChildScrollView(
            //               child:    SelectedDayDietView(day: selectedDay),
            //             )
            //         )
            //
            //
            //
            //       ],
            //     ),
            //   ),
            // );

            return DietScreen(clientProfileModel: widget.clientProfileModel,
              days: days,
              selectedDayIndex: selectedDayIndex,
              weekStartDate: weekStartDate,
              onDaySelected: _selectDay, day: selectedDay,
            );
          },
        );
      },
    );
  }
}