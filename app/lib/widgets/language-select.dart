import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:i18n_extension/i18n_widget.dart';

class LanguageSelect extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      child: DropdownButton(
        underline: null,
        items: [
          DropdownMenuItem(
            child: Text('🇸🇪'),
            value: Locale('sv', 'SE'),
          ),
          DropdownMenuItem(
            child: Text('🇬🇧'),
            value: Locale('en', 'GB'),
          )
        ],
        value: I18n.of(context).locale ?? Locale('en', 'GB'),
        onChanged: (val) {
          I18n.of(context).locale = val;
        },
      ),
    );
  }
}
