import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flet/flet.dart';

class FletGNavBarControl extends StatefulWidget {
  final Control? parent;
  final Control control;
  final FletControlBackend backend;

  const FletGNavBarControl({
    super.key,
    required this.parent,
    required this.control,
    required this.backend,
  });

  @override
  State<FletGNavBarControl> createState() => _FletGNavBarControlState();
}

class _FletGNavBarControlState extends State<FletGNavBarControl> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.control.attrInt("selectedIndex") ?? 0;
  }

  Map<String, dynamic> normalize(Map<String, dynamic> raw) {
    final Map<String, dynamic> normalized = {};
    raw.forEach((key, value) {
      if (value is bool || value is num)
        normalized[key] = value.toString();
      else
        normalized[key] = value;
    });
    return normalized;
  }

  @override
  Widget build(BuildContext context) {
    try {
      final backendIndex = widget.control.attrInt("selectedIndex") ?? 0;
      if (backendIndex != selectedIndex) selectedIndex = backendIndex;

      final jsonStr = widget.control.attrString("tabsData") ?? "[]";
      final List<dynamic> tabsData = jsonDecode(jsonStr);

      List<Widget> tabs = tabsData.map((tabRaw) {
        final normalizedTab = normalize(tabRaw as Map<String, dynamic>);
        return constrainedControl(
          context,
          FletGNavBarButtonControl(
            control: Control.fromJson(normalizedTab),
            onPressed: () {
              final i = tabsData.indexOf(tabRaw);
              setState(() => selectedIndex = i);
              widget.backend.updateControlState(
                widget.control.id,
                {"selectedIndex": i.toString()},
                client: true,
                server: true,
              );
              widget.backend.triggerControlEvent(
                widget.control.id,
                "change",
                jsonEncode({"index": "$i"}),
              );
            },
          ),
          widget.parent,
          Control.fromJson(normalizedTab),
        );
      }).toList();

      return constrainedControl(
        context,
        GNav(
          tabs: tabs.cast<GButton>(),
          selectedIndex: selectedIndex,
          gap: widget.control.attrDouble("gap") ?? 8,
          activeColor:
              widget.control.attrColor("activeColor", context) ?? Colors.white,
          color:
              widget.control.attrColor("color", context) ?? Colors.grey[400]!,
          rippleColor: widget.control.attrColor("rippleColor", context) ??
              Colors.transparent,
          hoverColor: widget.control.attrColor("hoverColor", context) ??
              Colors.transparent,
          backgroundColor:
              widget.control.attrColor("backgroundColor", context) ??
                  Colors.transparent,
          tabBackgroundColor:
              widget.control.attrColor("tabBackgroundColor", context) ??
                  Colors.grey[800]!,
          tabBorderRadius: widget.control.attrDouble("tabBorderRadius") ?? 100,
          iconSize: widget.control.attrDouble("iconSize") ?? 24,
          textSize: widget.control.attrDouble("textSize") ?? 14,
          onTabChange: (i) {
            setState(() => selectedIndex = i);
            widget.backend.updateControlState(
              widget.control.id,
              {"selectedIndex": i.toString()},
              client: true,
              server: true,
            );
            widget.backend.triggerControlEvent(
              widget.control.id,
              "change",
              jsonEncode({"index": "$i"}),
            );
          },
        ),
        widget.parent,
        widget.control,
      );
    } catch (e, st) {
      return Container(
        color: Colors.white,
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            e.toString() + "\n\n" + st.toString(),
            style: TextStyle(color: Colors.red, fontSize: 14),
          ),
        ),
      );
    }
  }
}

class FletGNavBarButtonControl extends StatefulWidget {
  final Control? parent;
  final Control control;
  final void Function()? onPressed;

  const FletGNavBarButtonControl({
    super.key,
    this.parent,
    required this.control,
    this.onPressed,
  });

  static IconData getLineIcon(String name) =>
      LineIcons.byName(name.toLowerCase()) ?? Icons.help_outline;

  static Color? parseColor(String? c) {
    if (c != null && c.startsWith("#")) {
      final hex = c.substring(1);
      final intColor = int.parse(hex, radix: 16);
      if (hex.length == 6) return Color(0xFF000000 | intColor);
      if (hex.length == 8) return Color(intColor);
    }
    return null;
  }

