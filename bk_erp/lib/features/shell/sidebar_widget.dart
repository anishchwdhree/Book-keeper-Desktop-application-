import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';

class NavItem {
  final IconData icon;
  final String label;
  final Widget screen;
  final String? group;

  const NavItem({
    required this.icon,
    required this.label,
    required this.screen,
    this.group,
  });
}

class SidebarWidget extends StatefulWidget {
  final int selectedIndex;
  final List<NavItem> items;
  final ValueChanged<int> onItemSelected;

  const SidebarWidget({
    super.key,
    required this.selectedIndex,
    required this.items,
    required this.onItemSelected,
  });

  @override
  State<SidebarWidget> createState() => _SidebarWidgetState();
}

class _SidebarWidgetState extends State<SidebarWidget> {
  int? _hoverIndex;
  final Set<String> _collapsedGroups = {};

  @override
  Widget build(BuildContext context) {
    final showLabels = context.showSidebarLabels;
    final sidebarWidth = context.sidebarWidth;

    return Container(
      width: sidebarWidth,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(
          right: BorderSide(color: AppColors.surfaceBorder, width: 1),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 80,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              border: Border(bottom: BorderSide(color: AppColors.primaryDark)),
            ),
            child: showLabels
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        ClipOval(
                          child: Image.asset(
                            'assets/images/logo_circle.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Ramgram Seed Company',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Book Keeper',
                                style: TextStyle(
                                  color: Color(0xFFB2DFDB),
                                  fontSize: 10,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo_circle.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 4),
              children: showLabels
                  ? _buildGroupedItems(showLabels)
                  : _buildIconOnlyItems(),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
              color: AppColors.statusBarBg,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: showLabels
                ? const Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Admin',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'v1.0',
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Icon(
                      Icons.person,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedItems(bool showLabels) {
    final widgets = <Widget>[];
    String? lastGroup;
    final groupCounts = <String, int>{};

    for (final item in widget.items) {
      final g = item.group ?? '';
      groupCounts[g] = (groupCounts[g] ?? 0) + 1;
    }

    for (int i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];

      if (item.group != null && item.group != lastGroup) {
        if (lastGroup != null) {
          widgets.add(const Divider(height: 1, indent: 10, endIndent: 10));
        }
        final isCollapsed = _collapsedGroups.contains(item.group);
        widgets.add(
          InkWell(
            onTap: showLabels
                ? () {
                    setState(() {
                      if (_collapsedGroups.contains(item.group)) {
                        _collapsedGroups.remove(item.group);
                      } else {
                        _collapsedGroups.add(item.group!);
                      }
                    });
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.only(
                left: 10,
                top: 8,
                bottom: 4,
                right: 10,
              ),
              child: Row(
                children: [
                  if (showLabels && groupCounts[item.group]! > 1)
                    Icon(
                      isCollapsed ? Icons.chevron_right : Icons.expand_more,
                      size: 14,
                      color: AppColors.textHint,
                    ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      item.group!.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.sidebarGroupHeader,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        lastGroup = item.group;
      }

      if (!_collapsedGroups.contains(item.group)) {
        widgets.add(_buildNavTile(i, showLabel: true));
      }
    }
    return widgets;
  }

  List<Widget> _buildIconOnlyItems() {
    return List.generate(
      widget.items.length,
      (i) => _buildNavTile(i, showLabel: false),
    );
  }

  Widget _buildNavTile(int i, {required bool showLabel}) {
    final item = widget.items[i];
    final isSelected = widget.selectedIndex == i;
    final isHovered = _hoverIndex == i;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: showLabel ? 4 : 2, vertical: 0),
      child: Tooltip(
        message: showLabel ? '' : item.label,
        preferBelow: false,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hoverIndex = i),
          onExit: (_) => setState(() => _hoverIndex = null),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => widget.onItemSelected(i),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: showLabel ? 10 : 0,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.sidebarSelected
                    : isHovered
                    ? AppColors.sidebarHover
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
              child: showLabel
                  ? Row(
                      children: [
                        Icon(
                          item.icon,
                          size: 15,
                          color: isSelected
                              ? Colors.white
                              : AppColors.sidebarText,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.label,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.sidebarText,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Icon(
                        item.icon,
                        size: 17,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.sidebarText,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
