import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/models/user_model.dart';

class LanguageSelect extends HookWidget {
  GlobalKey _key = LabeledGlobalKey("button_icon");
  Offset buttonPosition;
  Size buttonSize;
  AnimationController _animationController;
  OverlayEntry _overlayEntry;
  List<String> languages = ['🇸🇪', '🇬🇧'];
  final bool inAppBar;

  LanguageSelect({
    this.inAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    var isOpen = useState(false);
    _animationController = useAnimationController(
      duration: Duration(milliseconds: 300),
    );
    User user = useModel(userAtom);
    var setUserLanguageOverride = useAction(setUserLanguageOverrideAction);
    Locale currentLocale = I18n.of(context).locale ?? Locale('en');
    String flag = currentLocale.languageCode == 'en' ? '🇬🇧' : '🇸🇪';

    return Container(
      key: _key,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          if (!inAppBar)
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(0, 1),
            ),
        ],
      ),
      child: IconButton(
        icon: Text(
          flag,
          style: TextStyle(fontSize: 24),
        ),
        color: Colors.white,
        onPressed: () {
          if (isOpen.value) {
            this.close(isOpen);
          } else {
            this.open(context, user, setUserLanguageOverride, isOpen);
          }
        },
      ),
    );
  }

  open(BuildContext context, User user, setUserLanguageOverride, isOpen) {
    findButton();
    _animationController.forward();
    _overlayEntry = _overlayEntryBuilder(user, setUserLanguageOverride, isOpen);
    Overlay.of(context).insert(_overlayEntry);
    isOpen.value = true;
  }

  close(isOpen) {
    _overlayEntry.remove();
    _animationController.reverse();
    isOpen.value = false;
  }

  findButton() {
    RenderBox renderBox = _key.currentContext.findRenderObject();
    buttonSize = renderBox.size;
    buttonPosition = renderBox.localToGlobal(Offset.zero);
  }

  OverlayEntry _overlayEntryBuilder(
      User user, setUserLanguageOverride, isOpen) {
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          top: buttonPosition.dy + buttonSize.height,
          left: buttonPosition.dx - (inAppBar ? 10 : 0),
          width: buttonSize.width,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 3,
                          blurRadius: 3,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(languages.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            Locale selectedLocale = languages[index] == '🇸🇪'
                                ? Locale('sv')
                                : Locale('en');
                            user.languageOverride = selectedLocale.languageCode;
                            I18n.of(context).locale = selectedLocale;
                            setUserLanguageOverride();
                            this.close(isOpen);
                          },
                          child: Container(
                            width: buttonSize.width,
                            height: buttonSize.height,
                            alignment: Alignment.center,
                            child: Text(
                              languages[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
