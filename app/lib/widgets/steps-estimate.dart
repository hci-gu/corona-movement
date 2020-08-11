import 'package:wfhmovement/models/user_model.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wfhmovement/widgets/button.dart';

class StepsEstimate extends HookWidget {
  @override
  Widget build(BuildContext context) {
    User user = useModel(userAtom);
    var updateEstimate = useAction(updateEstimateAction);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25),
      child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: user.gaveEstimate
                ? gaveEstimate(context, user)
                : giveEstimate(context, user, updateEstimate)),
      ),
    );
  }

  List<Widget> giveEstimate(BuildContext context, User user, updateEstimate) {
    return [
      Text(
        'While your steps are being uploaded, please use the slider below to give an estimate of how much you think your average daily steps have changed.',
      ),
      Slider(
        value: user.stepsEstimate,
        min: -1,
        max: 2,
        divisions: 60,
        onChanged: (double value) {
          user.setStepsEstimate(value);
        },
      ),
      Text(
        textForEstimate(user.stepsEstimate),
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 20),
      StyledButton(
        icon: Icon(Icons.check),
        title: 'Set estimate',
        onPressed: () {
          user.setGaveEstimate(true);
          updateEstimate();
        },
      ),
    ];
  }

  List<Widget> gaveEstimate(BuildContext context, User user) {
    return [
      SizedBox(height: 20),
      Text(
        'You estimated a change of ${user.stepsEstimate.toStringAsFixed(1)}%.',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 20),
      StyledButton(
        icon: Icon(Icons.undo),
        title: 'Redo estimate',
        onPressed: () => user.setGaveEstimate(false),
      ),
    ];
  }

  String textForEstimate(double estimate) {
    if (estimate == 0) {
      return 'No change';
    }
    return '${estimate > 0 ? 'An increase' : 'A decrease'} of ${(estimate * 100).toStringAsFixed(1)}%';
  }
}
