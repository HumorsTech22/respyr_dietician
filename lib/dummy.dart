import 'package:flutter/material.dart';

class Dummy extends StatefulWidget {
  const Dummy({super.key});

  @override
  State<Dummy> createState() => _DummyState();
}

class _DummyState extends State<Dummy> {
  final ScrollController _scrollController = ScrollController();

  // Keys for the sections
  final gutKey = GlobalKey();
  final fatKey = GlobalKey();
  final liverKey = GlobalKey();

  // Scroll to a given section
  void _scrollTo(GlobalKey key) {
    final contextBox = key.currentContext;
    if (contextBox != null) {
      final box = contextBox.findRenderObject() as RenderBox;
      final position =
          box.localToGlobal(Offset.zero, ancestor: null).dy +
          _scrollController.offset;

      _scrollController.animateTo(
        position - 100, // adjust offset to leave space for AppBar/TabBar
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scrollable Tabs")),
      body: Column(
        children: [
          // Fake TabBar (3 tabs)
          Container(
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => _scrollTo(gutKey),
                  child: const Text("Gut"),
                ),
                TextButton(
                  onPressed: () => _scrollTo(fatKey),
                  child: const Text("Fat"),
                ),
                TextButton(
                  onPressed: () => _scrollTo(liverKey),
                  child: const Text("Liver"),
                ),
              ],
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  _buildSection(
                    gutKey,
                    "Gut Fermentation Metabolism",
                    Colors.orange,
                  ),
                  _buildSection(
                    fatKey,
                    "Glucose vs Fat Metabolism",
                    Colors.green,
                  ),
                  _buildSection(
                    liverKey,
                    "Liver Hepatic Metabolism",
                    Colors.purple,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(GlobalKey key, String title, Color color) {
    return Container(
      key: key,
      height: 400,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
