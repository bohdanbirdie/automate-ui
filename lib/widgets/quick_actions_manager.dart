import 'package:automate_ui/pages/media/media_page.dart';
import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';

class QuickActionsManager extends StatefulWidget {
  final Widget child;

  QuickActionsManager({Key key, this.child}) : super(key: key);

  @override
  _QuickActionsManagerState createState() => _QuickActionsManagerState();
}

class _QuickActionsManagerState extends State<QuickActionsManager> {
  final QuickActions quickActions = QuickActions();

  @override
  void initState() {
    super.initState();
    _setupQuickActions();
    _handleQuickActions();
  }

  void _setupQuickActions() {
    quickActions.setShortcutItems(<ShortcutItem>[
      ShortcutItem(
          type: 'action_main', localizedTitle: 'Main view', icon: 'QuickBox'),
      ShortcutItem(
          type: 'action_help', localizedTitle: 'Help', icon: 'QuickHeart')
    ]);
  }

  void _handleQuickActions() {
    quickActions.initialize((shortcutType) {
      print('shortcutType $shortcutType');
      if (shortcutType == 'action_main') {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MediaPage()));
      } else if (shortcutType == 'action_help') {
        print('Show the help dialog!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
