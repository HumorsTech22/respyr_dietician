import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/help_center/presentation/cubit/help_center_state.dart';
import '../cubit/help_center_cubit.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HelpCenterCubit, HelpCenterState>(
      builder: (context, state) {
        if (state is HelpCenterLoaded) {
          return Scaffold(
            appBar: AppBar(title: const Text("Help Center")),
            body: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "FAQ",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                ...List.generate(state.faqs.length, (index) {
                  return ExpansionPanelList(
                    expansionCallback: (panelIndex, isExpanded) {
                      context.read<HelpCenterCubit>().toggleFaq(index);
                    },
                    children: [
                      ExpansionPanel(
                        headerBuilder: (context, isExpanded) {
                          return ListTile(title: Text(state.faqs[index]));
                        },
                        body: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text("This is an example answer text."),
                        ),
                        isExpanded: state.expandedFaqs[index],
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.read<HelpCenterCubit>().switchTab(0);
                  },
                  child: const Text("Report An Issue"),
                ),
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
