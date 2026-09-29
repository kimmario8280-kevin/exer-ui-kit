# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

프론트엔드 UI 컴포넌트 학습·레퍼런스 사이트. CareerFoundry의 "32 UI Elements Designers Need To Know"를 기반으로 32가지 핵심 UI 요소와, 사이트 운영에 필수적인 공통 UX 레이어 컴포넌트(Alert, Confirm, Toast, Snackbar, Bottom Sheet, Notification Banner)를 한 화면에서 탐색·미리보기·복사할 수 있게 만든 정적 사이트다.

빌드 도구, 패키지 매니저, 테스트 러너가 없는 순수 정적 HTML/CSS/JS 프로젝트다. npm/빌드/린트/테스트 명령은 존재하지 않는다.

## 실행 방법

빌드 과정이 없으므로 [index.html](index.html)을 브라우저로 직접 열거나, 정적 서버로 서빙하면 된다.

```bash
# 예: 간단한 정적 서버로 확인하고 싶을 때
npx serve .
```

## 아키텍처

`index.html` 하나에 레이아웃, 스타일, 컴포넌트 데이터, 렌더링 로직이 모두 들어있는 단일 파일 구조다.

- **좌측 사이드바 + 우측 상세 뷰 레이아웃**: `.layout` 그리드가 `.side`(카테고리별 컴포넌트 목록 + 검색창)와 `.main`(선택한 컴포넌트의 상세 뷰)로 나뉜다.
- **데이터 기반 렌더링**: 컴포넌트는 코드가 아니라 데이터 배열로 정의된다.
  - `ELEMENTS` (1~16번), `ELEMENTS_2` (17~32번): CareerFoundry 32가지 UI 요소.
  - `LAYER_ELEMENTS` (33~38번): 공통 UX 레이어 컴포넌트(Alert Dialog, Confirm Dialog, Toast, Snackbar, Bottom Sheet, Notification Banner).
  - 세 배열을 `DATA = ELEMENTS.concat(ELEMENTS_2).concat(LAYER_ELEMENTS)`로 합쳐서 사용한다.
  - 각 요소는 `{ n, name, ko, cat, desc, html, css, js }` 형태이며, `html`/`css`/`js`는 **미리보기 iframe에 그대로 주입되는 완전히 독립된 코드 문자열**이다. 새 컴포넌트를 추가할 때는 이 배열들 중 하나에 항목을 추가하면 사이드바·상세뷰·미리보기·복사 기능이 자동으로 연결된다.
- **카테고리 체계**: `CATS`/`CAT_ORDER` 객체가 `input`(입력 컨트롤), `nav`(내비게이션), `info`(정보 표시), `container`(컨테이너), `layer`(공통 UX 레이어) 5개 분류와 표시 순서를 정의한다. 사이드바는 `CAT_ORDER`를 순회하며 `DATA`를 필터링해 그룹을 렌더링한다.
- **상세 뷰 렌더링 흐름** (`select(n)` 함수):
  1. 선택된 항목의 이름/한글명/설명을 헤더에 출력.
  2. 미리보기/HTML/CSS/JS 4개 탭과 각 탭에 대응하는 패널(`.panel[data-tab=...]`)을 생성.
  3. `buildSrcdoc(e)`가 요소의 `html`+`css`+`js`를 하나의 완전한 HTML 문서 문자열로 조립해 `<iframe class="preview-frame">`의 `srcdoc`에 할당 — 컴포넌트가 페이지 전체 스타일과 격리된 채 실제로 동작한다.
  4. `codeBlock()`이 HTML/CSS/JS 소스를 `<pre><code class="language-*">`로 렌더링하고, `hljs.highlightElement()`로 highlight.js(CDN) 문법 하이라이트를 적용한다.
  5. 각 코드 패널의 복사 버튼은 `navigator.clipboard.writeText()`로 해당 소스만 클립보드에 복사한다.
- **검색**: 사이드바 검색창은 `nav-item`의 `data-name`(영문+한글명)을 기준으로 필터링하고, 항목이 하나도 없는 카테고리 그룹은 통째로 숨긴다.
- **외부 의존성**: Google Fonts(Noto Sans KR, JetBrains Mono), highlight.js(CDN, CSS+core+xml/css/javascript 언어팩)만 사용하며 별도 프레임워크나 번들러는 없다.

## 참고 리소스

`docs/resource/`에 디자인/구조 참고용 목업들이 있다(모두 사이트 배포물이 아닌 참고 자료):

- `component-portfolio.html` — 현재 `index.html`의 레이아웃·데이터 구조·탭/미리보기 방식의 직접적인 베이스.
- `ui-component.html`, `ui-components-32-catalog.html` — Tailwind 기반의 대안 카탈로그 UI(카테고리 카드, 검색/필터 바 등 UX 아이디어 참고용).
- `alert-ui-showcase.html` — Toast, Banner, Slide-over, Shake, Full-screen, Popover, Command Bar, Notification List, Confetti 등 UX 레이어 패턴의 원본 참고 자료. `index.html`의 `LAYER_ELEMENTS`가 이 중 일부(Toast, Banner, Bottom Sheet 계열)를 단순화해 반영했다.
- `label-chip-system.html`, `colorpicker.html`, `color-personal-card.html`, `ui-elements-demo.html` — 색상/칩/라벨 등 세부 컴포넌트 스타일 참고용.

## 강제 디자인 규칙 — anti-ai-slop

[.claude/rules/anti-ai-slop.md](.claude/rules/anti-ai-slop.md)는 이 저장소의 모든 이미지·HTML·SVG·슬라이드 생성에 적용되는 **강제 규칙**이며 기본 동작을 override한다. 요지:

- **금지**: 그라데이션 일체, 색 들어간 그림자·글로우·`blur≥20px`, backdrop-filter 글래스모피즘, hover/load 시 transform·fade·키프레임 장식 모션, 배경 워터마크/그리드/광선, 카드 상단 컬러 액센트 바, 이모지 불릿, 마케팅 상투어.
- **강제**: 무채색 베이스 + 액센트 1색(색은 의미에만), 그림자는 중성 회색 1단계(`0 1px 2px rgba(0,0,0,.06)`)만, 구획은 `1px solid border`+여백으로, `border-radius` 0~8px, 위계는 크기·굵기·여백·정렬로, 폰트는 기본값(Inter/Roboto/Arial/system) 수렴 금지하고 목적에 맞게 의도적으로 고르고 이유를 한 줄 밝힘.

**주의**: `alert-ui-showcase.html`과 카탈로그 일부(헤더 숫자·카드 이미지의 `linear-gradient`)는 이 규칙 이전 자료라 위반 요소가 있다. 동작·구조는 참고하되 **비주얼은 규칙에 맞게 다시 작성**한다. 출력 전 `anti-ai-slop.md`의 자가 점검 체크리스트(그라데이션/컬러 그림자/장식 모션/배경 장식 등)를 통과시킨다.

## 프롬프트 기록 훅

`.claude/settings.local.json`에 **Stop 훅**이 걸려 있어, 세션 종료 시 `extract-my-prompts.sh`가 이 폴더의 Claude Code 세션에서 사용자가 입력한 프롬프트만 뽑아 [Prompt.md](Prompt.md)에 append한다. `settings.local.json`은 개인/머신 전용이라 `.gitignore` 처리돼 있다(커밋되지 않음).