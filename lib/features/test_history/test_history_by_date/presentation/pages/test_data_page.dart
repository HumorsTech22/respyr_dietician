// lib/features/metabolism_test/presentation/pages/test_data_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/test_data_bloc.dart';
import '../../bloc/test_data_event.dart';
import '../../bloc/test_data_state.dart';
import '../widgets/test_data_list.dart';

class TestDataPage extends StatefulWidget {
  final String initialProfileId; // e.g., 'profile1'
  final DateTime initialDate;    // e.g., DateTime.now()

  const TestDataPage({
    super.key,
    required this.initialProfileId,
    required this.initialDate,
  });

  @override
  State<TestDataPage> createState() => _TestDataPageState();
}

class _TestDataPageState extends State<TestDataPage> {
  late final TextEditingController _profileController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _profileController = TextEditingController(text: widget.initialProfileId);
    _selectedDate = widget.initialDate;
    _fetch();
  }

  void _fetch() {
    context.read<TestDataBloc>().add(
      FetchTestData(profileId: _profileController.text.trim(), date: _selectedDate),
    );
  }

  @override
  void dispose() {
    _profileController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final first = DateTime(now.year - 2);
    final last = DateTime(now.year + 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _fetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('yyyy-MM-dd').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Metabolism Tests'),
      ),
      body: Column(
        children: [
          // Controls
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _profileController,
                    decoration: const InputDecoration(
                      labelText: 'Profile ID',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _fetch(),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _pickDate,
                  child: Text(dateLabel),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _fetch,
                  child: const Text('Fetch'),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: BlocBuilder<TestDataBloc, TestDataState>(
              builder: (context, state) {
                if (state is TestDataLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TestDataError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else if (state is TestDataEmpty) {
                  return const Center(child: Text('No data for selected date.'));
                } else if (state is TestDataLoaded) {
                  return TestDataList(records: state.records);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
