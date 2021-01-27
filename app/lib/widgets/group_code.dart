import 'package:wfhmovement/i18n/widgets/group_code.i18n.dart';

import 'package:wfhmovement/models/user_model.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wfhmovement/pages/onboarding/user_form.dart';
import 'package:wfhmovement/widgets/button.dart';

import '../style.dart';

class GroupCode extends HookWidget {
  final bool showInfo;

  GroupCode({
    Key key,
    this.showInfo = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user = useModel(userAtom);
    final controller = useTextEditingController(text: user.groupCode);
    var joinGroup = useAction(joinGroupAction);
    var leaveGroup = useAction(leaveGroupAction);

    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: user.group != null
          ? _groupWidget(context, user, leaveGroup)
          : _codeInput(context, user, controller, joinGroup),
    );
  }

  List<Widget> _codeInput(
      BuildContext context, User user, controller, joinGroup) {
    return [
      Flexible(
        child: UserFormField(
          name: 'Group code'.i18n,
          headerInfo: showInfo ? _info(context) : null,
          child: _freeForm(
            controller,
            user.setGroupCode,
          ),
        ),
      ),
      _verifyCodeButton(user, joinGroup),
    ];
  }

  List<Widget> _groupWidget(BuildContext context, User user, leaveGroup) {
    return [
      Flexible(
        child: UserFormField(
          name: 'Group',
          headerInfo: showInfo ? _info(context) : null,
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
    ];
  }

  Widget _info(BuildContext context) {
    return GestureDetector(
      onTap: () => AppWidgets.showAlert(
        context,
        'Joining a group'.i18n,
        'If you have a code you can enter it here to join a group. This allows you to compare with others in the same group.\n\nIf you are interested in trying out this feature with your group, company or organization, feel free to contact us at sebastian.andreasson@ait.gu.se'
            .i18n,
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
        key: Key('group-code-join'),
        icon: Icons.done,
        title: 'Join'.i18n,
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
        key: Key('group-code-leave'),
        icon: Icons.close,
        secondary: true,
        title: 'Leave'.i18n,
        onPressed: () {
          if (!user.loading) leaveGroup();
        },
        tiny: true,
      ),
    );
  }

  Widget _freeForm(controller, onChange) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Code to join a group (optional)'.i18n,
      ),
      onChanged: (val) => onChange(val),
    );
  }
}
