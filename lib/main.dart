import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import 'storage/game_storage.dart';

void main() {
  runApp(const MudApp());
}

class MudApp extends StatelessWidget {
  const MudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '루미르의 폐광',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD8B55B),
          surface: Color(0xFF10130F),
        ),
        fontFamily: 'monospace',
        useMaterial3: true,
      ),
      home: const MudScreen(),
    );
  }
}

class MudScreen extends StatefulWidget {
  const MudScreen({super.key});

  @override
  State<MudScreen> createState() => _MudScreenState();
}

class _MudScreenState extends State<MudScreen> {
  late final GameEngine _engine;
  final TextEditingController _commandController = TextEditingController();
  final ScrollController _logController = ScrollController();
  final FocusNode _inputFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _engine = GameEngine(GameStorage());
    _engine.start();
  }

  @override
  void dispose() {
    _commandController.dispose();
    _logController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _submitCommand(String value) {
    final command = value.trim();
    if (command.isEmpty) {
      return;
    }

    setState(() {
      _engine.run(command);
    });
    _commandController.clear();
    _inputFocus.requestFocus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_logController.hasClients) {
        return;
      }
      _logController.animateTo(
        _logController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070907),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 840;
            final logPanel = Expanded(
              flex: isWide ? 3 : 5,
              child: _LogPanel(logs: _engine.logs, controller: _logController),
            );
            final sidePanel = _SidePanel(state: _engine.state);

            return Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _Header(state: _engine.state),
                  const SizedBox(height: 10),
                  Expanded(
                    child: isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              logPanel,
                              const SizedBox(width: 10),
                              SizedBox(width: 310, child: sidePanel),
                            ],
                          )
                        : Column(
                            children: [
                              logPanel,
                              const SizedBox(height: 10),
                              SizedBox(height: 190, child: sidePanel),
                            ],
                          ),
                  ),
                  const SizedBox(height: 10),
                  _QuickActionBar(
                    state: _engine.state,
                    onCommand: _submitCommand,
                  ),
                  const SizedBox(height: 10),
                  _CommandInput(
                    controller: _commandController,
                    focusNode: _inputFocus,
                    onSubmitted: _submitCommand,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final room = rooms[state.player.locationId]!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF12170F),
        border: Border.all(color: const Color(0xFF2D3B29)),
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 6,
        children: [
          Text(
            '루미르의 폐광',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFFE2C469),
              fontWeight: FontWeight.w700,
            ),
          ),
          Text('위치: ${room.name}'),
          Text('직업: ${state.player.className}'),
          Text('Lv.${state.player.level}'),
          Text('HP ${state.player.hp}/${state.player.maxHp}'),
          Text('EXP ${state.player.exp}'),
          Text('Gold ${state.player.gold}'),
        ],
      ),
    );
  }
}

class _LogPanel extends StatelessWidget {
  const _LogPanel({required this.logs, required this.controller});

