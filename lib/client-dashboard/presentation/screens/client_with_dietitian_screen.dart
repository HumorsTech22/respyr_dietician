import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/client-dashboard/presentation/screens/consultant_info_card.dart';
import 'package:respyr_dietitian/client-dashboard/presentation/screens/diet_plan_card.dart';

import 'package:respyr_dietitian/client-dashboard/presentation/screens/no_diet_plan_hero.dart';
import 'package:respyr_dietitian/client-dashboard/presentation/screens/test_history_card.dart';
import 'package:respyr_dietitian/features/profile_info/data/model/dietician_detail_model.dart';
import '../../common/widgets/loading_widget.dart';
import '../../common/widgets/slide_to_confirm.dart';
import '../../features/gifting/dashboard/presentation/widgets/test_result_history.dart';
import '../../features/test_history/test_history_by_date/data/models/test_data_record.dart';
import '../data/bloc/diet_plan_bloc.dart';
import '../data/bloc/diet_plan_event.dart';
import '../data/bloc/diet_plan_state.dart';
import '../data/model/client_profile_model.dart';
import '../data/repositories/diet_plan_repository.dart';
import '../data/services/diet_plan_service.dart';



class ClientWithDietitianScreen extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  final DietitianDetailModel dietitianModel;
  const ClientWithDietitianScreen({super.key,required this.clientProfileModel, required this.dietitianModel, });

  @override
  State<ClientWithDietitianScreen> createState() => _ClientWithDietitianScreenState();
}

class _ClientWithDietitianScreenState extends State<ClientWithDietitianScreen> {




  @override
  Widget build(BuildContext context) {




    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor:  Color(0xFFD3E5FF),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
    );



