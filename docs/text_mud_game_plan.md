# Flutter Web Text MUD Game Plan

## 1. Concept

옛날 텍스트 MUD 게임, 특히 한국 텍스트 MUD인 마법의대륙을 롤모델로 삼아 웹에서 재현하는 Flutter 기반 텍스트 RPG.

플레이어는 명령어를 입력해 방을 이동하고, NPC와 대화하고, 몬스터와 전투하며, 아이템을 얻고 성장한다. 화면은 터미널처럼 보이지만 웹 UI의 장점을 살려 로그, 상태창, 지도, 인벤토리, 도움말을 함께 제공한다.

롤모델 분석은 [마법의대륙 롤모델 분석과 적용안](magic_land_reference_analysis.md)에 별도로 정리한다.

독자 세계관과 명칭 규칙은 [Worldbuilding Draft](worldbuilding.md)에 정리한다.

전직, 마법, 마법 장비 규칙은 [Progression and Magic System](progression_and_magic_system.md)에 정리한다.

첫 구현 범위는 [MVP 0.1 Playable Slice](mvp_0_1_playable_slice.md)를 기준으로 한다.

## 2. Target Experience

- 키보드 중심 플레이
- 짧고 반복 가능한 명령어 입력
- 텍스트 로그를 읽으며 상상하는 탐험
- 방, 지역, NPC, 몬스터가 연결된 세계
- 단순하지만 확장 가능한 전투와 성장
- 무직 방랑자에서 시작해 1차/2차 전직으로 성장
- 마법 습득과 마법 장비 발동
- 채팅과 공지처럼 느껴지는 NPC/소문 로그
- 반복 사냥과 귀환 정비의 리듬
- 모바일 웹에서도 플레이 가능한 레이아웃

## 3. Core Loop

1. 현재 위치와 상황 설명을 읽는다.
2. 명령어를 입력한다.
3. 이동, 조사, 대화, 전투, 아이템 사용 등의 결과가 로그에 출력된다.
4. 경험치, 골드, 아이템, 퀘스트 상태가 갱신된다.
5. 더 깊은 지역으로 이동하거나 마을로 돌아와 정비한다.

## 4. MVP Scope

첫 번째 버전은 혼자 플레이하는 싱글 플레이 텍스트 MUD로 만든다.

포함할 기능:

- 명령어 입력창
- 게임 로그 출력
- 플레이어 상태 표시
- 방 단위 이동
- 방 설명과 출구 표시
- 아이템 획득과 인벤토리
- 기본 전투
- NPC 대화
- 소문/공지 로그
- 간단한 퀘스트
- 저장 및 불러오기
- 방랑자 시작 상태
- 조건 발동 마법 장비 1개

제외할 기능:

- 실시간 멀티플레이
- 계정 시스템
- 채팅
- 서버 동기화
- 1차/2차 전직 실제 구현
- 복잡한 직업/스킬 트리 UI

## 5. Game Theme

초기 테마는 정통 중세 모험 판타지 마을과 고대 신화의 흔적이 남은 지하 던전으로 한다.

시작 지역:

- 루미르 변경
- 루미르 광장
- 헤스틴 여관
- 브론 대장간
- 셀렌 약초점
- 아이긴 초소
- 네미르 숲길
- 오르페 폐광 입구
- 오르페 폐광 1층
- 별빛 수직갱

핵심 분위기:

- 오래된 온라인 RPG
- 낭만적인 중세 모험 판타지
- 검은 배경의 터미널
- 녹색 또는 호박색 텍스트
- 짧고 묵직한 문장
- 숨겨진 단서와 반복 탐험
- 신화에서 변형한 독자 명칭

## 6. Player Stats

초기 플레이어 속성:

| Stat | Description |
| --- | --- |
| name | 플레이어 이름 |
| level | 현재 레벨 |
| hp | 현재 체력 |
| maxHp | 최대 체력 |
| attack | 기본 공격력 |
| defense | 피해 감소 |
| exp | 현재 경험치 |
| gold | 보유 골드 |
| locationId | 현재 방 ID |
| classId | 현재 직업 ID |
| mp | 현재 마력 |
| maxMp | 최대 마력 |

초기값:

```text
level: 1
hp: 30
maxHp: 30
mp: 0
maxMp: 0
attack: 5
defense: 1
exp: 0
gold: 10
locationId: lumir_square
classId: wanderer
```

