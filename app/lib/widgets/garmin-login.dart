import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wfhmovement/models/garmin.dart';
import 'package:wfhmovement/models/recoil.dart';

class GarminLogin extends HookWidget {
  @override
  Widget build(BuildContext context) {
    GarminModel garmin = useModel(garminAtom);
    var username = useTextEditingController(text: garmin.username);
    var password = useTextEditingController(text: garmin.password);

    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          TextField(
            controller: username,
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) {
              garmin.setUsername(value);
            },
            decoration: InputDecoration(
              hintText: 'Email',
            ),
          ),
          TextField(
            controller: password,
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            onChanged: (value) {
              garmin.setPassword(value);
            },
            decoration: InputDecoration(
              hintText: 'Password',
            ),
          )
        ],
      ),
    );
  }
}
