import 'package:flutter/material.dart';

class CommonAppbar extends StatefulWidget {
  final VoidCallback onBackButtonPress;
  const CommonAppbar({super.key, required this.onBackButtonPress});

  @override
  State<CommonAppbar> createState() => _CommonAppbarState();
}

class _CommonAppbarState extends State<CommonAppbar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(

    );
  }
}
