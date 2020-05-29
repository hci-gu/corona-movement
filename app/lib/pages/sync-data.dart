import 'package:mycoronamovement/models/recoil.dart';
import 'package:mycoronamovement/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';

class SyncData extends HookWidget {
  @override
  Widget build(BuildContext context) {
    var pendingHealthDataPoints = useModel(pendingDataPointsSelector);
    var getSteps = useAction(getStepsAction);
    useMemoized(() {
      getSteps();
    });

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(25),
              child: SvgPicture.asset(
                'assets/svg/data.svg',
                height: 150,
              ),
            ),
            Text(
              'Analyserar din hälsodata...',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            if (pendingHealthDataPoints != null &&
                pendingHealthDataPoints.length > 0)
              Text(
                'Synkar: ${pendingHealthDataPoints.length} datapunkter kvar',
                textAlign: TextAlign.center,
              )
          ],
        ),
      ),
    );
  }
}
