import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'widgets/app_action_wrap.dart';
import 'widgets/app_page_header.dart';
import 'widgets/app_section_card.dart';

class WorkspaceSection {
  const WorkspaceSection({
    required this.label,
    required this.icon,
    this.description,
  });

  final String label;
  final IconData icon;
  final String? description;
}

class WorkspaceShortcut {
  const WorkspaceShortcut({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
}

class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.sections,
    required this.selectedIndex,
    required this.onSectionSelected,
    required this.child,
  });

  final String title;
  final String subtitle;
  final List<WorkspaceSection> sections;
  final int selectedIndex;
  final ValueChanged<int> onSectionSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.pagePadding.left,
            tokens.pagePadding.top,
            tokens.pagePadding.right,
            16,
          ),
          child: WorkspaceHeaderCard(
            title: title,
            subtitle: subtitle,
            sections: sections,
            selectedIndex: selectedIndex,
            onSectionSelected: onSectionSelected,
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class WorkspaceHeaderCard extends StatelessWidget {
  const WorkspaceHeaderCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.sections,
    required this.selectedIndex,
    required this.onSectionSelected,
  });

  final String title;
  final String subtitle;
  final List<WorkspaceSection> sections;
  final int selectedIndex;
  final ValueChanged<int> onSectionSelected;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppPageHeader(
            title: title,
            subtitle: subtitle,
          ),
          const SizedBox(height: 16),
          AppActionWrap(
            children: [
              for (var index = 0; index < sections.length; index += 1)
                _WorkspaceSectionChip(
                  section: sections[index],
                  isSelected: index == selectedIndex,
                  onTap: () => onSectionSelected(index),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class WorkspaceHubScreen extends StatelessWidget {
  const WorkspaceHubScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.shortcuts,
  });

  final String title;
  final String subtitle;
  final List<WorkspaceShortcut> shortcuts;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    return ListView(
      padding: tokens.pagePadding.copyWith(bottom: 32),
      children: [
        AppSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppPageHeader(title: title, subtitle: subtitle),
              if (shortcuts.isNotEmpty) ...[
                const SizedBox(height: 18),
                Column(
                  children: [
                    for (var index = 0; index < shortcuts.length; index += 1)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: index == shortcuts.length - 1 ? 0 : 12,
                        ),
                        child: _WorkspaceShortcutTile(shortcut: shortcuts[index]),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class PlaceholderWorkspaceScreen extends StatelessWidget {
  const PlaceholderWorkspaceScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.primaryAction,
    required this.primaryLabel,
    this.secondaryAction,
    this.secondaryLabel,
  });

  final String title;
  final String subtitle;
  final VoidCallback primaryAction;
  final String primaryLabel;
  final VoidCallback? secondaryAction;
  final String? secondaryLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    return ListView(
      padding: tokens.pagePadding.copyWith(bottom: 32),
      children: [
        AppSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppPageHeader(
                title: title,
                subtitle: subtitle,
              ),
              const SizedBox(height: 18),
              AppActionWrap(
                children: [
                  FilledButton.icon(
                    onPressed: primaryAction,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(primaryLabel),
                  ),
                  if (secondaryAction != null && secondaryLabel != null)
                    OutlinedButton.icon(
                      onPressed: secondaryAction,
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: Text(secondaryLabel!),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WorkspaceShortcutTile extends StatelessWidget {
  const _WorkspaceShortcutTile({required this.shortcut});

  final WorkspaceShortcut shortcut;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: shortcut.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: shortcut.accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: shortcut.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(shortcut.icon, color: shortcut.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shortcut.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shortcut.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6C665D),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: shortcut.accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkspaceSectionChip extends StatelessWidget {
  const _WorkspaceSectionChip({
    required this.section,
    required this.isSelected,
    required this.onTap,
  });

  final WorkspaceSection section;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : tokens.subtleSurface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : tokens.outlineSoft,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                section.icon,
                size: 18,
                color: isSelected ? Colors.white : theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                section.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isSelected ? Colors.white : const Color(0xFF163832),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