  @override
  State<FletGNavBarButtonControl> createState() =>
      _FletGNavBarButtonControlState();
}

class _FletGNavBarButtonControlState extends State<FletGNavBarButtonControl> {
  @override
  Widget build(BuildContext context) {
    try {
      final rawIconStr = widget.control.attrString("icon") ?? "";
      String? iconUrl;
      String iconName = "";

      try {
        final decoded = jsonDecode(rawIconStr);
        if (decoded is Map<String, dynamic> && decoded["type"] == "image") {
          iconUrl = decoded["src"];
        } else if (decoded is Map<String, dynamic> &&
            decoded["type"] == "icon") {
          iconName = decoded["name"] ?? "";
        } else {
          iconName = rawIconStr;
          if (iconName.startsWith("https://")) iconUrl = iconName;
        }
      } catch (_) {
        iconName = rawIconStr;
        if (iconName.startsWith("https://")) iconUrl = iconName;
      }

      final isImage = iconUrl != null;
      final badgeVisible = widget.control.attrBool("badgeVisible") ?? false;
      final badgeCount = widget.control.attrInt("badgeCount") ?? 0;
      final badgeText = widget.control.attrString("badgeText") ?? "";
      final badgeColor = FletGNavBarButtonControl.parseColor(
              widget.control.attrString("badgeColor")) ??
          Colors.white;
      final badgeBackgroundColor = FletGNavBarButtonControl.parseColor(
              widget.control.attrString("badgeBackgroundColor")) ??
          Colors.red;
      final disabled = widget.control.attrBool("disabled") ?? false;
      final opacity = widget.control.attrDouble("opacity") ?? 1.0;
      final iconSize = widget.control.attrDouble("iconSize") ?? 24;

      Widget iconWidget = isImage
          ? Image.network(iconUrl, width: iconSize, height: iconSize)
          : Icon(FletGNavBarButtonControl.getLineIcon(iconName),
              size: iconSize);

      if (badgeVisible && (badgeCount > 0 || badgeText.isNotEmpty)) {
        iconWidget = badges.Badge(
          badgeContent: Text(
            badgeText.isNotEmpty ? badgeText : badgeCount.toString(),
            style: TextStyle(color: badgeColor, fontSize: 10),
          ),
          badgeStyle: badges.BadgeStyle(badgeColor: badgeBackgroundColor),
          position: badges.BadgePosition.topEnd(top: -6, end: -6),
          child: iconWidget,
        );
      }

      return constrainedControl(
        context,
        Opacity(
          opacity: opacity,
          child: Semantics(
            label: widget.control.attrString("semanticLabel"),
            child: GButton(
              text: widget.control.attrString("text") ?? "",
              icon: isImage
                  ? Icons.help_outline
                  : FletGNavBarButtonControl.getLineIcon(iconName),
              leading: iconWidget,
              gap: widget.control.attrDouble("gap") ?? 8,
              iconSize: iconSize,
              textSize: widget.control.attrDouble("textSize") ?? 14,
              backgroundColor: FletGNavBarButtonControl.parseColor(
                      widget.control.attrString("backgroundColor")) ??
                  Colors.transparent,
              iconColor: FletGNavBarButtonControl.parseColor(
                      widget.control.attrString("iconColor")) ??
                  Colors.grey[400]!,
              iconActiveColor: FletGNavBarButtonControl.parseColor(
                      widget.control.attrString("iconActiveColor")) ??
                  Colors.white,
              textColor: FletGNavBarButtonControl.parseColor(
                      widget.control.attrString("textColor")) ??
                  Colors.white,
              rippleColor: FletGNavBarButtonControl.parseColor(
                  widget.control.attrString("rippleColor")),
              hoverColor: FletGNavBarButtonControl.parseColor(
                  widget.control.attrString("hoverColor")),
              onPressed: disabled
                  ? null
                  : () {
                      if (widget.control.attrBool("haptic") ?? true) {
                        try {
                          HapticFeedback.lightImpact();
                        } catch (_) {}
                      }
                      widget.onPressed?.call();
                    },
            ),
          ),
        ),
        widget.parent,
        widget.control,
      );
    } catch (e, st) {
      return Container(
        color: Colors.white,
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            e.toString() + "\n\n" + st.toString(),
            style: TextStyle(color: Colors.red, fontSize: 14),
          ),
        ),
      );
    }
  }
}
