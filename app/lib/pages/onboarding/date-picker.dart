import 'package:wfhmovement/api/responses.dart';
import 'package:wfhmovement/i18n.dart';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:wfhmovement/style.dart';
import 'package:wfhmovement/widgets/button.dart';

final specialDeletePeriod = DatePeriod(null, null);

class DatePicker extends HookWidget {
  final Function(BuildContext, List<DatePeriod>) onDone;
  final List<DatePeriod> initialPeriods;

  DatePicker({
    Key key,
    this.onDone,
    this.initialPeriods,
  }) : super(key: key);

  Widget build(BuildContext context) {
    var periods = useState(
      initialPeriods != null ? initialPeriods : <DatePeriod>[],
    );

    return Scaffold(
      appBar: AppWidgets.appBar(context: context, title: 'Pick periods'.i18n),
      body: _body(context, periods),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.done),
        onPressed: () {
          onDone(context, periods.value);
        },
      ),
    );
  }

  final dayColor = Color.fromARGB(50, 0, 0, 0);

  Widget _body(BuildContext context, ValueNotifier<List<DatePeriod>> periods) {
    double width = MediaQuery.of(context).size.width;
    double dayWidth = width * 0.5 / 7;
    DateTime startDay = DateTime(2019, 12, 30);
    int numWeeks = (DateTime.now().difference(startDay).inDays / 7).ceil();

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Text('When have you been working from home?'.i18n),
          ),
          Stack(
            children: [
              Container(width: width, height: numWeeks * dayWidth),
              _months(context),
              Positioned(
                left: width * 0.13,
                child: _days(context, periods),
              ),
              Positioned(
                left: width * 0.13,
                child: _periods(context, periods),
              ),
              _events(context),
            ],
          ),
        ],
      ),
    );
  }

  List<DatePeriod> mergePeriods(List<DatePeriod> periods) {
    if (periods.length <= 1) return periods;

    periods.sort((a, b) => a.from.compareTo(b.from));

    var merged = <DatePeriod>[];
    var from = periods[0].from;
    var to = periods[0].to;
    var i = 1;

    do {
      if (to == null) {
        to = null;
        break;
      }
      if (periods[i].from.isBefore(to) ||
          periods[i].from.isAtSameMomentAs(to)) {
        to = periods[i].to == null || periods[i].to.isAfter(to)
            ? periods[i].to
            : to;
      } else {
        merged.add(DatePeriod(from, to));
        from = periods[i].from;
        to = periods[i].to;
      }
      i++;
    } while (i < periods.length);
    merged.add(DatePeriod(from, to));

    return merged;
  }

  void _addToPeriods(BuildContext context,
      ValueNotifier<List<DatePeriod>> periods, DateTime startDate) async {
    var period = await showDialog(
      context: context,
      builder: (context) => AddPeriodDialog(
        from: startDate,
      ),
    );
    if (period != null) {
      periods.value = mergePeriods([...periods.value, period]);
    }
  }

  void _editPeriodInPeriods(BuildContext context,
      ValueNotifier<List<DatePeriod>> periods, DatePeriod period) async {
    var newPeriod = await showDialog(
      context: context,
      builder: (context) => EditPeriodDialog(
        from: period.from,
        to: period.to,
      ),
    );
    if (newPeriod == specialDeletePeriod) {
      periods.value =
          periods.value.where((element) => element != period).toList();
    } else if (newPeriod != null) {
      periods.value = mergePeriods(periods.value
          .map<DatePeriod>((p) => p == period ? newPeriod : p)
          .toList());
    }
  }

  Widget _months(context) {
    double dayWidth = MediaQuery.of(context).size.width * 0.52 / 7;
    double width = MediaQuery.of(context).size.width * 0.13;
    DateTime startDay = DateTime(2019, 12, 30);
    int numWeeks = (DateTime.now().difference(startDay).inDays / 7).ceil();

    List<Widget> children = [];

    for (var i = 0; i < numWeeks; i++) {
      var weekday = startDay.add(Duration(days: i * 7));
      var d = int.parse(DateFormat('d').format(weekday));
      if (d <= 16 && d + 7 > 16) {
        children.add(
          Positioned(
            top: i * dayWidth,
            child: Container(
              width: width,
              height: dayWidth,
              child: Center(
                child: Text(
                  DateFormat('MMM').format(weekday),
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
        );
      }
      var year = DateFormat('yyyy').format(weekday);
      var yearNextWeek =
          DateFormat('yyyy').format(weekday.add(Duration(days: 7)));
      if (year != yearNextWeek) {
        children.add(
          Positioned(
            top: i * dayWidth,
            child: Container(
              width: width,
              height: dayWidth,
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: dayColor))),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  year,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
        );
        children.add(
          Positioned(
            top: (i + 1) * dayWidth,
            child: Container(
              width: width,
              height: dayWidth,
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  yearNextWeek,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
        );
      }
    }

    return Container(
      width: width,
      height: dayWidth * numWeeks,
      child: Stack(
        children: children,
      ),
    );
  }

  Widget _days(context, ValueNotifier<List<DatePeriod>> periods) {
    double width = MediaQuery.of(context).size.width * 0.52;
    DateTime startDay = DateTime(2019, 12, 30);
    double dayWidth = width / 7;
    int numWeeks = (DateTime.now().difference(startDay).inDays / 7).ceil();

    List<Widget> children = [];

    for (var i = 0; i < 7 * numWeeks; i++) {
      final date = startDay.add(Duration(days: i));
      if (date.isAfter(DateTime.now())) break;
      children.add(Positioned(
        left: (i % 7) * dayWidth,
        top: (i / 7).floor() * dayWidth,
        child: GestureDetector(
          onTap: () async {
            _addToPeriods(context, periods, date);
          },
          child: Container(
            width: dayWidth,
            height: dayWidth,
            decoration: BoxDecoration(border: _numBorder(date, i % 7)),
            child: Center(
              child: Text(
                DateFormat('d').format(date),
                style: TextStyle(color: dayColor, fontSize: 12),
              ),
            ),
          ),
        ),
      ));
    }

    return Container(
      width: width,
      height: dayWidth * numWeeks,
      child: Stack(
        children: children,
      ),
    );
  }

  BoxBorder _numBorder(DateTime day, int dow) {
    String month = DateFormat('M').format(day);
    String monthBelow = DateFormat('M').format(day.add(Duration(days: 7)));
    String monthRight = DateFormat('M').format(day.add(Duration(days: 1)));
    BorderSide bottom =
        month == monthBelow ? BorderSide.none : BorderSide(color: dayColor);
    BorderSide right = month == monthRight || dow == 6
        ? BorderSide.none
        : BorderSide(color: dayColor);
    return Border(bottom: bottom, right: right);
  }

  Widget _periods(context, ValueNotifier<List<DatePeriod>> periods) {
    double width = MediaQuery.of(context).size.width * 0.52;
    DateTime startDay = DateTime(2019, 12, 30);
    double dayWidth = width / 7;
    int numWeeks = (DateTime.now().difference(startDay).inDays / 7).ceil();

    List<Widget> children = [];

    for (DatePeriod period in periods.value) {
      var beginning = period.from.difference(startDay).inDays;
      var start = beginning;
      var end = (period.to ?? DateTime.now()).difference(startDay).inDays;

      var eow;
      do {
        var weekIndex = (start / 7).floor();
        eow = start + (6 - (start % 7));
        if (eow > end) eow = end;

        var radius = Radius.circular(dayWidth / 2);
        var startRadius = start == beginning ? radius : Radius.zero;
        var endRadius = eow == end && period.to != null ? radius : Radius.zero;

        children.add(Positioned(
          left: (start % 7) * dayWidth,
          top: weekIndex * dayWidth,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () async {
              _editPeriodInPeriods(context, periods, period);
            },
            child: Container(
              width: (eow - start + 1) * dayWidth,
              height: dayWidth,
              padding: EdgeInsets.symmetric(vertical: dayWidth / 4),
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(102, 245, 195, 68),
                  borderRadius: BorderRadius.only(
                    topLeft: startRadius,
                    bottomLeft: startRadius,
                    topRight: endRadius,
                    bottomRight: endRadius,
                  ),
                ),
              ),
            ),
          ),
        ));
        start = eow + 1;
      } while (eow < end);
    }

    return Container(
      width: width,
      height: dayWidth * numWeeks,
      child: Stack(
        children: children,
      ),
    );
  }

  Widget _events(context) {
    double width = MediaQuery.of(context).size.width * 0.37;
    return Container(
      width: width,
    );
  }
}

class AddPeriodDialog extends PeriodDialog {
  AddPeriodDialog({from, to})
      : super(
          from: from,
          to: to,
          title: 'Add period'.i18n,
          leftButtonText: 'Cancel'.i18n,
          rightButtonText: 'Add'.i18n,
          leftButtonDanger: false,
        );
}

class EditPeriodDialog extends PeriodDialog {
  EditPeriodDialog({from, to})
      : super(
          from: from,
          to: to,
          title: 'Change period'.i18n,
          leftButtonText: 'Remove'.i18n,
          rightButtonText: 'Save'.i18n,
          leftButtonDanger: true,
        );
}

class PeriodDialog extends HookWidget {
  final DateTime from;
  final DateTime to;
  final String title;
  final String leftButtonText;
  final String rightButtonText;
  final bool leftButtonDanger;

  PeriodDialog(
      {this.from,
      this.to,
      @required this.title,
      @required this.leftButtonText,
      @required this.rightButtonText,
      @required this.leftButtonDanger});

  Widget build(BuildContext context) {
    var dialogFrom = useState(from);
    var dialogTo = useState<DateTime>(to);

    return SimpleDialog(
      contentPadding: EdgeInsets.all(10),
      children: [
        _dialogTitle(title),
        SizedBox(height: 22),
        _dialogLabel('From'.i18n),
        _dialogDate(
          context,
          date: dialogFrom.value,
          last: dialogTo.value,
          onChanged: (date) {
            dialogFrom.value = date;
          },
        ),
        SizedBox(height: 32),
        _dialogLabel('To'.i18n),
        _dialogDate(
          context,
          date: dialogTo.value,
          first: dialogFrom.value,
          onChanged: (date) {
            dialogTo.value = date;
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 30, 0, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StyledButton(
                onPressed: () {
                  Navigator.pop(
                      context, leftButtonDanger ? specialDeletePeriod : null);
                },
                title: leftButtonText,
                small: true,
                secondary: !leftButtonDanger,
                danger: leftButtonDanger,
              ),
              SizedBox(width: 5),
              StyledButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    DatePeriod(dialogFrom.value, dialogTo.value),
                  );
                },
                title: rightButtonText,
                small: true,
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _dialogTitle(text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _dialogLabel(text) {
    return Text(text, style: TextStyle(fontSize: 12));
  }

  Widget _dialogDate(context,
      {DateTime date, DateTime first, DateTime last, onChanged}) {
    return GestureDetector(
      onTap: () async {
        var newDate = await showDatePicker(
            context: context,
            initialDate: date != null ? date : DateTime.now(),
            firstDate: first ?? DateTime(2020, 1, 1),
            lastDate: last ?? DateTime.now());
        if (newDate != null) {
          onChanged(newDate);
        }
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
            border: Border.all(
          color: Colors.black,
          width: 1,
        )),
        child: Center(
          child: Text(date != null
              ? DateFormat('yyyy-MM-dd').format(date)
              : 'ongoing'.i18n),
        ),
      ),
    );
  }
}
