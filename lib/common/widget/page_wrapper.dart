import 'package:flutter/material.dart';

class PageWrapper extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  const PageWrapper({super.key, required this.child, this.title, this.bottomNavigationBar, this.floatingActionButton});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null ? null : AppBar(title: Text(title!)),
      body: SafeArea(child: child),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