  final List<GameLogEntry> logs;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF090C08),
        border: Border.all(color: const Color(0xFF30412E)),
      ),
      child: ListView.builder(
        controller: controller,
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SelectableText(
              log.message,
              style: TextStyle(
                color: log.type.color,
                height: 1.35,
                fontSize: 15,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SidePanel extends StatelessWidget {
  const _SidePanel({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final room = rooms[state.player.locationId]!;
    final inventory = state.inventory.isEmpty
        ? '비어 있음'
        : state.inventory.map((id) => items[id]?.name ?? id).join(', ');
    final questText = state.questStatus == QuestStatus.notStarted
        ? '없음'
        : '폐광의 별빛: ${state.questStatus.label}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF10130F),
        border: Border.all(color: const Color(0xFF30412E)),
      ),
      child: ListView(
        children: [
          _PanelLine(title: '현재 위치', value: room.name),
          _PanelLine(title: '출구', value: room.exitLabel),
          _PanelLine(title: '장착', value: state.equippedNames),
          _PanelLine(title: '인벤토리', value: inventory),
          _PanelLine(title: '퀘스트', value: questText),
          const SizedBox(height: 10),
          const Text(
            '아래 빠른 행동을 누르거나 직접 명령어를 입력할 수 있다.',
            style: TextStyle(color: Color(0xFF9EB892), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _PanelLine extends StatelessWidget {
  const _PanelLine({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Color(0xFFD8B55B), fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14, height: 1.3)),
        ],
      ),
    );
  }
}

class _QuickActionBar extends StatelessWidget {
  const _QuickActionBar({required this.state, required this.onCommand});

  final GameState state;
  final ValueChanged<String> onCommand;

  @override
  Widget build(BuildContext context) {
    final actions = _buildActions();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F130E),
        border: Border.all(color: const Color(0xFF30412E)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            '빠른 행동',
            style: TextStyle(color: Color(0xFFD8B55B), fontSize: 13),
          ),
          for (final action in actions)
            OutlinedButton.icon(
              key: ValueKey('quick-${action.command}'),
              onPressed: () => onCommand(action.command),
              icon: Icon(action.icon, size: 16),
              label: Text(action.label),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE8E3C7),
                side: const BorderSide(color: Color(0xFF3F563A)),
                minimumSize: const Size(0, 34),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                textStyle: const TextStyle(fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  List<QuickAction> _buildActions() {
    final room = rooms[state.player.locationId]!;
    final actions = <QuickAction>[];

    const directionLabels = {
      'north': ('북', Icons.north),
      'south': ('남', Icons.south),
      'east': ('동', Icons.east),
      'west': ('서', Icons.west),
    };

    for (final entry in room.exits.entries) {
      final direction = directionLabels[entry.key];
      if (direction == null) {
        continue;
      }
      actions.add(
        QuickAction(
          label: direction.$1,
          command: direction.$1,
          icon: direction.$2,
        ),
      );
    }

    for (final npcId in room.npcIds) {
      final npc = npcs[npcId]!;
      actions.add(
        QuickAction(
          label: '대화 ${npc.shortName}',
          command: '대화 ${npc.shortName}',
          icon: Icons.chat_bubble_outline,
        ),
      );
    }

    for (final monsterId in room.monsterIds) {
      if (state.defeatedMonsterIds.contains(monsterId)) {
        continue;
      }
      final monster = monsters[monsterId]!;
      actions.add(
        QuickAction(
          label: '공격 ${monster.name}',
          command: '공격 ${monster.name}',
          icon: Icons.gps_fixed,
        ),
      );
    }

    if (room.id == 'orphe_mine_gate' &&
        !state.inventory.contains('patrol_note')) {
      actions.add(
        const QuickAction(
          label: '줍기 기록',
          command: '줍기 기록',
          icon: Icons.inventory_2_outlined,
        ),
      );
    }

    if (state.inventory.contains('small_potion')) {
      actions.add(
        const QuickAction(
          label: '회복약',
          command: '사용 회복약',
          icon: Icons.local_drink_outlined,
        ),
      );
    }

    actions.addAll(const [
      QuickAction(label: '보기', command: '보기', icon: Icons.visibility_outlined),
      QuickAction(label: '소문', command: '소문', icon: Icons.campaign_outlined),
      QuickAction(label: '지도', command: '지도', icon: Icons.map_outlined),
      QuickAction(label: '상태', command: '상태', icon: Icons.favorite_border),
      QuickAction(label: '가방', command: '인벤토리', icon: Icons.backpack_outlined),
      QuickAction(label: '저장', command: '저장', icon: Icons.save_outlined),
    ]);

    return actions;
  }
}

class QuickAction {
  const QuickAction({
    required this.label,
    required this.command,
    required this.icon,
  });

  final String label;
  final String command;
  final IconData icon;
}

class _CommandInput extends StatelessWidget {
  const _CommandInput({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: true,
      onSubmitted: onSubmitted,
      style: const TextStyle(color: Color(0xFFE8E3C7), fontSize: 16),
      decoration: InputDecoration(
        prefixText: '> ',
        prefixStyle: const TextStyle(color: Color(0xFFD8B55B), fontSize: 16),
        hintText: '명령어 입력',
        hintStyle: const TextStyle(color: Color(0xFF718067)),
        filled: true,
        fillColor: const Color(0xFF0F130E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF30412E)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF30412E)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFFD8B55B)),
        ),
      ),
    );
  }
}

class GameEngine {
  GameEngine(this._storage);

  final GameStorage _storage;
  final Random _random = Random(7);
  final List<GameLogEntry> logs = [];
  GameState state = GameState.initial();
  String? _combatMonsterId;
  String? _lastCommand;

  void start() {
    _log(GameLogType.system, '에다리온 동쪽 끝, 루미르 변경에 도착했다.');
    _describeCurrentRoom();
    _log(GameLogType.system, '`도움말`을 입력하면 사용할 수 있는 명령어를 볼 수 있다.');
  }

  void run(String rawCommand) {
    final command = _normalize(rawCommand);
    _log(GameLogType.input, '> $rawCommand');

    if (command == '다시' || command == 'again') {
      if (_lastCommand == null) {
        _log(GameLogType.warning, '반복할 이전 명령이 없다.');
        return;
      }
      run(_lastCommand!);
      return;
    }

    _lastCommand = rawCommand;

    if (_isHelp(command)) return _help();
    if (_matches(command, ['보기', 'look', 'l'])) return _describeCurrentRoom();
    if (_matches(command, ['상태', 'status', 'stat'])) return _status();
    if (_matches(command, ['인벤토리', 'inventory', 'inv', 'i'])) {
      return _inventory();
    }
    if (_matches(command, ['소문', 'rumors', 'rumor'])) return _rumors();
    if (_matches(command, ['공지', 'notices', 'notice'])) return _notices();
    if (_matches(command, ['지도', 'map'])) return _map();
    if (_matches(command, ['기술', 'skills', 'skill'])) return _skills();
    if (_matches(command, ['전직', 'advance', 'class'])) return _advance();
    if (_matches(command, ['저장', 'save'])) return _save();
    if (_matches(command, ['불러오기', 'load'])) return _load();
    if (_matches(command, ['도망', 'flee', 'run'])) return _flee();

    final direction = _parseDirection(command);
    if (direction != null) {
      return _move(direction);
    }

    if (command.startsWith('대화 ') || command.startsWith('talk ')) {
      return _talk(_targetAfter(command));
    }
    if (command.startsWith('공격 ') || command.startsWith('attack ')) {
      return _attack(_targetAfter(command));
    }
    if (_matches(command, ['공격', 'attack'])) {
      return _attack(null);
    }
    if (command.startsWith('줍기 ') || command.startsWith('take ')) {
      return _take(_targetAfter(command));
    }
    if (command.startsWith('사용 ') || command.startsWith('use ')) {
      return _use(_targetAfter(command));
    }
    if (command.startsWith('시전 ') || command.startsWith('cast ')) {
      return _cast(_targetAfter(command));
    }

    _log(GameLogType.warning, '알 수 없는 명령어다. `도움말`을 입력해 보자.');
  }

  bool _isHelp(String command) => _matches(command, ['도움말', 'help', '?']);

  bool _matches(String command, List<String> options) =>
      options.contains(command);

  String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  String _targetAfter(String command) {
    final parts = command.split(' ');
    if (parts.length <= 1) {
      return '';
    }
    return parts.skip(1).join(' ');
  }

  String? _parseDirection(String command) {
    const aliases = {
      '북': 'north',
      '북쪽': 'north',
      'n': 'north',
      'north': 'north',
      '남': 'south',
      '남쪽': 'south',
      's': 'south',
      'south': 'south',
      '동': 'east',
      '동쪽': 'east',
      'e': 'east',
      'east': 'east',
      '서': 'west',
      '서쪽': 'west',
      'w': 'west',
      'west': 'west',
    };
    if (aliases.containsKey(command)) {
      return aliases[command];
    }
    if (command.startsWith('이동 ') || command.startsWith('go ')) {
      return aliases[_targetAfter(command)];
    }
    return null;
  }

  void _help() {
    _log(
      GameLogType.system,
      '명령어: 도움말, 보기, 북/남/동/서, 이동 [방향], 소문, 공지, 지도, 대화 [대상], 공격 [대상], 공격, 도망, 줍기 [아이템], 인벤토리, 사용 [아이템], 상태, 기술, 전직, 저장, 불러오기',
    );
  }

  void _describeCurrentRoom() {
    final room = rooms[state.player.locationId]!;
    _log(GameLogType.location, room.name);
    _log(GameLogType.location, room.description);
    _log(GameLogType.system, '출구: ${room.exitLabel}');

    if (room.id == 'nemir_forest_path' && !_isDefeated('moss_rat')) {
      _log(GameLogType.warning, '이끼쥐가 젖은 낙엽 사이에서 튀어나왔다.');
    }
    if (room.id == 'orphe_mine_gate') {
      _log(GameLogType.warning, '[경고] 아직 깊이 들어가기에는 준비가 부족하다.');
      if (!state.inventory.contains('patrol_note')) {
        _log(GameLogType.reward, '무너진 목책 아래에 젖은 순찰 기록이 떨어져 있다.');
      }
    }
  }

  void _move(String direction) {
    final room = rooms[state.player.locationId]!;
    final nextRoomId = room.exits[direction];
    if (nextRoomId == null) {
      _log(GameLogType.warning, '그 방향으로는 갈 수 없다.');
      return;
    }
    state = state.copyWith(
      player: state.player.copyWith(locationId: nextRoomId),
      visitedRoomIds: {...state.visitedRoomIds, nextRoomId},
    );
    _combatMonsterId = null;
    _describeCurrentRoom();
  }

  void _talk(String target) {
    final room = rooms[state.player.locationId]!;
    final npc = npcs.values
        .where((candidate) => room.npcIds.contains(candidate.id))
        .where((candidate) => _looselyMatches(target, candidate.name))
        .firstOrNull;

    if (npc == null) {
      _log(GameLogType.warning, '그런 사람은 이곳에 보이지 않는다.');
      return;
    }

    _log(GameLogType.npc, '${npc.name}: ${npc.dialogue}');
    if (npc.id == 'guard_captain_eran' &&
        state.questStatus == QuestStatus.notStarted) {
      state = state.copyWith(questStatus: QuestStatus.active);
      _log(GameLogType.reward, '퀘스트를 수락했다: 폐광의 별빛');
    }
  }

  void _attack(String? target) {
    final room = rooms[state.player.locationId]!;
    final monsterId = _combatMonsterId ?? _findMonsterId(room, target);

    if (monsterId == null) {
      _log(GameLogType.warning, '공격할 대상이 없다.');
      return;
    }
    if (_isDefeated(monsterId)) {
      _log(GameLogType.warning, '이미 쓰러뜨린 대상이다.');
      return;
    }

    _combatMonsterId = monsterId;
    final monster = state.monsterHp[monsterId] == null
        ? monsters[monsterId]!
        : monsters[monsterId]!.copyWith(hp: state.monsterHp[monsterId]!);

    final playerDamage = max(1, state.player.attack - monster.defense);
    final nextMonsterHp = max(0, monster.hp - playerDamage);
    state = state.copyWith(
      monsterHp: {...state.monsterHp, monsterId: nextMonsterHp},
    );
    _log(
      GameLogType.combat,
      '당신은 ${state.equippedWeaponName}로 ${monster.name}에게 $playerDamage의 피해를 입혔다.',
    );

    if (nextMonsterHp <= 0) {
      _combatMonsterId = null;
      state = state.copyWith(
        player: state.player.copyWith(
          exp: state.player.exp + monster.expReward,
          gold: state.player.gold + monster.goldReward,
        ),
        defeatedMonsterIds: {...state.defeatedMonsterIds, monsterId},
      );
      _log(GameLogType.reward, '${monster.name}을 쓰러뜨렸다.');
      _log(
        GameLogType.reward,
        '${monster.expReward} 경험치와 ${monster.goldReward} 골드를 얻었다.',
      );
      if (monster.dropItemIds.isNotEmpty && _random.nextBool()) {
        final itemId = monster.dropItemIds.first;
        state = state.copyWith(inventory: [...state.inventory, itemId]);
        _log(GameLogType.reward, '${items[itemId]!.name}을 얻었다.');
      }
      return;
    }

    final monsterDamage = max(1, monster.attack - state.player.defense);
    final nextHp = max(0, state.player.hp - monsterDamage);
    state = state.copyWith(player: state.player.copyWith(hp: nextHp));
    _log(
      GameLogType.combat,
      '${monster.name}가 발목을 물었다. $monsterDamage의 피해를 입었다.',
    );

    if (nextHp <= 0) {
      _die();
    }
  }

  String? _findMonsterId(GameRoom room, String? target) {
    final availableIds = room.monsterIds
        .where((id) => !_isDefeated(id))
        .toList();
    if (availableIds.isEmpty) {
      return null;
    }
    if (target == null || target.isEmpty) {
      return availableIds.first;
    }
    for (final id in availableIds) {
      if (_looselyMatches(target, monsters[id]!.name)) {
        return id;
      }
    }
    return null;
  }

  bool _isDefeated(String monsterId) =>
      state.defeatedMonsterIds.contains(monsterId);

  void _take(String target) {
    final room = rooms[state.player.locationId]!;
    if (room.id == 'orphe_mine_gate' && _looselyMatches(target, '젖은 순찰 기록')) {
      if (state.inventory.contains('patrol_note')) {
        _log(GameLogType.warning, '이미 주운 물건이다.');
        return;
      }
      state = state.copyWith(
        inventory: [...state.inventory, 'patrol_note'],
        questStatus: state.questStatus == QuestStatus.active
            ? QuestStatus.clueFound
            : state.questStatus,
      );
      _log(GameLogType.reward, '젖은 순찰 기록을 주웠다.');
      return;
    }
    _log(GameLogType.warning, '주울 수 있는 물건을 찾지 못했다.');
  }

  void _use(String target) {
    final potionId = state.inventory.firstWhere(
      (id) => _looselyMatches(target, items[id]?.name ?? id),
      orElse: () => '',
    );
    if (potionId.isEmpty || potionId != 'small_potion') {
      _log(GameLogType.warning, '사용할 수 있는 아이템이 없다.');
      return;
    }
    final nextInventory = [...state.inventory]..remove(potionId);
    final nextHp = min(state.player.maxHp, state.player.hp + 10);
    state = state.copyWith(
      inventory: nextInventory,
      player: state.player.copyWith(hp: nextHp),
    );
    _log(
      GameLogType.reward,
      '작은 회복약을 사용했다. HP가 ${state.player.hp}/${state.player.maxHp}이 되었다.',
    );
  }

  void _flee() {
    if (_combatMonsterId == null) {
      _log(GameLogType.warning, '지금은 전투 중이 아니다.');
      return;
    }
    _combatMonsterId = null;
    state = state.copyWith(
      player: state.player.copyWith(locationId: 'lumir_square'),
    );
    _log(GameLogType.warning, '전투에서 물러나 루미르 광장으로 돌아왔다.');
    _describeCurrentRoom();
  }

  void _die() {
    _combatMonsterId = null;
    final lostGold = max(1, state.player.gold ~/ 5);
    state = state.copyWith(
      player: state.player.copyWith(
        hp: state.player.maxHp,
        gold: max(0, state.player.gold - lostGold),
        locationId: 'hestin_inn',
      ),
    );
    _log(GameLogType.warning, '눈앞이 어두워졌다.');
    _log(GameLogType.warning, '헤스틴 여관의 침대에서 깨어났다. $lostGold골드를 잃었다.');
  }

  void _inventory() {
    if (state.inventory.isEmpty) {
      _log(GameLogType.system, '인벤토리는 비어 있다.');
      return;
    }
    _log(
      GameLogType.system,
      '인벤토리: ${state.inventory.map((id) => items[id]?.name ?? id).join(', ')}',
    );
  }

  void _status() {
    _log(
      GameLogType.system,
      '방랑자 Lv.${state.player.level} HP ${state.player.hp}/${state.player.maxHp} MP ${state.player.mp}/${state.player.maxMp} 공격 ${state.player.attack} 방어 ${state.player.defense} 경험치 ${state.player.exp} 골드 ${state.player.gold}',
    );
  }

  void _skills() {
    _log(GameLogType.system, '현재 배운 기술은 없다. 방랑자는 기본 공격과 아이템 사용만 가능하다.');
  }

  void _advance() {
    _log(
      GameLogType.system,
      '1차 전직: 전사, 정찰자, 견습 마법사, 수련 사제. 조건: 레벨 10, 첫 장 퀘스트 완료, 계열 시험 완료.',
    );
  }

  void _cast(String target) {
    _log(GameLogType.warning, '$target 마법은 아직 배우지 않았다.');
  }

  void _rumors() {
    final room = rooms[state.player.locationId]!;
    _log(GameLogType.rumor, room.rumor);
  }

  void _notices() {
    _log(GameLogType.rumor, '[공지] 루미르 수비대는 서쪽 폐광으로 향하는 여행자에게 주의를 당부합니다.');
  }

  void _map() {
    final current = rooms[state.player.locationId]!.name;
    _log(GameLogType.system, '지도: 현재 위치는 $current이다.');
    _log(
      GameLogType.system,
      '      [네미르 숲길]\n'
      '            |\n'
      '[헤스틴 여관] - [루미르 광장] - [아이긴 초소]\n'
      '            |\n'
      '      [오르페 폐광 입구]',
    );
  }

  void _save() {
    _storage.save(jsonEncode(state.toJson()));
    _log(GameLogType.system, '저장이 완료되었다.');
  }

  void _load() {
    final saved = _storage.load();
    if (saved == null) {
      _log(GameLogType.warning, '저장된 진행이 없다.');
      return;
    }
    state = GameState.fromJson(jsonDecode(saved) as Map<String, dynamic>);
    _combatMonsterId = null;
    _log(GameLogType.system, '저장된 진행을 불러왔다.');
    _describeCurrentRoom();
  }

  bool _looselyMatches(String input, String name) {
    final cleanInput = input.replaceAll(' ', '');
    final cleanName = name.replaceAll(' ', '').toLowerCase();
    return cleanName.contains(cleanInput.toLowerCase()) ||
        cleanInput.toLowerCase().contains(cleanName);
  }

  void _log(GameLogType type, String message) {
    logs.add(GameLogEntry(type, message));
  }
}

enum GameLogType {
  input(Color(0xFF94A88D)),
  location(Color(0xFFE8E3C7)),
  combat(Color(0xFFE0A05B)),
  reward(Color(0xFFD8B55B)),
  warning(Color(0xFFE06B63)),
  system(Color(0xFF9EB892)),
  npc(Color(0xFF8AB5D6)),
  rumor(Color(0xFFC7A3D9));

  const GameLogType(this.color);

  final Color color;
}

class GameLogEntry {
  const GameLogEntry(this.type, this.message);

  final GameLogType type;
  final String message;
}

class GameState {
  const GameState({
    required this.player,
    required this.inventory,
    required this.equippedItemIds,
    required this.learnedSkillIds,
    required this.questStatus,
    required this.defeatedMonsterIds,
    required this.visitedRoomIds,
    required this.monsterHp,
  });

  factory GameState.initial() {
    return GameState(
      player: Player.initial(),
      inventory: const ['small_potion'],
      equippedItemIds: const ['worn_blade'],
      learnedSkillIds: const [],
      questStatus: QuestStatus.notStarted,
      defeatedMonsterIds: const {},
      visitedRoomIds: const {'lumir_square'},
      monsterHp: const {},
    );
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      player: Player.fromJson(json['player'] as Map<String, dynamic>),
      inventory: List<String>.from(json['inventory'] as List<dynamic>? ?? []),
      equippedItemIds: List<String>.from(
        json['equippedItemIds'] as List<dynamic>? ?? [],
      ),
      learnedSkillIds: List<String>.from(
        json['learnedSkillIds'] as List<dynamic>? ?? [],
      ),
      questStatus: QuestStatus.values.firstWhere(
        (status) => status.name == json['questStatus'],
        orElse: () => QuestStatus.notStarted,
      ),
      defeatedMonsterIds: Set<String>.from(
        json['defeatedMonsterIds'] as List<dynamic>? ?? [],
      ),
      visitedRoomIds: Set<String>.from(
        json['visitedRoomIds'] as List<dynamic>? ?? ['lumir_square'],
      ),
      monsterHp: Map<String, int>.from(json['monsterHp'] as Map? ?? {}),
    );
  }

  final Player player;
  final List<String> inventory;
  final List<String> equippedItemIds;
  final List<String> learnedSkillIds;
  final QuestStatus questStatus;
  final Set<String> defeatedMonsterIds;
  final Set<String> visitedRoomIds;
  final Map<String, int> monsterHp;

  String get equippedNames =>
      equippedItemIds.map((id) => items[id]?.name ?? id).join(', ');
  String get equippedWeaponName => items[equippedItemIds.first]?.name ?? '맨손';

  GameState copyWith({
    Player? player,
    List<String>? inventory,
    List<String>? equippedItemIds,
    List<String>? learnedSkillIds,
    QuestStatus? questStatus,
    Set<String>? defeatedMonsterIds,
    Set<String>? visitedRoomIds,
    Map<String, int>? monsterHp,
  }) {
    return GameState(
      player: player ?? this.player,
      inventory: inventory ?? this.inventory,
      equippedItemIds: equippedItemIds ?? this.equippedItemIds,
      learnedSkillIds: learnedSkillIds ?? this.learnedSkillIds,
      questStatus: questStatus ?? this.questStatus,
      defeatedMonsterIds: defeatedMonsterIds ?? this.defeatedMonsterIds,
      visitedRoomIds: visitedRoomIds ?? this.visitedRoomIds,
      monsterHp: monsterHp ?? this.monsterHp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'player': player.toJson(),
      'inventory': inventory,
      'equippedItemIds': equippedItemIds,
      'learnedSkillIds': learnedSkillIds,
      'questStatus': questStatus.name,
      'defeatedMonsterIds': defeatedMonsterIds.toList(),
      'visitedRoomIds': visitedRoomIds.toList(),
      'monsterHp': monsterHp,
    };
  }
}

class Player {
  const Player({
    required this.name,
    required this.level,
    required this.classId,
    required this.hp,
    required this.maxHp,
    required this.mp,
    required this.maxMp,
    required this.attack,
    required this.defense,
    required this.exp,
    required this.gold,
    required this.locationId,
  });

  factory Player.initial() {
    return const Player(
      name: '방랑자',
      level: 1,
      classId: 'wanderer',
      hp: 30,
      maxHp: 30,
      mp: 0,
      maxMp: 0,
      attack: 7,
      defense: 1,
      exp: 0,
      gold: 10,
      locationId: 'lumir_square',
    );
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'] as String? ?? '방랑자',
      level: json['level'] as int? ?? 1,
      classId: json['classId'] as String? ?? 'wanderer',
      hp: json['hp'] as int? ?? 30,
      maxHp: json['maxHp'] as int? ?? 30,
      mp: json['mp'] as int? ?? 0,
      maxMp: json['maxMp'] as int? ?? 0,
      attack: json['attack'] as int? ?? 7,
      defense: json['defense'] as int? ?? 1,
      exp: json['exp'] as int? ?? 0,
      gold: json['gold'] as int? ?? 10,
      locationId: json['locationId'] as String? ?? 'lumir_square',
    );
  }

  final String name;
  final int level;
  final String classId;
  final int hp;
  final int maxHp;
  final int mp;
  final int maxMp;
  final int attack;
  final int defense;
  final int exp;
  final int gold;
  final String locationId;

  String get className => classId == 'wanderer' ? '방랑자' : classId;

  Player copyWith({
    int? level,
    int? hp,
    int? maxHp,
    int? mp,
    int? maxMp,
    int? attack,
    int? defense,
    int? exp,
    int? gold,
    String? locationId,
    String? classId,
  }) {
    return Player(
      name: name,
      level: level ?? this.level,
      classId: classId ?? this.classId,
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
      mp: mp ?? this.mp,
      maxMp: maxMp ?? this.maxMp,
      attack: attack ?? this.attack,
      defense: defense ?? this.defense,
      exp: exp ?? this.exp,
      gold: gold ?? this.gold,
      locationId: locationId ?? this.locationId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'level': level,
      'classId': classId,
      'hp': hp,
      'maxHp': maxHp,
      'mp': mp,
      'maxMp': maxMp,
      'attack': attack,
      'defense': defense,
      'exp': exp,
      'gold': gold,
      'locationId': locationId,
    };
  }
}