    return BlocProvider<DietPlanBloc>(
      create: (_) => DietPlanBloc(DietPlanRepository(DietPlanService()))
        ..add(FetchPlans(
          dietitianId: widget.clientProfileModel.dietitianId,
          clientId: widget.clientProfileModel.profileId,
        )),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocBuilder<DietPlanBloc, DietPlanState>(
            builder: (context, state) {
              if (state.status == LoadStatus.loading) {
                return const Center(
                  child: LoadingWidget(loadingMessage: 'loading message'),
                );
              }

              if (state.status == LoadStatus.failure) {
                return Center(
                  child: Text(
                    'Error: ${state.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              if (state.status == LoadStatus.success) {
                final categorized = state.data;
                if (categorized == null ||
                    (categorized.active.isEmpty &&
                        categorized.completed.isEmpty &&
                        categorized.cancelled.isEmpty &&
                        categorized.other.isEmpty)) {
                  return Stack(
                    children: [
                      Positioned.fill(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                               NoDietPlanHero(clientProfileModel: widget.clientProfileModel,),
                                SizedBox(height: 40,),
                                TestResultHistory(testDataRecord: TestDataRecord.dummy(profileId: widget.clientProfileModel.profileId),),
                                SizedBox(height: 50,),
                                DietPlanCard(activeData: [], completedData:  [], canceledData:  [], dietitianDetailModel: widget.dietitianModel,),
                                SizedBox(height: 50,),
                                ConsultantInfoCard(
                                  dietitianModel: widget.dietitianModel,
                                  clientProfileModel: widget.clientProfileModel,
                                ),
                                SizedBox(height: 50,),
                              ],
                            ),
                          )
                      ),
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(250000),
                                ),
                                shadows: const [
                                  BoxShadow(
                                    color: Color(0x3F000000),
                                    blurRadius: 8.4,
                                    offset: Offset(0, 0),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: ConfirmationSlider(
                                onConfirmation: () {
                                  // TODO: handle confirmation action
                                },
                                backgroundColor: const Color(0xFFF0F0F0),
                                height: 61,
                                width: 209,
                                text: 'Slide to start test',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return Stack(
                  children: [

                    Positioned.fill(
                      child:  SingleChildScrollView(
                        child: Column(
                          children: [
                            DietPlanCard(
                            activeData: categorized.active,
                            completedData:  categorized.completed,
                            canceledData:  categorized.cancelled, dietitianDetailModel: widget.dietitianModel,),

                            ConsultantInfoCard(dietitianModel: widget.dietitianModel, clientProfileModel: widget.clientProfileModel,),
                          ],
                        ),
                      ),),

                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0x3F000000),
                                  blurRadius: 8.4,
                                  offset: Offset(0, 0),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: ConfirmationSlider(
                              onConfirmation: () {
                                // TODO: handle confirmation action
                              },
                              backgroundColor: const Color(0xFFF0F0F0),
                              height: 61,
                              width: 209,
                              text: 'Slide to start test',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );



    return Scaffold(
      backgroundColor: Colors.white,
      body:  SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
             // NoDietPlanHero(),
              // DietPlanHero(dietitianModel: dietitianModel, clientProfileModel: clientProfileModel),
              const SizedBox(height: 20),
              TestHistoryCard(),
              const SizedBox(height: 20),
              //
              const SizedBox(height: 40),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}


// class ClientWithDietitianScreen extends StatelessWidget {
//
//   // @override
//   // void initState() {
//   //   super.initState();
//   //   WidgetsBinding.instance.addObserver(this);
//   //
//   //   askPermission();
//   //   saveFCMToken();
//   //   checkTestLog(context: context, profileId: widget.clientProfileModel.profileId);
//   // }
//   //
//   // @override
//   // void didChangeDependencies() {
//   //   super.didChangeDependencies();
//   //   routeObserver.subscribe(this, ModalRoute.of(context)!);
//   // }
//   //
//   // @override
//   // void dispose() {
//   //   WidgetsBinding.instance.removeObserver(this);
//   //   routeObserver.unsubscribe(this);
//   //   super.dispose();
//   // }
//   //
//   // void saveFCMToken() async {
//   //   FCMService.saveTokenToServer(widget.clientProfileModel.profileId, await DeviceInfoManager().getDeviceId());
//   // }
//   //
//   // void askPermission() async {
//   //   await askNotificationPermission();
//   // }
//
//
//
//
// }


// dietitianModel = DietitianModel(
// id: 1,
// dietitianId: 'diet001',
// name: 'Dt. John',
// phoneNo: '9988776655',
// email: 'manoranjan@example.com',
// location: 'Bhubaneswar',
// logo: 'https://humorstech.com/humors_app/app_final/dieticianapp/api/get_dietician_logo.php?dietician_id=${widget.clientProfileModel.dietitianId}',
// dttm: '2025-08-03 12:34:56',
// password: 'secret123',
// );





// return BlocProvider(
// create: (_) => DietPlanBloc(DietPlanRepository(DietPlanService()))
// ..add(FetchPlans(dietitianId: widget.clientProfileModel.dietitianId, clientId:  widget.clientProfileModel.profileId)),
// child: Scaffold(
// backgroundColor: Colors.white,
// body: BlocBuilder<DietPlanBloc, DietPlanState>(
// builder: (context, state) {
// if (state.status == LoadStatus.loading) {
// return const Center(child: LoadingWidget(loadingMessage: 'loading message',));
// }
//
// if (state.status == LoadStatus.failure) {
// return Center(
// child: Text(
// "Error: ${state.error}",
// style: const TextStyle(color: Colors.red),
// ),
// );
// }
//
// if (state.status == LoadStatus.success) {
// final categorized = state.data;
// if (categorized == null ||
// (categorized.active.isEmpty &&
// categorized.completed.isEmpty &&
// categorized.cancelled.isEmpty &&
// categorized.other.isEmpty)) {
// return const Center(child: Text("No diet plans found"));
// }
//
//
//
//
// return SafeArea(
// child: Stack(
// children: [
//
//
// SingleChildScrollView(
// child: ClientWithDietitianScreen(
// dietitianModel: dietitianModel,
// clientProfileModel:widget.clientProfileModel,
// categorizedPlans: state.data!,
// ),
// ),
//
// Positioned(
// bottom: 20,
// left: 0,
// right: 0,
// child: Row(
// mainAxisSize: MainAxisSize.min,
// mainAxisAlignment: MainAxisAlignment.center,
// children: [
// Container(
// decoration: ShapeDecoration(
//
// shape: RoundedRectangleBorder(
// borderRadius: BorderRadius.circular(25),
// ),
// shadows: [
// BoxShadow(
// color: Color(0x3F000000),
// blurRadius: 8.40,
// offset: Offset(0, 0),
// spreadRadius: 0,
// )
// ],
// ),
// child: ConfirmationSlider(
// onConfirmation: () {
//
// },
// backgroundColor: const Color(0xFFF0F0F0),
// height: 61,
// width: 209,
// text: "Slide to start test",
//
//
// ),
// ),
//
//
// ],
// ),
// )
// ],
// ),
// );
// }
//
// return SizedBox.shrink();
// },
// ),
// ),
//
// );
