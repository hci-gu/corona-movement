import 'package:wfhmovement/i18n/onboarding/sync-data.i18n.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:wfhmovement/models/form_model.dart';
import 'package:wfhmovement/models/onboarding_model.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wfhmovement/models/user_model.dart';
import 'package:wfhmovement/pages/onboarding/user_form.dart';
import 'package:wfhmovement/style.dart';
import 'package:wfhmovement/widgets/button.dart';
import 'package:wfhmovement/widgets/main_scaffold.dart';
import 'package:wfhmovement/widgets/steps-estimate.dart';

class SyncData extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final step = useState(0);
    User user = useModel(userAtom);
    OnboardingModel onboarding = useModel(onboardingAtom);
    FormModel form = useModel(formAtom);

    bool isUploading =
        onboarding.dataChunks != null && onboarding.dataChunks.length > 0;

    return MainScaffold(
      displaySnackbars: true,
      child: ListView(
        padding: EdgeInsets.only(bottom: 125, top: 40, left: 25, right: 25),
        children: <Widget>[
          Row(
            children: [
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 10, right: 10),
                child: SvgPicture.asset(
                  'assets/svg/data.svg',
                  height: 40,
                ),
              ),
              Expanded(
                child: AutoSizeText(
                  isUploading
                      ? 'Uploading your steps: %d uploads left.'
                          .i18n
                          .plural(onboarding.dataChunks.length)
                      : 'Upload done.'.i18n,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          if (step.value == 0) UserForm(),
          if (step.value == 1) StepsEstimate(),
          SizedBox(height: 40),
          _formButtons(context, onboarding, step, form, user),
        ],
      ),
    );
  }

  Widget _formButtons(BuildContext context, onboarding, step, form, user) {
    bool formDone = useModel(formDoneSelector);
    bool done = formDone && user.gaveEstimate && !onboarding.uploading;
    var setUserFormData = useAction(setUserFormDataAction);

    Widget proceedButton = Opacity(
      opacity: step.value == 0 && formDone || done ? 1.0 : 0.5,
      child: form.loading
          ? Center(child: CircularProgressIndicator())
          : StyledButton(
              icon: step.value == 0 ? Icons.arrow_forward : Icons.done,
              title: step.value == 0 ? 'Next'.i18n : 'Done'.i18n,
              onPressed: () {
                if (formDone) {
                  if (step.value == 0) {
                    step.value++;
                    return;
                  }
                  if (!done) {
                    AppWidgets.showAlert(
                      context,
                      'Upload not finished'.i18n,
                      'Please wait until the upload has finished to proceed.'
                          .i18n,
                    );
                    return;
                  }
                  if (step.value == 1) {
                    setUserFormData();
                  }
                  return;
                }
                AppWidgets.showAlert(
                  context,
                  'Form not completed'.i18n,
                  'Please fill out the fields above to proceed.'.i18n,
                );
              },
            ),
    );
    if (step.value == 0) return proceedButton;

    return Row(
      children: [
        StyledButton(
          icon: Icons.arrow_back,
          title: 'Back'.i18n,
          onPressed: () {
            step.value = 0;
          },
          small: true,
          secondary: true,
        ),
        SizedBox(width: 10),
        if (user.gaveEstimate) Flexible(child: proceedButton),
      ],
    );
  }
}