enum QuestStatus {
  notStarted('미수락'),
  active('진행 중'),
  clueFound('단서 발견'),
  completed('완료');

  const QuestStatus(this.label);

  final String label;
}

class GameRoom {
  const GameRoom({
    required this.id,
    required this.name,
    required this.description,
    required this.exits,
    required this.npcIds,
    required this.monsterIds,
    required this.rumor,
  });

  final String id;
  final String name;
  final String description;
  final Map<String, String> exits;
  final List<String> npcIds;
  final List<String> monsterIds;
  final String rumor;

  String get exitLabel {
    const names = {'north': '북', 'south': '남', 'east': '동', 'west': '서'};
    return exits.keys
        .map((direction) => names[direction] ?? direction)
        .join(', ');
  }
}

class Npc {
  const Npc({required this.id, required this.name, required this.dialogue});

  final String id;
  final String name;
  final String dialogue;

  String get shortName => name.split(' ').last;
}

class Monster {
  const Monster({
    required this.id,
    required this.name,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.expReward,
    required this.goldReward,
    required this.dropItemIds,
  });

  final String id;
  final String name;
  final int hp;
  final int attack;
  final int defense;
  final int expReward;
  final int goldReward;
  final List<String> dropItemIds;

  Monster copyWith({int? hp}) {
    return Monster(
      id: id,
      name: name,
      hp: hp ?? this.hp,
      attack: attack,
      defense: defense,
      expReward: expReward,
      goldReward: goldReward,
      dropItemIds: dropItemIds,
    );
  }
}

