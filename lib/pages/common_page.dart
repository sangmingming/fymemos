import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fymemos/utils/l10n.dart';

class LoadingPage extends StatelessWidget {

  LoadingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator());
  }
}

class ErrorPage extends StatelessWidget {
  final String error;
  const ErrorPage({required this.error, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(error);
  }
}

class EmptyPage extends StatelessWidget {
  const EmptyPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 80),
          SvgPicture.asset('assets/image/empty.svg', width: 160, height: 160),
          Text(context.intl.empty_tips),
        ],
      ),
    );
  }
}
