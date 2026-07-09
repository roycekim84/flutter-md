# MVP 0.1 Playable Slice

## 1. Goal

MVP 0.1의 목표는 “텍스트 MUD처럼 느껴지는 첫 10분”을 만드는 것이다.

플레이어는 방랑자로 시작해 루미르 광장에서 소문을 듣고, 아이긴 초소에서 의뢰를 받고, 네미르 숲길에서 첫 전투를 경험한 뒤, 오르페 폐광 입구까지 도달한다.

이 단계에서는 게임 전체를 크게 만들지 않는다. 대신 입력, 로그, 이동, NPC 대화, 전투, 보상, 저장이 실제로 연결되어야 한다.

## 2. Player Flow

1. 게임 시작
2. 루미르 광장 설명 출력
3. `도움말`로 명령어 확인
4. `소문`으로 폐광 관련 소문 확인
5. `서` 또는 `이동 서쪽`으로 아이긴 초소 이동
6. `대화 에란`으로 첫 퀘스트 수락
7. `동`으로 루미르 광장 복귀
8. `북`으로 네미르 숲길 이동
9. 이끼쥐와 첫 전투
10. 회복약 획득 또는 사용
11. `서` 또는 별도 출구로 오르페 폐광 입구 도달
12. 위험 경고 출력
13. `저장`으로 진행 저장

## 3. Rooms

MVP 0.1 방은 5개만 구현한다.

| ID | Name | Purpose |
| --- | --- | --- |
| lumir_square | 루미르 광장 | 시작 지점, 소문, 공지 |
| aigyn_watch | 아이긴 초소 | 첫 퀘스트 수락 |
| hestin_inn | 헤스틴 여관 | 회복, 부활 위치 |
| nemir_forest_path | 네미르 숲길 | 첫 전투 |
| orphe_mine_gate | 오르페 폐광 입구 | 다음 버전 예고, 위험 경고 |

## 4. Room Connections

```text
              [네미르 숲길]
                    |
                    북
                    |
[헤스틴 여관] - 서 - [루미르 광장] - 동 - [아이긴 초소]
                    |
                    남
                    |
             [오르페 폐광 입구]
```

출구 정의:

| From | Direction | To |
| --- | --- | --- |
| lumir_square | north | nemir_forest_path |
| lumir_square | east | aigyn_watch |
| lumir_square | west | hestin_inn |
| lumir_square | south | orphe_mine_gate |
| nemir_forest_path | south | lumir_square |
| aigyn_watch | west | lumir_square |
| hestin_inn | east | lumir_square |
| orphe_mine_gate | north | lumir_square |

## 5. Required Commands

MVP 0.1에서 반드시 동작해야 하는 명령어:

| Command | Behavior |
| --- | --- |
| 도움말 | 명령어 목록 출력 |
| 보기 | 현재 방 설명 재출력 |
| 북/남/동/서 | 방향 이동 |
| 이동 [방향] | 방향 이동 |
| 소문 | 현재 지역 소문 출력 |
| 공지 | 현재 지역 공지 출력 |
| 대화 [대상] | NPC 대화 |
| 공격 [대상] | 몬스터 공격 |
| 공격 | 전투 중 대상 계속 공격 |
| 도망 | 전투 종료 후 루미르 광장으로 이동 |
| 줍기 [아이템] | 방 아이템 획득 |
| 인벤토리 | 보유 아이템 출력 |
| 사용 [아이템] | 회복약 사용 |
| 상태 | 플레이어 상태 출력 |
| 기술 | 배운 기술 출력 |
| 전직 | 전직 조건 출력 |
| 저장 | local storage 저장 |
| 불러오기 | local storage 불러오기 |

## 6. Starting State

```json
{
  "player": {
    "name": "방랑자",
    "level": 1,
    "classId": "wanderer",
    "hp": 30,
    "maxHp": 30,
    "mp": 0,
    "maxMp": 0,
    "attack": 5,
    "defense": 1,
    "exp": 0,
    "gold": 10,
    "locationId": "lumir_square"
  },
  "inventory": ["small_potion"],
  "equippedItemIds": ["worn_blade"],
  "learnedSkillIds": [],
  "activeQuestIds": [],
  "completedQuestIds": [],
  "defeatedMonsterIds": [],
  "visitedRoomIds": ["lumir_square"]
}
```

## 7. NPCs

### 학자 이오드

Location: 루미르 광장

Purpose:

- 세계관 떡밥
- 별신전과 룬 조각 언급

