import 'package:mycoronamovement/models/recoil.dart';
import 'package:mycoronamovement/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';

class PickDataRange extends HookWidget {
  @override
  Widget build(BuildContext context) {
    var fromDate = useModel(dataDateSelector);
    var availableData = useModel(availableDataSelector);
    var getAvailableStepsForDate = useAction(getAvailableStepsForDateAction);
    var setLastFetch = useAction(setLastFetchAction);
    useEffect(() {
      getAvailableStepsForDate();
    }, [fromDate.value]);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(25),
              child: SvgPicture.asset(
                'assets/svg/date.svg',
                height: 150,
              ),
            ),
            Text(
              'Från när ska vi hämta din hälsodata? ',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('${fromDate.value.toString().substring(0, 10)}'),
                OutlineButton(
                  child: Text('Ändra startdatum'),
                  onPressed: () async {
                    var date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.parse('2018-01-01'),
                      firstDate: DateTime.parse('2016-01-01'),
                      lastDate: DateTime.now(),
                    );
                    fromDate.value = date;
                    print(date);
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Du har ${availableData.length} datapunkter tillgängliga från det här datumet',
            ),
            SizedBox(height: 25),
            RaisedButton(
              child: Text('Analysera min data'),
              onPressed: () async {
                setLastFetch();
              },
            ),
          ],
        ),
      ),
    );
  }
}
