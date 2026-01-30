import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/retake_test/bloc/retake_test_cubit.dart';
import 'package:respyr_dietitian/features/retake_test/presentation/screens/retake_test_screen.dart';



void main() {
  testWidgets('Continue disabled initially', (tester) async {
    final dummyClient = ClientProfileModel(id: 1, dietitianId: '', profileId: '', phoneNo: '', email: '', profileName: '', profileImage: '', age: '', gender: '', height: '', weight: '', region: '', location: '', dttm: '', isNotificationEnabled: 1, isDietitianLinkedInt: 1); // make minimal constructor or mock

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => RetakeTestCubit(),
          child: RetakeTestScreen(clientProfileModel: dummyClient),
        ),
      ),
    );

    final button = find.text('Continue');
    expect(button, findsOneWidget);

    final elevated = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );
    expect(elevated.onPressed, isNull); // disabled
  });

  testWidgets('Selecting curious enables Continue', (tester) async {
    final dummyClient = ClientProfileModel(id: 0, dietitianId: '', profileId: '', phoneNo: '', email: '', profileName: '', profileImage: '', age: '', gender: '', height: '', weight: '', region: '', location: '', dttm: '', isNotificationEnabled: 0, isDietitianLinkedInt: 0);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => RetakeTestCubit(),
          child: RetakeTestScreen(clientProfileModel: dummyClient),
        ),
      ),
    );

    // Tap on "Just curious"
    await tester.tap(find.text('Just curious'));
    await tester.pumpAndSettle();

    final elevated = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );
    expect(elevated.onPressed, isNotNull); // enabled
  });

  testWidgets('Selecting other shows textfield and needs input', (tester) async {
    final dummyClient = ClientProfileModel(id: 0, dietitianId: '', profileId: '', phoneNo: '', email: '', profileName: '', profileImage: '', age: '', gender: '', height: '', weight: '', region: '', location: '', dttm: '', isNotificationEnabled: 0, isDietitianLinkedInt: 0);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => RetakeTestCubit(),
          child: RetakeTestScreen(clientProfileModel: dummyClient),
        ),
      ),
    );

    // Tap Other
    await tester.tap(find.text('Other'));
    await tester.pumpAndSettle();

    // TextField should appear
    expect(find.byType(TextField), findsOneWidget);

    // Still disabled because no text
    var elevated = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(elevated.onPressed, isNull);

    // Enter text
    await tester.enterText(find.byType(TextField), 'Not satisfied');
    await tester.pumpAndSettle();

    elevated = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(elevated.onPressed, isNotNull);
  });
}
