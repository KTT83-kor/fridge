# CLAUDE.md

## 응답 언어

모든 답변은 항상 한국어로 작성한다.

## 코드 스타일

코딩 스타일·린터·검수 체크리스트는 글로벌 `~/.claude/CLAUDE.md`를 따른다.

---

## 이 앱이 하는 일

냉장고에 든 재료와 인입 시기를 기록해 소진 임박일을 알려주고, 남은 재료를
조합해 한 끼부터 n일치까지 메뉴를 추천한다. 집에서 둘이서만 쓴다. 2026-09-17 착수.

## 단계

0. 아키텍처 뼈대 + 기기에서 뜨는 앱 — **끝남**
1. 재료 입력 + 소진 임박 (로컬 저장)
2. 아내 기기와 동기화 (Firestore)
3. 빠른 입력 — 한 줄 텍스트 파싱 → 영수증 사진
4. 메뉴 추천 — 임박 재료 우선, 한 끼 → n일치

## 대상 기기

안드로이드 태블릿(SM X110, Android 13)으로 먼저 돌리고 iOS를 뒤에 붙인다.
안드로이드를 먼저 잡은 이유는 서명 절차 없이 바로 설치되기 때문이다.
개인 애플 개발자 계정이 없어서 iOS는 무료 프로비저닝(7일마다 재설치)이 된다.

## 아키텍처

```
lib/
├── core/          앱 전역 공통 — 상수, 테마, Result, 포매터
├── domain/        entity · repository 인터페이스 · usecase
├── data/          model(DTO) · datasource · repository 구현
└── ui/            화면. 화면마다 bloc/ 과 widget/ 을 둔다
```

의존 방향은 `ui → domain ← data` 한 방향이다. `ui`와 `data`는 서로 모른다.
`domain/repository`가 그 사이를 끊는 지점이라 2단계에서 로컬 구현을
Firestore 구현으로 갈아끼울 때 `ui`는 건드리지 않는다.

## 알아둘 것

**저장소는 스트림으로 읽는다**: `IngredientRepository.watchAll()`이 `Stream`인 것은
2단계 Firestore 실시간 동기화를 그대로 받기 위해서다. 로컬 구현은
`StreamController.broadcast`로 흉내 내고 있다. 읽기는 스트림, 쓰기는 `Result<T>`다.

**코드젠을 쓰지 않는다**: `json_serializable`과 `bloc_test`가 analyzer 버전에서
충돌해서 뺐다. DTO의 `fromJson`/`toJson`은 손으로 쓴다. `build_runner`를 돌릴 일이 없다.

**DI 패키지가 없다**: `main.dart`에서 저장소를 만들어 `RepositoryProvider`로 내린다.
이 규모에 get_it을 붙일 이유가 없다.

**intl은 0.20.2에 고정이다**: `flutter_localizations`가 SDK에서 그 버전을 박는다.
캐럿(`^`)을 붙이면 pub 해석이 깨진다.

**소진 임박 판정**: `Freshness.fromDaysLeft`가 하루 이하는 `urgent`, 사흘 이하는
`soon`으로 본다. 기준일은 항상 파라미터로 받는다 — `DateTime.now()`를 도메인 안에서
부르지 않아야 테스트가 고정된다.

**GEMINI_API_KEY는 개발 머신에서만 읽힌다**: `main.dart`가 `dart:io`로 프로젝트
루트의 `.env`를 직접 읽는다(`env.example` 참고). `flutter run -d R8YX81EYL0X`처럼
이 저장소가 있는 머신에서 띄울 때만 통하고, `flutter install`로 태블릿에 독립
설치하면 그 파일이 없어서 키가 비어 메뉴 추천이 실패한다. 독립 설치가 필요해지면
`--dart-define=GEMINI_API_KEY=xxx`로 빌드 시점에 주입하는 방식으로 바꿔야 한다.

## 자주 쓰는 명령어

```bash
flutter run -d R8YX81EYL0X    # 안드로이드 태블릿
flutter test
dart analyze
```
