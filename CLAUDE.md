# CLAUDE.md

이 문서는 Claude Code(claude.ai/code)가 이 저장소에서 **아직 만들어지지 않은 최종 산출물 `ui-kit-playground.html`**을 구현할 때 따라야 할 설계 명세서(Requirements Specification)다.

**이 문서는 현재 구현(`index.html` 등)을 설명하는 문서가 아니다.** `index.html`과 `docs/resource/` 목업들은 모두 과거/참고 자료이며, 앞으로의 개발은 이 문서가 정의하는 구조·데이터 모델·레이아웃·렌더링 방식·디자인 규칙을 기준으로 `ui-kit-playground.html`을 새로 작성하는 방향으로 진행한다. 구현이 끝난 뒤에도 이 문서는 "지금 코드가 이렇게 되어 있다"가 아니라 "코드는 이래야 한다"를 설명해야 한다.

## 1. 프로젝트 개요

CareerFoundry의 "32 UI Elements Designers Need To Know"를 기반으로 한 32가지 핵심 UI 컴포넌트와, 사이트 운영에 필수적인 공통 UX 레이어 컴포넌트(Alert, Confirm, Toast, Snackbar, Bottom Sheet, Notification Banner 등)를 한 화면에서 탐색·미리보기·복사할 수 있는 **정적 프론트엔드 UI 컴포넌트 레퍼런스 겸 플레이그라운드**를 만든다.

- 최종 산출물은 **단일 self-contained HTML 파일 하나(`ui-kit-playground.html`)**다. 빌드 도구, 패키지 매니저, 번들러, 테스트 러너를 전제하지 않는다.
- 브라우저로 파일을 직접 열거나 정적 서버로 서빙하는 것만으로 완전히 동작해야 한다.

```bash
# 예: 간단한 정적 서버로 확인하고 싶을 때
npx serve .
```

## 2. 레이아웃 요구사항

- **좌측 패널**: 32가지 UI 요소 목록 + 공통 UX 레이어 컴포넌트 목록을 카테고리별로 구분해 보여준다. 검색/필터로 좁혀볼 수 있어야 한다.
- **우측 패널**: 선택한 컴포넌트의
  - 이름(영문) + 한글명
  - 정의/설명(desc), 용도(usecase), 핵심 특징(feature)
  - Preview / HTML / CSS / JS 4개 탭
  을 보여준다.
- 좌측에서 항목을 선택하면 우측 패널 전체가 그 컴포넌트 기준으로 갱신된다.

## 3. 데이터 모델 설계

모든 컴포넌트(32 UI 요소 + 공통 UX 레이어 컴포넌트)는 **하나의 배열**로 관리한다. 여러 개의 분리된 배열로 쪼개지 않는다.

각 요소는 다음 구조를 따른다:

```js
{
  id: Number,        // 고유 식별자
  num: Number,        // 표시 순번 (목록에 보이는 01, 02...)
  name: String,        // 영문 이름
  nameKo: String,      // 한글명
  cat: String,         // 카테고리 키
  desc: String,        // 정의/설명
  usecase: String,     // 사용 사례
  feature: String,     // 핵심 특징
  html: String,        // 미리보기용 HTML 소스 (완전히 독립된 문자열)
  css: String,         // 미리보기용 CSS 소스
  js: String           // 미리보기용 JS 소스 (없으면 빈 문자열)
}
```

- `html`/`css`/`js`는 다른 컴포넌트나 전역 스타일에 의존하지 않는 **완전히 독립된 코드 문자열**이어야 한다. 미리보기 iframe에 그대로 주입했을 때 그 자체로 동작해야 한다.
- 카테고리 체계(`CATS`/`CAT_ORDER` 또는 동등한 구조)는 입력 컨트롤(input), 내비게이션(nav), 정보 표시(info), 컨테이너(container), 공통 UX 레이어(layer) 분류와 표시 순서를 정의한다.
- 새 컴포넌트를 추가할 때는 이 배열에 항목 하나를 추가하는 것만으로 좌측 목록·우측 상세·미리보기·복사 기능이 모두 자동으로 연결되어야 한다(데이터 기반 렌더링).

## 4. 렌더링 방식

- **탭 전환**: Preview / HTML / CSS / JS 탭 전환은 `display` 토글 방식으로 구현한다(탭마다 DOM을 다시 만들지 않는다).
- **미리보기 격리**: 선택된 요소의 `html`+`css`+`js`를 하나의 완전한 HTML 문서로 조립해 `<iframe>`의 `srcdoc`에 할당한다. 이렇게 컴포넌트가 플레이그라운드 자체의 스타일·스크립트와 완전히 격리된 채로 실제 동작해야 한다.
- **코드 하이라이트**: HTML/CSS/JS 소스는 `<pre><code>`로 렌더링하고 highlight.js(CDN)로 문법 하이라이트를 적용한다.
- **복사 버튼**: 각 코드 탭에는 복사 버튼을 두고 `navigator.clipboard.writeText()`로 해당 탭의 소스만 클립보드에 복사한다.
- **검색/필터**: 좌측 목록은 `name`/`nameKo` 기준으로 필터링하고, 매칭되는 항목이 없는 카테고리 그룹은 통째로 숨긴다.