class GameItem {
  const GameItem({required this.id, required this.name});

  final String id;
  final String name;
}

const rooms = {
  'lumir_square': GameRoom(
    id: 'lumir_square',
    name: '루미르 광장',
    description: '낮은 돌담 사이로 바람이 분다. 낡은 게시판에는 밤새 새로 붙은 공지가 흔들리고 있다.',
    exits: {
      'north': 'nemir_forest_path',
      'east': 'aigyn_watch',
      'west': 'hestin_inn',
      'south': 'orphe_mine_gate',
    },
    npcIds: ['scholar_iod'],
    monsterIds: [],
    rumor: '[소문] 오르페 폐광 쪽 하늘이 어젯밤에도 푸르게 빛났다고 한다.',
  ),
  'aigyn_watch': GameRoom(
    id: 'aigyn_watch',
    name: '아이긴 초소',
    description: '창을 든 병사들이 좁은 길목을 지키고 있다. 목책 너머로 폐광의 능선이 보인다.',
    exits: {'west': 'lumir_square'},
    npcIds: ['guard_captain_eran'],
    monsterIds: [],
    rumor: '[소문] 돌아오지 않은 순찰대는 폐광 입구까지만 간다고 했다.',
  ),
  'hestin_inn': GameRoom(
    id: 'hestin_inn',
    name: '헤스틴 여관',
    description: '난로 불빛이 낮게 흔들린다. 젖은 망토를 말리는 여행자들이 조용히 잔을 기울인다.',
    exits: {'east': 'lumir_square'},
    npcIds: ['innkeeper_mara'],
    monsterIds: [],
    rumor: '[소문] 폐광 쪽으로 간 사람들은 대개 말수가 줄어서 돌아온다고 한다.',
  ),
  'nemir_forest_path': GameRoom(
    id: 'nemir_forest_path',
    name: '네미르 숲길',
    description: '젖은 흙냄새와 이끼 냄새가 짙다. 낮은 풀숲이 길 가장자리를 덮고 있다.',
    exits: {'south': 'lumir_square'},
    npcIds: [],
    monsterIds: ['moss_rat'],
    rumor: '[소문] 숲길의 이끼쥐는 반짝이는 물건을 물고 달아난다.',
  ),
  'orphe_mine_gate': GameRoom(
    id: 'orphe_mine_gate',
    name: '오르페 폐광 입구',
    description: '무너진 목책 너머로 차가운 바람이 새어 나온다. 바닥에는 오래된 수레 자국이 남아 있다.',
    exits: {'north': 'lumir_square'},
    npcIds: [],
    monsterIds: [],
    rumor: '[소문] 폐광 안쪽에서 푸른빛이 솟았다는 말이 있다.',
  ),
};

