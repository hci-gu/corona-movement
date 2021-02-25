import 'package:wfhmovement/config.dart';
import 'package:wfhmovement/i18n.dart';

import 'package:country_list_pick/country_list_pick.dart';
import 'package:wfhmovement/models/form_model.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wfhmovement/widgets/group_code.dart';

class UserFormField extends StatelessWidget {
  final Widget child;
  final Widget headerInfo;
  final String name;

  UserFormField({
    Key key,
    @required this.child,
    @required this.name,
    this.headerInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (headerInfo != null) headerInfo,
            ],
          ),
          child,
        ],
      ),
    );
  }
}

class UserForm extends HookWidget {
  @override
  Widget build(BuildContext context) {
    FormModel form = useModel(formAtom);

    return Column(
      children: <Widget>[
        UserFormField(
          name: 'Country'.i18n,
          child: Row(children: [
            CountryListPick(
              isShowFlag: true,
              isShowTitle: true,
              isShowCode: false,
              isDownIcon: true,
              showEnglishName: false,
              initialSelection: '+46',
              onChanged: (CountryCode code) => form.setCountry(code.name),
            ),
          ]),
        ),
        if (EnvironmentConfig.APP_NAME == 'WFH Movement') ..._wfhFields(form),
        if (EnvironmentConfig.APP_NAME == 'SFH Movement') ..._sfhFields(form),
        GroupCode(key: Key('userForm')),
      ],
    );
  }

  List<Widget> _wfhFields(FormModel form) {
    return [
      UserFormField(
        name: 'Gender'.i18n,
        child: _dropDown(
            FormModel.genderChoices, 'gender', form.gender, form.setField),
      ),
      UserFormField(
        name: 'Age range'.i18n,
        child: _dropDown(
            FormModel.ageRanges, 'ageRange', form.ageRange, form.setField),
      ),
      UserFormField(
        name: 'Education'.i18n,
        child: _dropDown(
            FormModel.educations, 'education', form.education, form.setField),
      ),
      UserFormField(
        name: 'Occupation'.i18n,
        child: _freeForm('occupation', form.occupation, form.setField),
      ),
    ];
  }

  List<Widget> _sfhFields(FormModel form) {
    return [
      UserFormField(
        name: 'Gender'.i18n,
        child: _dropDown(
            FormModel.genderChoices, 'gender', form.gender, form.setField),
      ),
      UserFormField(
        name: 'Age'.i18n,
        child: _freeForm('age', form.age, form.setField, int.parse),
      ),
    ];
  }

  Widget _dropDown(List values, String type, String value, onChange) {
    return DropdownButton(
      isExpanded: true,
      hint: Text('Please choose one'.i18n),
      items: [
        ...values
            .map((e) => DropdownMenuItem(child: Text(e), value: e))
            .toList(),
      ],
      value: value,
      onChanged: (val) => onChange(type, val),
    );
  }

  Widget _freeForm(String type, value, onChange, [parseFunction]) {
    final controller = useTextEditingController(text: value.toString());

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Your %s (optional)'.i18n.fill([type]),
      ),
      onChanged: (val) {
        if (parseFunction != null) {
          onChange(type, parseFunction(val));
        } else {
          onChange(type, val);
        }
      },
    );
  }
}
