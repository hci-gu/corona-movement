import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/models/user_model.dart';

import '../style.dart';

class JoinGroupMessage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final showJoinGroupSuccess = useState(false);
    User user = useModel(userAtom);

    useEffect(() {
      if (user.deeplinkOpen && user.group != null) {
        showJoinGroupSuccess.value = true;
      }
    }, [user.deeplinkOpen, user.group != null]);

    if (user.group == null || showJoinGroupSuccess.value == false)
      return Container();

    return GestureDetector(
      onTap: () {
        showJoinGroupSuccess.value = false;
      },
      child: Stack(
        children: [
          Positioned(
            child: Opacity(
              opacity: 0.25,
              child: Container(
                color: Colors.black,
              ),
            ),
          ),
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.8,
              heightFactor: 0.7,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(25),
                      child: SvgPicture.asset(
                        'assets/svg/success.svg',
                        height: 150,
                      ),
                    ),
                    Text(
                      'You have successfully joined ${user.group.name}!',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    AppWidgets.chartDescription(
                      'you can now see a comparison between you and the average of your group in "You vs others".\n\n Tap anywhere to dismiss this message.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