## 7. Commands

기본 명령어는 한글과 영문 별칭을 모두 지원한다.

| Korean | English | Behavior |
| --- | --- | --- |
| 도움말 | help | 사용 가능한 명령어 표시 |
| 보기 | look | 현재 위치 설명 다시 출력 |
| 이동 북쪽 | go north | 북쪽으로 이동 |
| 북 | n | 북쪽으로 이동 |
| 남 | s | 남쪽으로 이동 |
| 동 | e | 동쪽으로 이동 |
| 서 | w | 서쪽으로 이동 |
| 조사 | inspect | 현재 방의 사물 조사 |
| 대화 [대상] | talk [target] | NPC와 대화 |
| 공격 [대상] | attack [target] | 몬스터 공격 |
| 줍기 [아이템] | take [item] | 아이템 획득 |
| 인벤토리 | inventory | 보유 아이템 표시 |
| 사용 [아이템] | use [item] | 아이템 사용 |
| 도망 | flee | 전투에서 도망 |
| 다시 | again | 직전 행동 반복 |
| 소문 | rumors | 현재 지역의 소문 표시 |
| 공지 | notices | 시스템 공지풍 정보 표시 |
| 상태 | status | 플레이어 상태 표시 |
| 퀘스트 | quests | 퀘스트 목록 표시 |
| 전직 | advance | 전직 가능 조건 표시 |
| 기술 | skills | 배운 기술과 마법 표시 |
| 시전 [마법] | cast [spell] | 배운 마법 사용 |
| 저장 | save | 진행 상태 저장 |
| 불러오기 | load | 저장 상태 불러오기 |

## 8. Room Model

방은 게임 월드의 기본 단위다.

```dart
class GameRoom {
  final String id;
  final String name;
  final String description;
  final Map<String, String> exits;
  final List<String> npcIds;
  final List<String> monsterIds;
  final List<String> itemIds;
}
```

예시:

```json
{
  "id": "lumir_square",
  "name": "루미르 광장",
  "description": "낮은 돌담 사이로 바람이 분다. 낡은 게시판에는 밤새 새로 붙은 공지가 흔들리고 있다.",
  "exits": {
    "north": "nemir_forest_path",
    "east": "bron_forge",
    "west": "hestin_inn"
  },
  "npcIds": ["scholar_iod"],
  "monsterIds": [],
  "itemIds": []
}
```

## 9. Item Model

```dart
enum ItemType {
  consumable,
  weapon,
  armor,
  accessory,
  quest,
}

class GameItem {
  final String id;
  final String name;
  final String description;
  final ItemType type;
  final Map<String, int> effects;
  final List<String> equipmentEffectIds;
}
```

초기 아이템:

| ID | Name | Type | Effect |
| --- | --- | --- | --- |
| small_potion | 작은 회복약 | consumable | hp +10 |
| worn_blade | 낡은 칼 | weapon | attack +2 |
| patched_cloak | 덧댄 망토 | armor | defense +1 |
| lost_patrol_badge | 실종 순찰대의 표식 | quest | 퀘스트 아이템 |
| dim_rune_shard | 흐린 룬 조각 | quest | 다음 장 떡밥 |
| ember_blade | 잿불검 | weapon | 공격 명중 시 낮은 확률로 화염 피해 |

## 10. Monster Model

```dart
class Monster {
  final String id;
  final String name;
  final String description;
  final int hp;
  final int attack;
  final int defense;
  final int expReward;
  final int goldReward;
  final List<String> dropItemIds;
}
```

초기 몬스터:

| ID | Name | Location | Role |
| --- | --- | --- | --- |
| moss_rat | 이끼쥐 | 네미르 숲길 | 첫 전투용 약한 몬스터 |
| cave_stray | 동굴 들개 | 오르페 폐광 1층 | 기본 사냥 몬스터 |
| hollow_miner | 빈껍질 광부 | 오르페 폐광 1층 | 퀘스트 단서 제공 |
| shard_gnawer | 파편갉이 | 별빛 수직갱 | MVP 보스 |

## 11. NPC Model

```dart
class Npc {
  final String id;
  final String name;
  final String description;
  final List<DialogueNode> dialogues;
}

class DialogueNode {
  final String id;
  final String text;
  final Map<String, String> choices;
}
```

초기 NPC:

| ID | Name | Purpose |
| --- | --- | --- |
| guard_captain_eran | 경비대장 에란 | 폐광 조사 의뢰 |
| innkeeper_mara | 여관주인 마라 | 회복과 소문 제공 |
| smith_bron | 대장장이 브론 | 장비 힌트 제공 |
| herbalist_selen | 약초사 셀렌 | 회복약 판매 |
| scholar_iod | 학자 이오드 | 고대 신전 떡밥 제공 |

## 12. Quest Model

```dart
enum QuestStatus {
  notStarted,
  active,
  completed,
}

class Quest {
  final String id;
  final String title;
  final String description;
  final QuestStatus status;
  final List<String> objectiveIds;
  final List<String> rewardItemIds;
  final int rewardExp;
  final int rewardGold;
}
```

MVP 퀘스트:

```text
Title: 폐광의 별빛
Start: 경비대장 에란과 대화
Objective:
- 오르페 폐광 입구 찾기
- 오르페 폐광 1층에서 실종 순찰대의 표식 획득
- 별빛 수직갱의 파편갉이 처치
Reward:
- 50 exp
- 30 gold
- 낡은 칼
```

## 13. Combat

전투는 턴 기반으로 단순하게 시작한다.

공격 계산:

```text
playerDamage = max(1, player.attack - monster.defense)
monsterDamage = max(1, monster.attack - player.defense)
```

전투 흐름:

1. 플레이어가 `공격 [대상]` 입력
2. 몬스터 체력 감소
3. 몬스터가 살아 있으면 반격
4. 플레이어 체력 감소
5. 몬스터 처치 시 보상 지급
6. 플레이어 체력이 0이 되면 마을 여관에서 부활

마법의대륙식 반복 사냥 감각을 위해 전투 중인 대상은 기억한다. 전투가 시작된 뒤에는 `공격`만 입력해도 같은 대상을 계속 공격한다. `도망`은 현재 전투를 종료하고 이전 안전 지역으로 이동할 수 있게 한다.

사망 패널티:

- 여관에서 부활
- 현재 골드 일부 손실
- 경험치 손실 없음
- 첫 사망은 튜토리얼 메시지와 함께 완화

## 14. Progression and Magic Summary

성장 시스템은 무직 방랑자에서 시작해 1차 전직, 2차 전직으로 확장한다.

MVP에서는 전직을 실제 구현하지 않고, 플레이어 상태에 `classId: wanderer`를 포함해 이후 확장 가능하게 만든다. 전직 가능 조건은 `전직` 명령으로 미리 확인할 수 있게 한다.

마법과 마법 장비의 기본 원칙:

- 마법은 배운 주문만 `시전 [마법]`으로 사용할 수 있다.
- 마법 사용에는 직업, MP, 상태 이상 조건이 적용된다.
- 마법검 같은 장비는 착용 중 효과가 열린다.
- 장비 효과는 능력치 증가, 패시브, 조건 발동, 직접 사용, 저주 효과로 나눈다.
- MVP에서는 조건 발동 장비 1개를 먼저 구현한다.

초기 장비 예시:

| ID | Name | Effect |
| --- | --- | --- |
| ember_blade | 잿불검 | 공격 명중 시 15% 확률로 추가 화염 피해 |

## 15. Game Log Model

로그는 단순 문자열이 아니라 타입을 가진 이벤트로 관리한다.

```dart
enum GameLogType {
  location,
  combat,
  reward,
  warning,
  system,
  npc,
  rumor,
}

class GameLogEntry {
  final GameLogType type;
  final String message;
  final DateTime createdAt;
  final List<String> tags;
}
```

로그 타입별 역할:

| Type | Role |
| --- | --- |
| location | 방 설명과 이동 결과 |
| combat | 공격, 피해, 처치 |
| reward | 경험치, 골드, 아이템 획득 |
| warning | 위험 지역, 낮은 체력, 사망 직전 |
| system | 저장, 불러오기, 도움말 |
| npc | NPC 대화 |
| rumor | 소문, 공지, 다른 플레이어 흔적처럼 보이는 연출 |

## 16. Flutter Architecture

초기 구조:

```text
lib/
  main.dart
  app.dart
  game/
    game_engine.dart
    command_parser.dart
    game_state.dart
    game_log.dart
    models/
      player.dart
      room.dart
      item.dart
      monster.dart
      npc.dart
      quest.dart
      player_class.dart
      skill.dart
      equipment_effect.dart
    data/
      rooms.dart
      items.dart
      monsters.dart
      npcs.dart
      quests.dart
      classes.dart
      skills.dart
      equipment_effects.dart
  ui/
    mud_screen.dart
    log_panel.dart
    command_input.dart
    status_panel.dart
    inventory_panel.dart
```

