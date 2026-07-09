# Progression and Magic System

## 1. Direction

플레이어는 처음부터 직업을 고르지 않는다.

처음에는 `방랑자` 또는 `무직 모험가`로 시작한다. 플레이하면서 무기 사용, 마법 학습, 퀘스트 선택, 길드 입문 조건을 만족하면 1차 전직을 할 수 있다. 이후 더 높은 레벨과 조건을 만족하면 2차 전직으로 확장된다.

핵심 의도:

- 초반에는 누구나 같은 출발선에서 시작한다.
- 플레이 스타일에 따라 전직 방향이 열린다.
- 직업은 고정 선택지가 아니라 플레이 이력의 결과처럼 느껴진다.
- 마법과 장비 효과는 텍스트 전투 로그에서 선명하게 보인다.

## 2. Base Class

초기 직업:

| ID | Name | Description |
| --- | --- | --- |
| wanderer | 방랑자 | 아직 어떤 길도 정하지 않은 초보 모험가 |

초기 방랑자는 기본 공격, 아이템 사용, 도망, 조사, 대화만 사용할 수 있다.

## 3. First Advancement

1차 전직은 레벨과 조건을 함께 본다.

기본 조건:

- 레벨 10 이상
- 루미르 변경의 첫 장 퀘스트 완료
- 해당 계열 교관 또는 길드 NPC와 대화
- 필요 아이템 또는 시험 완료

1차 전직은 4개 계열로 확정한다.

| ID | Name | Style | Unlock Condition |
| --- | --- | --- | --- |
| fighter | 전사 | 근접 공격, 방어, 안정적인 사냥 | 근접 무기 사용 경험과 전투 시험 |
| scout | 정찰자 | 회피, 선공, 채집, 던전 탐색 | 숲길 탐색과 추적 시험 |
| apprentice_mage | 견습 마법사 | 주문, 원소 피해, 낮은 방어 | 마법서 해독과 마력 시험 |
| acolyte | 수련 사제 | 회복, 보호, 언데드 대응 | 신전 의뢰와 치유 시험 |

역할 구분:

| Class | Combat Role | Exploration Role | First Skill Direction |
| --- | --- | --- | --- |
| 전사 | 안정적인 근접 전투 | 무거운 문, 방어 시험 | 강타, 방어 자세 |
| 정찰자 | 빠른 공격과 회피 | 흔적 찾기, 함정 감지 | 기습, 회피술 |
| 견습 마법사 | 높은 마법 피해 | 룬 해독, 마법 장치 조작 | 불씨, 작은 장벽 |
| 수련 사제 | 회복과 보호 | 저주 해제, 언데드 대응 | 치유, 보호 기도 |

## 4. Second Advancement

2차 전직은 레벨 30 이후의 장기 목표다. MVP에서는 구현하지 않고 문서와 데이터 구조만 준비한다.

| First Class | Second Class Candidate | Style |
| --- | --- | --- |
| 전사 | 기사 | 방어, 도발, 안정성 |
| 전사 | 검투사 | 공격, 반격, 치명타 |
| 정찰자 | 추적자 | 선공, 함정, 야외 사냥 |
| 정찰자 | 암영 | 회피, 기습, 상태 이상 |
| 견습 마법사 | 원소술사 | 화염, 냉기, 번개 |
| 견습 마법사 | 룬마도사 | 장비 마법, 룬, 조건 발동 |
| 수련 사제 | 사제 | 회복, 보호막 |
| 수련 사제 | 성전사 | 근접 전투와 신성 마법 |

## 5. Skill Types

스킬은 크게 네 종류로 나눈다.

| Type | Description | Example |
| --- | --- | --- |
| active | 플레이어가 명령어로 직접 사용 | `시전 불꽃화살` |
| passive | 배운 뒤 항상 적용 | 최대 HP +10 |
| triggered | 조건 만족 시 자동 발동 | 공격 시 15% 확률로 화염 피해 |
| equipment | 장비 착용 중에만 사용 가능 | 마법검 착용 시 `섬광베기` 사용 가능 |

## 6. Magic Learning

마법사는 처음부터 모든 마법을 쓰지 않는다.

마법 사용 조건:

- 해당 마법을 배웠다.
- 필요한 직업 또는 숙련 조건을 만족한다.
- 필요한 MP 또는 자원을 보유했다.
- 침묵, 봉인 같은 상태 이상에 걸리지 않았다.

마법 습득 방식:

