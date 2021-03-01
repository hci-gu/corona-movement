import 'package:wfhmovement/i18n.dart';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wfhmovement/global-analytics.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/models/steps/daysFilter.dart';
import 'package:wfhmovement/models/steps/steps.dart';
import 'package:wfhmovement/widgets/button.dart';

class DaySelect extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: StyledButton(
        title: 'Change days'.i18n,
        icon: Icons.arrow_drop_down,
        onPressed: () => _onPressed(context),
      ),
    );
  }

  _onPressed(BuildContext context) {
    globalAnalytics.sendEvent('showDaySelect');
    showDialog(
      useSafeArea: false,
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DaySelectDialog(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DaySelectDialog extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final animationController =
        useAnimationController(duration: Duration(milliseconds: 300));
    final _offsetAnimation =
        Tween<Offset>(begin: Offset(0.0, 1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOut,
      ),
    );
    animationController.forward();

    return SlideTransition(
      position: _offsetAnimation,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
          color: Colors.white,
        ),
        width: 5000,
        height: 120,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: DayFilterModel.weekdays
                .map((day) => DaySelectInput(day))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class DaySelectInput extends HookWidget {
  final Map<String, dynamic> day;

  DaySelectInput(this.day);

  @override
  Widget build(BuildContext context) {
    DayFilterModel dayFilter = useModel(dayFilterAtom);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(day['display'].substring(0, 3)),
        SizedBox(
          height: 48,
          width: 48,
          child: Checkbox(
            materialTapTargetSize: MaterialTapTargetSize.padded,
            value: dayFilter.days.contains(day['value']),
            onChanged: (value) {
              dayFilter.updateDays(day['value'], value);
            },
          ),
        ),
      ],
    );
  }
}
