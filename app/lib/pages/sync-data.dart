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
                      ? 'Uploading your steps: ${onboarding.dataChunks.length} uploads left.'
                      : 'Upload done.',
                  maxLines: 1,
                ),
              ),
            ],
          ),
          Text(
            isUploading
                ? 'While your steps are uploading, please fill in the information below.'
                : 'Your upload is complete, please finish filling in the form below to proceed.',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),
          if (step.value == 0) UserForm(),
          if (step.value == 1) StepsEstimate(),
          SizedBox(height: 40),
          _formButtons(context, step, form, user),
        ],
      ),
    );
  }

  Widget _formButtons(BuildContext context, step, form, user) {
    bool formDone = useModel(formDoneSelector);
    var setUserFormData = useAction(setUserFormDataAction);

    Widget proceedButton = Opacity(
      opacity: step.value == 0 && formDone || user.gaveEstimate ? 1.0 : 0.5,
      child: form.loading
          ? Center(child: CircularProgressIndicator())
          : StyledButton(
              icon: Icon(
                step.value == 0 ? Icons.arrow_forward : Icons.done,
              ),
              title: step.value == 0 ? 'Next' : 'Done',
              onPressed: () {
                if (formDone) {
                  if (step.value == 0) {
                    step.value++;
                    return;
                  }
                  if (step.value == 1) {
                    setUserFormData();
                  }
                  return;
                }
                AppWidgets.showAlert(
                  context,
                  'Form not completed',
                  'Please fill out the fields above to proceed.',
                );
              },
            ),
    );
    if (step.value == 0) return proceedButton;

    return Row(
      children: [
        StyledButton(
          icon: Icon(Icons.arrow_back),
          title: 'Back',
          onPressed: () {
            step.value = 0;
          },
          small: true,
        ),
        SizedBox(width: 10),
        proceedButton,
      ],
    );
  }
}