## 5. CSS 작성 규칙

- **Tailwind 등 외부 유틸리티 클래스 프레임워크 사용을 금지**한다. `docs/resource/ui-component.html`, `ui-components-32-catalog.html`처럼 Tailwind CDN에 의존하는 방식은 참고만 하고 그대로 가져오지 않는다.
- 모든 컴포넌트는 `.accordion`, `.btn`, `.modal-box`처럼 **의미 있는 시맨틱 클래스명을 가진 self-contained CSS**로 작성한다.
- 목적은 복사·이식성 극대화다 — 사용자가 코드 탭에서 HTML/CSS/JS를 그대로 복사해 다른 프로젝트에 붙여넣었을 때 외부 의존성 없이 동작해야 한다.

## 6. 디자인 규칙 — anti-ai-slop 강제 적용

[.claude/rules/anti-ai-slop.md](.claude/rules/anti-ai-slop.md)는 `ui-kit-playground.html`을 포함해 이 저장소에서 생성하는 모든 이미지·HTML·SVG·슬라이드에 적용되는 **강제 규칙**이며 기본 동작을 override한다. 요지:

- **금지**: 그라데이션 일체, 색 들어간 그림자·글로우·`blur≥20px`, backdrop-filter 글래스모피즘, hover/load 시 transform·fade·키프레임 장식 모션, 배경 워터마크/그리드/광선, 카드 상단 컬러 액센트 바, 이모지 불릿, 마케팅 상투어.
- **강제**: 무채색 베이스 + 액센트 1색(색은 의미에만 사용), 그림자는 중성 회색 1단계(`0 1px 2px rgba(0,0,0,.06)`)만, 구획은 `1px solid border` + 여백으로, `border-radius`는 0~8px, 위계는 크기·굵기·여백·정렬로 만든다. 폰트는 기본값(Inter/Roboto/Arial/system)으로 수렴하지 않고 목적에 맞게 의도적으로 고른 뒤 이유를 한 줄 밝힌다.
- 출력 전 `anti-ai-slop.md`의 자가 점검 체크리스트(그라데이션/컬러 그림자/장식 모션/배경 장식 등)를 반드시 통과시킨다.

## 7. 참고 리소스 파일의 역할

`docs/resource/`의 파일들은 모두 **동작·구조 참고용**이며, 그대로 가져다 쓰는 배포 대상이 아니다. 특히 비주얼(색상·그림자·모션)은 전부 6번 규칙에 맞게 다시 작성한다.

- `component-portfolio.html` — 좌측 목록 + 우측 상세(탭/미리보기 iframe) 전체 구조의 **정본(canonical) 참고 자료**. 레이아웃 그리드, 탭 전환, `srcdoc` 기반 미리보기, 코드 복사 흐름의 기준은 이 파일을 따른다.
- `ui-component.html` — 상단 브레드크럼, 탭 바 등 레이아웃 아이디어 참고용. Tailwind 기반이므로 **CSS 작성 방식(5번 규칙)은 따르지 않는다.**
- `ui-components-32-catalog.html` — 32개 컴포넌트를 하나의 데이터 배열(`id`/`name`/`desc`/`html`/`css`/`script`)로 관리하는 **데이터 모델 설계(3번 규칙)의 직접적인 참고 자료**. 단, Tailwind 유틸리티 클래스와 `script: () => {...}` 함수 직렬화 방식은 가져오지 않고, `js` 문자열 필드로 단순화한다.
- `label-chip-system.html` — 색상/칩/라벨 시스템 참고용.
- `alert-ui-showcase.html` — Toast, Top Banner, Inline Alert, Slide-over, Shake, Full-screen Takeover, Popover, Command Bar, Notification List, Destructive Confetti 등 **공통 UX 레이어 컴포넌트의 동작 참고 자료**. 다크 테마, 그라데이션, 컬러 글로우, 장식 애니메이션을 다수 사용하므로 **동작 로직만 참고하고 비주얼은 6번 규칙에 맞게 전면 재작성**한다.
- `colorpicker.html`, `color-personal-card.html`, `ui-elements-demo.html` — 색상·카드 등 세부 컴포넌트 스타일 참고용.

## 8. 문서 형식 규칙

- 이 CLAUDE.md는 한글로 작성하며, 앞으로도 **미래 지향적 설계 문서**로 유지한다.
- "현재 코드가 어떻게 동작하는가"를 설명하는 구현 설명 문서로 되돌아가지 않는다. 항상 "개발자가 무엇을 따라야 하는가"라는 설계·요구사항 중심으로 작성한다.
- `ui-kit-playground.html` 구현이 진행되며 설계가 바뀌면, 이 문서를 구현 결과에 맞춰 사후 기술하지 말고 **의도한 설계 자체를 갱신**한다.

## 프롬프트 기록 훅

`.claude/settings.local.json`에 **Stop 훅**이 걸려 있어, 세션 종료 시 `extract-my-prompts.sh`가 이 폴더의 Claude Code 세션에서 사용자가 입력한 프롬프트만 뽑아 [Prompt.md](Prompt.md)에 append한다. `settings.local.json`은 개인/머신 전용이라 `.gitignore` 처리돼 있다(커밋되지 않음).
