import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';

/// A plain text field in a dialog: where to go or what to search for.
/// Placeholder for the search screen of milestone 5, so milestone 2 can open
/// real pages. Returns the text, or null when cancelled.
Future<String?> showAddressPrompt(BuildContext context, {String initial = ''}) {
  return showDialog<String>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context);
      final controller = TextEditingController(
        text: initial,
      )..selection = TextSelection(baseOffset: 0, extentOffset: initial.length);
      return AlertDialog(
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.go,
          autocorrect: false,
          decoration: InputDecoration(hintText: l10n.searchOrEnterAddress),
          onSubmitted: (text) => Navigator.of(context).pop(text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      );
    },
  );
}
