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

**GEMINI_API_KEY는 env.example에 실제 키를 적어서 쓴다**: `pubspec.yaml`
assets에 `env.example`이 등록돼 있고 `main.dart`가 `dotenv.load(fileName:
'env.example')`로 읽는다. 파일명이 이상해 보이지만 이유가 있다 — 안드로이드
기기에 설치된 앱은 `dart:io`로 개발 머신의 파일을 못 읽는다(그 경로는 기기
샌드박스를 가리킨다). asset 번들만이 기기까지 값을 들고 간다. 그런데 asset은
빌드 시점에 존재하는 파일만 등록할 수 있어서 `.env`처럼 있다 없다 하는 이름을
쓰면 그 파일이 없을 때 `flutter build`/`test` 자체가 깨진다. 그래서 `.env`
대신 `env.example`이라는, 원래는 "예시"라는 뜻이지만 실제로 항상 존재하게
만든 파일 이름을 그대로 실사용 키 저장소로 쓴다. `env.example`은
`.gitignore`에 걸려 있어 실제 키가 커밋되지 않는다 — 커밋되는 빈 템플릿은
`env.example.template`이다. 처음 셋업할 때 이 템플릿을 `env.example`로
복사해서 키를 채운다. `.env`라는 파일은 더 이상 쓰지 않는다.

`pubspec.yaml`의 `assets` 목록을 고친 뒤에는 `flutter clean`을 한 번 돌리고
빌드해야 한다 — 안 그러면 캐시된 애셋 매니페스트가 그대로 남아 새로 추가한
파일이 apk에 안 들어간다. `unzip -l build/app/outputs/flutter-apk/app-debug.apk
| grep env.example`로 실제로 번들됐는지 확인할 수 있다.

**Gemini 모델명은 자주 바뀐다**: `gemini-2.5-flash`가 신규 사용자에게 단종돼
그 이름으로 요청하면 404가 난다. 지금은 `gemini-3.6-flash`를 쓴다
(`GeminiMenuDataSource._model`). 메뉴 추천이 원인 불명으로 실패하면 먼저
`curl -X POST "https://generativelanguage.googleapis.com/v1beta/models/$MODEL:generateContent?key=$KEY" ...`
로 모델명이 아직 유효한지부터 확인해라.

## 자주 쓰는 명령어

```bash
flutter run -d R8YX81EYL0X    # 안드로이드 태블릿
flutter test
dart analyze
```
