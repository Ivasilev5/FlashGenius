import 'package:cupertino_native/components/tab_bar.dart';
import 'package:cupertino_native/style/sf_symbol.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../decks/presentation/decks_screen.dart';
import '../../ai_agent/presentation/ai_generate_screen.dart';
import '../../ai_agent/presentation/ai_text_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/data/models/auth_response.dart';
import '../../notifications/providers/study_reminder_provider.dart';

class HomeShellScreen extends ConsumerStatefulWidget {
  const HomeShellScreen({super.key});

  @override
  ConsumerState<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends ConsumerState<HomeShellScreen> {
  int _index = 0;

  String get _title {
    switch (_index) {
      case 0:
        return 'Мои колоды';
      case 1:
        return 'ИИ-агент';
      case 2:
        return 'Профиль';
      default:
        return 'FlashGenius';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final width = MediaQuery.sizeOf(context).width;
    final useIosNavigation =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    final useRailNavigation = !useIosNavigation && width >= 1000;

    final pages = [
      const DecksScreen(showAppBar: false),
      const _AiHubScreen(),
      _ProfileScreen(authState: authState),
    ];

    if (useIosNavigation) {
      return CupertinoPageScaffold(
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Stack(
            children: [
              Positioned.fill(child: pages[_index]),
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: CNTabBar(
                    items: const [
                      CNTabBarItem(
                        label: 'Колоды',
                        icon: CNSymbol('rectangle.grid.2x2.fill'),
                      ),
                      CNTabBarItem(
                        label: 'ИИ',
                        icon: CNSymbol('sparkles'),
                      ),
                      CNTabBarItem(
                        label: 'Профиль',
                        icon: CNSymbol('person.fill'),
                      ),
                    ],
                    currentIndex: _index,
                    onTap: (value) {
                      setState(() {
                        _index = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: useRailNavigation
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (value) {
                    setState(() {
                      _index = value;
                    });
                  },
                  labelType: NavigationRailLabelType.selected,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.style_outlined),
                      selectedIcon: Icon(Icons.style),
                      label: Text('Колоды'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.auto_awesome_outlined),
                      selectedIcon: Icon(Icons.auto_awesome),
                      label: Text('ИИ'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: Text('Профиль'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: IndexedStack(
                        index: _index,
                        children: pages,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : kIsWeb
              ? Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: IndexedStack(
                      index: _index,
                      children: pages,
                    ),
                  ),
                )
              : IndexedStack(
                  index: _index,
                  children: pages,
                ),
      bottomNavigationBar: useRailNavigation
          ? null
          : kIsWeb
              ? SafeArea(
                  minimum: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 12,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxWidth: 640),
                      child: NavigationBar(
                        selectedIndex: _index,
                        onDestinationSelected: (value) {
                          setState(() {
                            _index = value;
                          });
                        },
                        destinations: const [
                          NavigationDestination(
                            icon: Icon(Icons.style_outlined),
                            selectedIcon: Icon(Icons.style),
                            label: 'Колоды',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.auto_awesome_outlined),
                            selectedIcon: Icon(Icons.auto_awesome),
                            label: 'ИИ',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.person_outline),
                            selectedIcon: Icon(Icons.person),
                            label: 'Профиль',
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : NavigationBar(
                  selectedIndex: _index,
                  onDestinationSelected: (value) {
                    setState(() {
                      _index = value;
                    });
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.style_outlined),
                      selectedIcon: Icon(Icons.style),
                      label: 'Колоды',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.auto_awesome_outlined),
                      selectedIcon: Icon(Icons.auto_awesome),
                      label: 'ИИ',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: 'Профиль',
                    ),
                  ],
                ),
    );
  }
}

class _AiHubScreen extends StatelessWidget {
  const _AiHubScreen();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 26),
          Text(
            'ИИ-агент',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Генерируйте карточки по теме или из вставленного текста с помощью ИИ.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.topic),
              title: const Text('Генерация по теме'),
              subtitle: const Text(
                  'Создать колоду или дополнить существующую по описанию темы.'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AiGenerateScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.text_snippet_outlined),
              title: const Text('Генерация из текста'),
              subtitle: const Text(
                  'Вставить большой кусок текста и получить карточки по содержимому.'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AiTextScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileScreen extends ConsumerWidget {
  const _ProfileScreen({required this.authState});

  final AsyncValue<AuthUser?> authState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = authState.valueOrNull;
    final reminderState = ref.watch(studyReminderProvider);

    return Material(
      color: Colors.transparent,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 26),
          Text(
            'Профиль',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          if (user != null) ...[
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(user.username),
              subtitle: Text(user.email),
            ),
          ] else
            const Text('Пользователь не авторизован'),
          const SizedBox(height: 20),
          reminderState.when(
            data: (settings) => _ReminderSettingsCard(settings: settings),
            loading: () => const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (error, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child:
                    Text('Не удалось загрузить настройки уведомлений: $error'),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.topRight,
            child: FilledButton.icon(
              onPressed: () async {
                await ref.read(authStateProvider.notifier).logout();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Выйти'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderSettingsCard extends ConsumerWidget {
  const _ReminderSettingsCard({required this.settings});

  final StudyReminderSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(studyReminderProvider.notifier);
    final formattedTime = DateFormat.Hm().format(
      DateTime(0, 1, 1, settings.time.hour, settings.time.minute),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.notifications_active_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Напоминания о повторении',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ежедневное локальное уведомление помогает не выпадать из интервального повторения.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: settings.isEnabled,
                  onChanged: (value) async {
                    await notifier.setEnabled(value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: const Text('Время напоминания'),
              subtitle: Text(formattedTime),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: settings.time,
                );
                if (pickedTime == null) return;
                await notifier.setTime(pickedTime);
              },
            ),
            if (!settings.permissionGranted) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Если система ещё не выдала доступ, включение переключателя запросит разрешение на уведомления.',
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    await notifier.requestPermissions();
                  },
                  icon: const Icon(Icons.lock_open),
                  label: const Text('Разрешить уведомления'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () async {
                    await notifier.sendTestNotification();
                  },
                  icon: const Icon(Icons.notifications),
                  label: const Text('Тестовое уведомление'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