| Method | Description |
| --- | --- |
| spellbook | 마법서를 읽어 습득 |
| trainer | 스승 NPC에게 비용을 내고 습득 |
| quest | 퀘스트 보상으로 습득 |
| relic | 유물과 계약해 제한적으로 습득 |

초기 마법 예시:

| ID | Name | Type | Requirement | Effect |
| --- | --- | --- | --- | --- |
| spark | 불씨 | active | 견습 마법사 | 적 1명에게 낮은 화염 피해 |
| frost_touch | 서리손 | active | 견습 마법사 | 피해와 낮은 둔화 확률 |
| minor_barrier | 작은 장벽 | active | 견습 마법사 또는 수련 사제 | 다음 피해 감소 |
| calm_breath | 고요한 숨 | passive | 수련 사제 | 전투 후 HP 소량 회복 |

## 7. Magic Equipment

마법 장비는 장착했을 때 스탯만 올리는 장비보다 더 강한 정체성을 갖는다.

장비 효과 구분:

| Category | Description | Example |
| --- | --- | --- |
| stat | 단순 능력치 증가 | attack +3 |
| passive | 착용 중 항상 적용 | 화염 저항 +10 |
| triggered | 특정 조건에서 자동 발동 | 공격 시 확률로 불꽃 추가 피해 |
| active | 장착 중 명령어로 사용 | `사용 루미르검`으로 광휘 방출 |
| cursed | 강한 효과와 패널티 동시 보유 | 공격력 증가, 회복량 감소 |

장비 발동 조건 예시:

| Trigger | Meaning |
| --- | --- |
| onAttack | 일반 공격 시 |
| onHit | 공격이 명중했을 때 |
| onDamaged | 피해를 받았을 때 |
| onLowHp | HP가 일정 이하일 때 |
| onKill | 적을 처치했을 때 |
| onEnterRoom | 특정 방에 들어갔을 때 |
| command | 플레이어가 직접 사용했을 때 |

## 8. Example Magic Gear

| ID | Name | Category | Effect |
| --- | --- | --- | --- |
| ember_blade | 잿불검 | triggered | 공격 명중 시 15% 확률로 화염 피해 3 |
| moonlit_buckler | 달빛 소형방패 | passive | 밤 또는 지하에서 defense +2 |
| aigyn_ring | 아이긴 반지 | active | 하루 1회 작은 보호막 생성 |
| rune_edge | 룬날 검 | equipment | 룬마도사가 착용하면 `룬베기` 사용 가능 |
| hungry_iron_sword | 굶주린 철검 | cursed | attack +5, 전투 후 HP 1 손실 |

## 9. Combat Log Examples

마법 발동은 로그에서 즉시 이해되어야 한다.

```text
당신은 잿불검으로 동굴 들개를 베었다. 6의 피해.
잿불검의 금이 붉게 달아오른다.
추가로 3의 화염 피해를 입혔다.
```

```text
당신은 불씨를 시전했다.
작은 불꽃이 파편갉이의 등껍질을 태웠다. 8의 피해.
```

```text
아이긴 반지에서 희미한 빛이 퍼진다.
다음 공격으로 받는 피해가 5 감소한다.
```

## 10. Data Model Draft

```dart
enum SkillActivationType {
  active,
  passive,
  triggered,
  equipment,
}

enum EquipmentEffectCategory {
  stat,
  passive,
  triggered,
  active,
  cursed,
}

class PlayerClass {
  final String id;
  final String name;
  final int tier;
  final List<String> prerequisiteClassIds;
  final Map<String, int> requiredStats;
  final List<String> requiredQuestIds;
}

class Skill {
  final String id;
  final String name;
  final SkillActivationType activationType;
  final List<String> requiredClassIds;
  final int mpCost;
  final String description;
}

class EquipmentEffect {
  final String id;
  final EquipmentEffectCategory category;
  final String trigger;
  final int chancePercent;
  final Map<String, int> values;
  final String logMessage;
}
```

## 11. MVP Boundary

MVP에서 바로 구현할 것:

- 방랑자 시작
- 전직 UI/명령어는 아직 잠금 상태로 노출
- 마법 장비 데이터 구조 준비
- `잿불검` 같은 조건 발동 장비 1개
- 장비 발동 로그

MVP 이후 구현:

- 1차 전직
- MP와 마법 습득
- 액티브 마법 명령어
- 2차 전직
- 저주 장비와 해주 시스템
