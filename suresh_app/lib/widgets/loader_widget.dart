import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoaderWidget extends StatelessWidget {
  final double width;
  final double height;

  const LoaderWidget({
    Key? key,
    this.width = 200,
    this.height = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'loader.gif',
        width: width,
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }
}