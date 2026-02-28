import 'package:cupertino_native/components/tab_bar.dart';
import 'package:cupertino_native/style/sf_symbol.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../decks/presentation/decks_screen.dart';
import '../../ai_agent/presentation/ai_generate_screen.dart';
import '../../ai_agent/presentation/ai_pdf_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/data/models/auth_response.dart';

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
    final useIosNavigation =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

    final pages = [
      const DecksScreen(),
      const _AiHubScreen(),
      _ProfileScreen(authState: authState),
    ];

    if (useIosNavigation) {
      return CupertinoPageScaffold(
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
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
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
            'Генерируйте карточки по теме или из PDF-документа с помощью ИИ.',
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
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Генерация из PDF'),
              subtitle: const Text(
                  'Загрузить PDF и получить карточки по содержимому.'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AiPdfScreen()),
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

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 18),
            Container(
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
      ),
    );
  }
}
