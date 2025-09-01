import 'package:flet/flet.dart';

import 'flet_gnav_bar.dart';

CreateControlFactory createControl = (CreateControlArgs args) {
  switch (args.control.type) {
    case "flet_gnav_bar":
      return FletGNavBarControl(
        parent: args.parent,
        control: args.control,
        backend: args.backend,
      );
    case "flet_gnav_bar_button":
      return FletGNavBarButtonControl(
        parent: args.parent,
        control: args.control,
      );
    default:
      return null;
  }
};

void ensureInitialized() {
  // nothing to initialize
}
