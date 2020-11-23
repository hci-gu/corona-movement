import 'package:country_list_pick/country_list_pick.dart';
import 'package:wfhmovement/api/api.dart';
import 'package:wfhmovement/models/user_model.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wfhmovement/pages/onboarding/user_form.dart';
import 'package:wfhmovement/widgets/button.dart';

import '../style.dart';

class GroupCode extends HookWidget {
  @override
  Widget build(BuildContext context) {
    User user = useModel(userAtom);
    var joinGroup = useAction(joinGroupAction);
    var leaveGroup = useAction(leaveGroupAction);

    if (user.group != null) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: UserFormField(
              name: 'Company code',
              headerInfo: _info(context),
              child: Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  user.group.name,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
          _disconnectCompanyButton(user, leaveGroup),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: UserFormField(
            name: 'Company code',
            headerInfo: _info(context),
            child: _freeForm(
              user.groupCode,
              user.setGroupCode,
            ),
          ),
        ),
        _verifyCodeButton(user, joinGroup),
      ],
    );
  }

  Widget _info(BuildContext context) {
    return GestureDetector(
      onTap: () => AppWidgets.showAlert(
        context,
        'Joining a company',
        'If you have a code you can enter it here to join a company.\n\nIf you\'re interested in trying out this feature within your company feel free to contact us at sebastian.andreasson@ait.gu.se',
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 5),
        child: Icon(
          Icons.info_outline,
          size: 20,
        ),
      ),
    );
  }

  Widget _verifyCodeButton(User user, joinGroup) {
    return Padding(
      padding: EdgeInsets.only(top: 40),
      child: StyledButton(
        icon: Icons.done,
        title: 'Verify',
        onPressed: () {
          if (!user.loading) joinGroup();
        },
        tiny: true,
      ),
    );
  }

  Widget _disconnectCompanyButton(User user, leaveGroup) {
    return Padding(
      padding: EdgeInsets.only(top: 40),
      child: StyledButton(
        icon: Icons.close,
        secondary: true,
        title: 'Remove',
        onPressed: () {
          if (!user.loading) leaveGroup();
        },
        tiny: true,
      ),
    );
  }

  Widget _freeForm(String value, onChange) {
    final controller = useTextEditingController(text: value);

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Code to join a company (optional)',
      ),
      onChanged: (val) => onChange(val),
    );
  }
}