const npcs = {
  'scholar_iod': Npc(
    id: 'scholar_iod',
    name: '학자 이오드',
    dialogue: '별빛은 하늘에만 있는 것이 아니오. 폐광 아래에서 빛이 솟는다면 오래된 문이 깨어나는 징조일 수 있소.',
  ),
  'guard_captain_eran': Npc(
    id: 'guard_captain_eran',
    name: '경비대장 에란',
    dialogue: '순찰대 하나가 돌아오지 않았다. 폐광 입구의 상황만 확인해다오.',
  ),
  'innkeeper_mara': Npc(
    id: 'innkeeper_mara',
    name: '여관주인 마라',
    dialogue: '무리하지 말아요. 폐광 쪽으로 간 사람들은 대개 말수가 줄어서 돌아오더군요.',
  ),
};

const monsters = {
  'moss_rat': Monster(
    id: 'moss_rat',
    name: '이끼쥐',
    hp: 10,
    attack: 3,
    defense: 0,
    expReward: 5,
    goldReward: 2,
    dropItemIds: ['small_potion'],
  ),
};

const items = {
  'small_potion': GameItem(id: 'small_potion', name: '작은 회복약'),
  'worn_blade': GameItem(id: 'worn_blade', name: '낡은 칼'),
  'patrol_note': GameItem(id: 'patrol_note', name: '젖은 순찰 기록'),
};
