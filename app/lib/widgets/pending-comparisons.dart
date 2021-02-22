import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wfhmovement/api/responses.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/models/steps/steps.dart';

class PendingComparisons extends HookWidget {
  @override
  Widget build(BuildContext context) {
    HealthComparison comparison = useModel(stepsComparisonSelector);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: comparison.pendingComparisons.map(
          (HealthSummary summary) {
            return Text(
              'The comparison with ${summary.name} will show up here once enough people have joined the group.',
              style: TextStyle(),
              textAlign: TextAlign.center,
            );
          },
        ).toList(),
      ),
    );
  }
}
