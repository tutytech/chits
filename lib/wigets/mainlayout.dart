import 'package:flutter/material.dart';
import 'customdrawer.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String rights; // Pass user rights

  const MainLayout({Key? key, required this.child, required this.rights})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      drawer: CustomDrawer(rights: rights),
      body: child,
    );
  }
}
