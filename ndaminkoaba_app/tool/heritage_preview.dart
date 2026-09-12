// Development-only visual fixture. Not imported by main.dart or the router.
// flutter run -d web-server -t tool/heritage_preview.dart --web-port 5319
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ndaminkoaba_app/core/theme/app_theme.dart';
import 'package:ndaminkoaba_app/design_system/navigation/admin_shell.dart';
import 'package:ndaminkoaba_app/design_system/widgets/admin_data_table.dart';
import 'package:ndaminkoaba_app/design_system/widgets/admin_stat_card.dart';
import 'package:ndaminkoaba_app/design_system/cards/premium_card.dart';
import 'package:ndaminkoaba_app/design_system/widgets/gradient_hero_card.dart';
import 'package:ndaminkoaba_app/design_system/gradients/app_gradients.dart';
import 'package:ndaminkoaba_app/l10n/app_localizations.dart';

void main() => runApp(const ProviderScope(child: HeritagePreview()));

class HeritagePreview extends StatelessWidget {
  const HeritagePreview({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => AdminShell(
        activeNavKey: 'overview',
        title: 'Administration',
        subtitle: 'Heritage theme preview · sample content',
        breadcrumbs: const ['NdaMinkoaba', 'Overview'],
        actions: [
          OutlinedButton(onPressed: () {}, child: const Text('Preview action')),
          FilledButton.icon(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Create a course'),
                content: const SizedBox(
                  width: 420,
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Course name'),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Preview dialog'),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AdminStatCard(
                    icon: Icons.language,
                    value: '4',
                    label: 'Languages',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: AdminStatCard(
                    icon: Icons.people_outline,
                    value: '248',
                    label: 'Learners',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: AdminStatCard(
                    icon: Icons.menu_book,
                    value: '32',
                    label: 'Courses',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const GradientHeroCard(
              gradient: AppGradients.hero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Learn · Preserve · Transmit',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Manage language learning and cultural resources.',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AdminDataTable(
              columns: const [
                AdminTableColumn('Language', flex: 2),
                AdminTableColumn('Courses'),
                AdminTableColumn('Status'),
              ],
              rows: ['Ewondo', 'Bulu', 'Bassa']
                  .map(
                    (name) => Row(
                      children: [
                        Expanded(flex: 2, child: Text(name)),
                        const Expanded(child: Text('12')),
                        const Expanded(child: Text('Active')),
                      ],
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            PremiumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Content settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Title',
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    minLines: 3,
                    maxLines: 5,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Published'),
                        selected: true,
                        onSelected: (_) {},
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () {},
                        child: const Text('Save preview'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
