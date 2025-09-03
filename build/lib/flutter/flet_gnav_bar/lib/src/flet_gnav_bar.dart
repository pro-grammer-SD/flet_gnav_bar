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

  /// Normalize a raw map so nulls become safe default strings and
  /// primitive types are stringified (Flet controls often expect strings).
  Map<String, dynamic> normalize(Map<String, dynamic>? raw) {
    final Map<String, dynamic> normalized = <String, dynamic>{};
    if (raw == null) return normalized;
    raw.forEach((key, value) {
      if (value == null) {
        normalized[key] = "";
      } else if (value is bool || value is num) {
        normalized[key] = value.toString();
      } else {
        normalized[key] = value;
      }
    });
    return normalized;
  }

  /// Safely parse tabsData JSON into a list of maps (sanitized).
  List<Map<String, dynamic>> parseTabsData(String? jsonStr) {
    final List<Map<String, dynamic>> out = <Map<String, dynamic>>[];
    if (jsonStr == null || jsonStr.trim().isEmpty) return out;
    try {
      final dynamic decoded = jsonDecode(jsonStr);
      if (decoded is List) {
        for (final dynamic item in decoded) {
          if (item is Map<String, dynamic>) {
            out.add(normalize(item));
          } else if (item is String) {
            // try to parse stringified json item
            try {
              final dynamic parsedItem = jsonDecode(item);
              if (parsedItem is Map<String, dynamic>) {
                out.add(normalize(parsedItem));
              }
            } catch (_) {
              // ignore
            }
          }
        }
      }
    } catch (_) {
      // invalid JSON — return empty
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    try {
      final int backendIndex = widget.control.attrInt("selectedIndex") ?? 0;
      if (backendIndex != selectedIndex) selectedIndex = backendIndex;

      final String? jsonStr = widget.control.attrString("tabsData");
      final List<Map<String, dynamic>> tabsData = parseTabsData(jsonStr);

      final List<Widget> tabs = tabsData.map((tabMap) {
        // tabMap is already normalized
        Control? tabControl;
        try {
          tabControl = Control.fromJson(tabMap);
        } catch (_) {
          tabControl = null;
        }

        final Widget button = FletGNavBarButtonControl(
          control: tabControl ?? widget.control,
          onPressed: () {
            final int i = tabsData.indexOf(tabMap);
            setState(() => selectedIndex = i);
            try {
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
            } catch (_) {}
          },
        );

        // If Control.fromJson failed, pass the original parent control so constrainedControl still works.
        return constrainedControl(
          context,
          button,
          widget.parent,
          tabControl ?? widget.control,
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
          onTabChange: (int i) {
            setState(() => selectedIndex = i);
            try {
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
            } catch (_) {}
          },
        ),
        widget.parent,
        widget.control,
      );
    } catch (e, st) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            '${e.toString()}\n\n${st.toString()}',
            style: const TextStyle(color: Colors.red, fontSize: 14),
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
    if (c == null) return null;
    if (c.startsWith("#")) {
      final String hex = c.substring(1);
      final int intColor = int.parse(hex, radix: 16);
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
      // attrString returns String? — always treat it as possibly null
      final String rawIconStr = widget.control.attrString("icon") ?? "";

      // We allow two formats:
      // - plain string: either "search" or "https://..."
      // - a JSON string that encodes { "type": "image", "src": "https://..." } or { "type": "icon", "name": "search" }
      String? iconUrl;
      String iconName = "";

      if (rawIconStr.isNotEmpty) {
        // try to decode JSON safely; if not JSON, fall back to plain string
        try {
          final dynamic decoded = jsonDecode(rawIconStr);
          if (decoded is Map<String, dynamic>) {
            final String? t =
                decoded['type'] is String ? decoded['type'] as String : null;
            if (t == 'image') {
              iconUrl =
                  decoded['src'] is String ? decoded['src'] as String : null;
            } else if (t == 'icon') {
              iconName =
                  decoded['name'] is String ? decoded['name'] as String : '';
            }
          } else {
            // decoded to something else (list, number) — treat raw as plain string
            iconName = rawIconStr;
            if (iconName.startsWith('https://')) iconUrl = iconName;
          }
        } catch (_) {
          // not JSON — check if it's a URL or icon name
          iconName = rawIconStr;
          if (iconName.startsWith('https://')) iconUrl = iconName;
        }
      }

      final bool isImage = iconUrl != null && iconUrl.isNotEmpty;
      final bool badgeVisible =
          widget.control.attrBool("badgeVisible") ?? false;
      final int badgeCount = widget.control.attrInt("badgeCount") ?? 0;
      final String badgeText = widget.control.attrString("badgeText") ?? "";
      final Color badgeColor = FletGNavBarButtonControl.parseColor(
              widget.control.attrString("badgeColor")) ??
          Colors.white;
      final Color badgeBackgroundColor = FletGNavBarButtonControl.parseColor(
              widget.control.attrString("badgeBackgroundColor")) ??
          Colors.red;
      final bool disabled = widget.control.attrBool("disabled") ?? false;
      final double opacity = widget.control.attrDouble("opacity") ?? 1.0;
      final double iconSize = widget.control.attrDouble("iconSize") ?? 24.0;

      Widget iconWidget;
      if (isImage) {
        final String safeUrl = iconUrl;
        iconWidget = safeUrl.isNotEmpty
            ? Image.network(safeUrl, width: iconSize, height: iconSize)
            : Icon(FletGNavBarButtonControl.getLineIcon(iconName),
                size: iconSize);
      } else {
        iconWidget = Icon(FletGNavBarButtonControl.getLineIcon(iconName),
            size: iconSize);
      }

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
            label: widget.control.attrString("semanticLabel") ?? '',
            child: GButton(
              text: widget.control.attrString("text") ?? "",
              icon: isImage
                  ? Icons.help_outline
                  : FletGNavBarButtonControl.getLineIcon(iconName),
              leading: iconWidget,
              gap: widget.control.attrDouble("gap") ?? 8.0,
              iconSize: iconSize,
              textSize: widget.control.attrDouble("textSize") ?? 14.0,
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
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            '${e.toString()}\n\n${st.toString()}',
            style: const TextStyle(color: Colors.red, fontSize: 14),
          ),
        ),
      );
    }
  }
}
