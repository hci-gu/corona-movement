import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/models/user_model.dart';
import 'package:wfhmovement/style.dart';
import 'package:wfhmovement/widgets/steps-difference.dart';

class Settings extends HookWidget {
  @override
  Widget build(BuildContext context) {
    User user = useModel(userAtom);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.primaryText,
          ),
        ),
      ),
      body: Container(
        child: ListView(
          padding: EdgeInsets.only(top: 25),
          children: [
            Text(user.id),
          ],
        ),
      ),
    );
  }
}