상태 관리:

- MVP는 `ChangeNotifier` 또는 `ValueNotifier`로 시작
- 게임 로직은 UI에서 분리
- 명령어 처리 결과는 `GameEvent` 리스트로 반환
- 저장은 Flutter web의 local storage 사용

## 17. Main Screen Layout

Desktop:

```text
+----------------------------------------------------------+
| Game Log                                                 |
|                                                          |
|                                                          |
|                                                          |
+-------------------------------+--------------------------+
| Command Input                 | Status / Inventory       |
+-------------------------------+--------------------------+
```

Mobile:

```text
+-------------------------+
| Game Log                |
|                         |
|                         |
+-------------------------+
| Command Input           |
+-------------------------+
| Status / Inventory Tabs |
+-------------------------+
```

UI 원칙:

- 첫 화면은 바로 게임 화면
- 마케팅성 랜딩 페이지 없음
- 텍스트 로그가 가장 큰 비중
- 명령어 입력창은 항상 접근 가능
- 도움말은 사이드 패널 또는 모달

## 18. Save Data

저장 데이터는 JSON으로 관리한다.

```json
{
  "player": {
    "name": "모험가",
    "level": 1,
    "hp": 30,
    "maxHp": 30,
    "mp": 0,
    "maxMp": 0,
    "attack": 5,
    "defense": 1,
    "exp": 0,
    "gold": 10,
    "locationId": "lumir_square",
    "classId": "wanderer"
  },
  "inventory": ["small_potion"],
  "equippedItemIds": ["worn_blade"],
  "learnedSkillIds": [],
  "completedQuestIds": [],
  "activeQuestIds": [],
  "defeatedMonsterIds": [],
  "visitedRoomIds": ["lumir_square"]
}
```

## 19. Implementation Milestones

### Milestone 1: Project Setup

- Flutter web 프로젝트 생성
- 기본 라우팅 없는 단일 화면 구성
- 테마와 폰트 설정
- 터미널형 UI 초안

### Milestone 2: Command System

- 명령어 파서 구현
- `help`, `look`, `status`, `rumors`, `notices`, `skills`, `advance` 구현
- 로그 출력 시스템 구현

### Milestone 3: World Navigation

- 방 데이터 추가
- 방향 이동 구현
- 출구와 현재 위치 표시

### Milestone 4: Inventory and Items

- 아이템 데이터 추가
- 줍기, 인벤토리, 사용 구현
- 회복약 기능 구현
- 장착 아이템 상태 구현

### Milestone 5: Combat

- 몬스터 데이터 추가
- 공격 명령어 구현
- 전투 중 대상 기억 구현
- 도망 명령어 구현
- 턴 기반 반격 구현
- 조건 발동 장비 효과 구현
- 보상과 사망 처리 구현

### Milestone 6: NPC and Quest

- NPC 대화 구현
- 소문/공지 로그 구현
- 첫 퀘스트 구현
- 퀘스트 진행 상태 표시

### Milestone 7: Persistence

- local storage 저장
- 불러오기
- 새 게임 초기화

### Milestone 8: Advancement and Magic

- 1차 전직 조건 구현
- MP 구현
- 마법 습득 구현
- `시전 [마법]` 구현
- 패시브/액티브/조건 발동 스킬 분리

## 20. Open Decisions

- 게임 제목
- 플레이어 이름 입력 시점
- 한글 명령어만 우선할지, 영문 별칭도 처음부터 넣을지
- 세로형 모바일 UI를 MVP에 포함할지
- 데이터 파일을 Dart 상수로 둘지 JSON asset으로 분리할지
- 저장 슬롯을 1개로 할지 여러 개로 할지
- 마법 자원을 MP 하나로 갈지, 직업별 자원을 둘지

## 21. Proposed Game Titles

- 루미르의 폐광
- 검은 화면의 모험가
- 오래된 문 너머
- The Fog Mine
- Echoes Under Mistvale

## 22. Next Step

다음 작업은 Flutter web 프로젝트를 생성하고, `MVP 0.1 Playable Slice`의 첫 10분 플레이 흐름부터 구현하는 것이다.