Sample:

```text
학자 이오드: 별빛은 하늘에만 있는 것이 아니오.
폐광 아래에서 빛이 솟는다면, 그건 돌이 아니라 오래된 문이 깨어나는 징조일 수 있소.
```

### 경비대장 에란

Location: 아이긴 초소

Purpose:

- 첫 퀘스트 제공
- 폐광 입구까지 조사 요청

Sample:

```text
경비대장 에란: 순찰대 하나가 돌아오지 않았다.
아직 정식 의뢰를 맡길 단계는 아니지만, 폐광 입구의 상황만 확인해다오.
```

### 여관주인 마라

Location: 헤스틴 여관

Purpose:

- 회복
- 사망 후 부활 위치
- 루미르 생활감 제공

Sample:

```text
여관주인 마라: 무리하지 말아요. 폐광 쪽으로 간 사람들은 대개 말수가 줄어서 돌아오더군요.
```

## 8. Monsters

### 이끼쥐

Location: 네미르 숲길

```json
{
  "id": "moss_rat",
  "name": "이끼쥐",
  "hp": 10,
  "attack": 3,
  "defense": 0,
  "expReward": 5,
  "goldReward": 2,
  "dropItemIds": ["small_potion"]
}
```

전투 로그:

```text
이끼쥐가 젖은 낙엽 사이에서 튀어나왔다.
당신은 낡은 칼로 이끼쥐에게 5의 피해를 입혔다.
이끼쥐가 발목을 물었다. 2의 피해를 입었다.
```

## 9. Items

| ID | Name | Behavior |
| --- | --- | --- |
| small_potion | 작은 회복약 | HP 10 회복 |
| worn_blade | 낡은 칼 | 기본 장착 무기, attack +2 |
| patrol_note | 젖은 순찰 기록 | 퀘스트 단서, 폐광 입구에서 발견 |

## 10. Quest

Title: 폐광의 별빛

MVP 0.1에서는 퀘스트 완료까지 가지 않고, 수락과 첫 단서 획득까지만 구현한다.

상태:

| Status | Condition |
| --- | --- |
| notStarted | 에란과 대화 전 |
| active | 에란에게 의뢰 수락 |
| clueFound | 오르페 폐광 입구에서 젖은 순찰 기록 획득 |

## 11. First 10 Minutes Script

예상 플레이 로그:

```text
루미르 광장
낮은 돌담 사이로 바람이 분다. 낡은 게시판에는 밤새 새로 붙은 공지가 흔들리고 있다.

> 소문
[소문] 오르페 폐광 쪽 하늘이 어젯밤에도 푸르게 빛났다고 한다.

> 동
아이긴 초소
창을 든 병사들이 좁은 길목을 지키고 있다.

> 대화 에란
경비대장 에란: 순찰대 하나가 돌아오지 않았다.
퀘스트를 수락했다: 폐광의 별빛

> 서
루미르 광장으로 돌아왔다.

> 북
네미르 숲길
젖은 흙냄새와 이끼 냄새가 짙다.
이끼쥐가 젖은 낙엽 사이에서 튀어나왔다.

> 공격 이끼쥐
당신은 낡은 칼로 이끼쥐에게 5의 피해를 입혔다.
이끼쥐가 발목을 물었다. 2의 피해를 입었다.

> 공격
당신은 이끼쥐를 쓰러뜨렸다.
5 경험치와 2 골드를 얻었다.

> 남
루미르 광장으로 돌아왔다.

> 남
오르페 폐광 입구
무너진 목책 너머로 차가운 바람이 새어 나온다.
[경고] 아직 깊이 들어가기에는 준비가 부족하다.

> 저장
저장이 완료되었다.
```

## 12. Success Criteria

MVP 0.1 완료 기준:

- 플레이어가 명령어만으로 5개 방을 이동할 수 있다.
- 로그가 타입별로 구분되어 출력된다.
- NPC 대화로 퀘스트 상태가 바뀐다.
- 첫 전투가 시작되고 종료된다.
- 전투 중 `공격` 반복 명령이 동작한다.
- 회복약을 사용할 수 있다.
- 상태, 인벤토리, 기술, 전직 명령이 최소 출력된다.
- 저장/불러오기가 동작한다.

## 13. Next After MVP 0.1

MVP 0.2에서는 오르페 폐광 1층, 파편갉이 보스, 조건 발동 장비 `잿불검`, 퀘스트 완료 보상을 구현한다.
