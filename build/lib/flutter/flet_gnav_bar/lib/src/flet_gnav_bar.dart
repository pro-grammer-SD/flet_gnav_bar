import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flet/flet.dart';
import 'package:line_icons/line_icons.dart';

class FletGNavBarControl extends StatefulWidget {
  final Control? parent;
  final Control control;
  final FletControlBackend backend;

  const FletGNavBarControl(
      {super.key,
      required this.parent,
      required this.control,
      required this.backend});

  @override
  State<FletGNavBarControl> createState() => _FletGNavBarControlState();
}

class _FletGNavBarControlState extends State<FletGNavBarControl> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.control.attrInt("selectedIndex", 0) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final backendIndex = widget.control.attrInt("selectedIndex", 0) ?? 0;
    if (backendIndex != selectedIndex) {
      selectedIndex = backendIndex;
    }

    final jsonStr = widget.control.attrString("tabsData") ?? "[]";
    final List<dynamic> tabsData = jsonDecode(jsonStr);

    List<GButton> tabs = tabsData.map((tab) {
      return GButton(
        text: tab["text"] ?? "",
        icon: FletGNavBarButtonControl.getLineIcon(tab["icon"] ?? ""),
        gap: (tab["gap"] ?? 8).toDouble(),
        iconSize: (tab["iconSize"] ?? 24).toDouble(),
        textSize: (tab["textSize"] ?? 14).toDouble(),
        backgroundColor:
            FletGNavBarButtonControl.parseColor(tab["backgroundColor"]) ??
                Colors.transparent,
        iconColor: FletGNavBarButtonControl.parseColor(tab["iconColor"]) ??
            Colors.grey[400]!,
        iconActiveColor:
            FletGNavBarButtonControl.parseColor(tab["iconActiveColor"]) ??
                Colors.white,
        textColor: FletGNavBarButtonControl.parseColor(tab["textColor"]) ??
            Colors.white,
        onPressed: () {},
      );
    }).toList();

    Widget myControl = GNav(
      tabs: tabs,
      selectedIndex: selectedIndex,
      gap: widget.control.attrDouble("gap", 8) ?? 8,
      activeColor:
          widget.control.attrColor("activeColor", context) ?? Colors.white,
      color: widget.control.attrColor("color", context) ?? Colors.grey[400]!,
      rippleColor: widget.control.attrColor("rippleColor", context) ??
          Colors.transparent,
      hoverColor:
          widget.control.attrColor("hoverColor", context) ?? Colors.transparent,
      backgroundColor: widget.control.attrColor("backgroundColor", context) ??
          Colors.transparent,
      tabBackgroundColor:
          widget.control.attrColor("tabBackgroundColor", context) ??
              Colors.grey[800]!,
      tabBorderRadius: widget.control.attrDouble("tabBorderRadius", 100) ?? 100,
      iconSize: widget.control.attrDouble("iconSize") ?? 24,
      textSize: widget.control.attrDouble("textSize") ?? 14,
      onTabChange: (i) {
        setState(() => selectedIndex = i);
        widget.backend.updateControlState(
            widget.control.id, {"selectedIndex": i.toString()},
            client: true, server: true);
        widget.backend.triggerControlEvent(
          widget.control.id,
          "change",
          jsonEncode({"index": "$i"}),
        );
      },
    );

    return constrainedControl(
        context, myControl, widget.parent, widget.control);
  }
}

class FletGNavBarButtonControl extends StatefulWidget {
  final Control? parent;
  final Control control;

  const FletGNavBarButtonControl({
    super.key,
    this.parent,
    required this.control,
  });

  @override
  State<FletGNavBarButtonControl> createState() =>
      _FletGNavBarButtonControlState();

  static IconData getLineIcon(String name) {
    return LineIcons.byName(name.toLowerCase()) ?? Icons.help_outline;
  }

  static Color? parseColor(dynamic c) {
    if (c is String && c.startsWith("#")) {
      final hex = c.substring(1);
      final intColor = int.parse(hex, radix: 16);
      if (hex.length == 6) return Color(0xFF000000 | intColor);
      if (hex.length == 8) return Color(intColor);
    }
    return null;
  }
}

class _FletGNavBarButtonControlState extends State<FletGNavBarButtonControl> {
  @override
  Widget build(BuildContext context) {
    Widget myControl = GButton(
      text: widget.control.attrString("text") ?? "",
      icon: FletGNavBarButtonControl.getLineIcon(
          widget.control.attrString("icon") ?? ""),
      gap: widget.control.attrDouble("gap") ?? 8,
      iconSize: widget.control.attrDouble("iconSize") ?? 24,
      textSize: widget.control.attrDouble("textSize") ?? 14,
      backgroundColor: widget.control.attrColor("backgroundColor", context) ??
          Colors.transparent,
      iconColor:
          widget.control.attrColor("iconColor", context) ?? Colors.grey[400]!,
      iconActiveColor:
          widget.control.attrColor("iconActiveColor", context) ?? Colors.white,
      textColor: widget.control.attrColor("textColor", context) ?? Colors.white,
      onPressed: () {},
    );

    return constrainedControl(
        context, myControl, widget.parent, widget.control);
  }
}
