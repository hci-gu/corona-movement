import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/models/steps.dart';
import 'package:wfhmovement/style.dart';
import 'package:wfhmovement/widgets/button.dart';

class DaySelect extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: StyledButton(
        title: 'Change days',
        icon: Icon(Icons.arrow_drop_down),
        onPressed: () => _onPressed(context),
      ),
    );
  }

  _onPressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select the days to display steps from.'),
          content: DaySelectDialog(),
          actions: [
            OutlineButton(
              child: Text(
                'Close',
                style: TextStyle(
                  color: AppColors.secondary,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}

class DaySelectDialog extends HookWidget {
  @override
  Widget build(BuildContext context) {
    StepsModel steps = useModel(stepsAtom);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children:
          StepsModel.weekdays.map((day) => _daySelect(steps, day)).toList(),
    );
  }

  Widget _daySelect(StepsModel steps, Map<String, dynamic> day) {
    return Row(
      children: [
        SizedBox(
          height: 30,
          width: 30,
          child: Checkbox(
            value: steps.days.contains(day['value']),
            onChanged: (value) {
              steps.updateDays(day['value'], value);
            },
          ),
        ),
        Text(day['display']),
      ],
    );
  }
}
