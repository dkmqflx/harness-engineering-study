# discussion.html 인터랙션·렌더 계약

`discussion-topics`가 만드는 `discussion.html`의 구조·인터랙션 규칙. 렌더 서브에이전트는 `DESIGN.md`(시각 토큰)와 이 파일을 함께 따른다. 산출물은 **자체완결 단일 HTML**, 크림/라이트 팔레트(다크 표면 없음), 진행자가 공유 화면에서 함께 보며 토론을 진행하는 용도.

## 레이아웃
- `.layout`: CSS grid `264px minmax(0,1fr)` — 좌 고정 사이드바 + 본문(max-width ~820px). 880px 이하 1단 스택(사이드바는 상단 가로 목차, `position:static`).
- 간격·패딩·radius는 DESIGN.md 토큰(섹션 96px, 카드 32px, r-lg 12px). 모든 토큰은 `:root` CSS 변수로 선언, 인라인 hex 금지.

## 폰트 (CDN + 폴백)
- KoPub Batang: `https://cdn.jsdelivr.net/npm/font-kopubworld@1.0.3/css/batang.css` (family `"KoPubWorld Batang"`)
- Pretendard: `https://cdn.jsdelivr.net/gh/orioncactus/pretendard/dist/web/static/pretendard.min.css` (family `"Pretendard"`)
- JetBrains Mono: Google Fonts(코드)
- `--font-display: "KoPubWorld Batang", serif` / `--font-sans: "Pretendard", -apple-system, BlinkMacSystemFont, system-ui, "Apple SD Gothic Neo", "Malgun Gothic", sans-serif` / `--font-mono: "JetBrains Mono", ui-monospace, monospace`
- 디스플레이 음수 letter-spacing은 -0.5px 이내.

## 사이드바 목차 (고정)
- `position:sticky; top:0; height:100vh; overflow:auto`, 우측 hairline 경계, surface-soft 배경.
- 내용: `SESSION N · 논제` 제목 → 아티클 그룹(번호·이름)별 발제 짧은 라벨 링크(`href="#<발제id>"`) → 교차 논제 그룹.
- 라벨은 발제 질문을 6~14자로 줄인 요약(질문 전문 아님).
- scrollspy: `IntersectionObserver`(`rootMargin: '-45% 0px -45% 0px'`, 화면 중앙 밴드)로 현재 위치를 추적하고, 밴드 내에서 **화면 중앙에 가장 가까운 발제**의 링크에 `.active`(코랄 좌측 보더 + 굵게 + surface-card 배경). 여러 카드가 밴드에 걸리면 중앙 최근접으로 결정(경합 방지).

## 본문
- 히어로: `caption-uppercase` eyebrow `SESSION N · 하네스 엔지니어링 스터디`, 디스플레이 serif H1, 한 줄 안내(아티클의 발견에서 한 걸음 더 + "근거 보기" 안내).
- 아티클 섹션: 번호 배지(코랄·mono·pill) + serif 타이틀 + muted 이름.
- 발제 카드 `.thesis`: 열린 질문이 헤드라인 `.q`, 아래 근거 토글 버튼.
- 교차 논제: surface-cream-strong 밴드.

## 근거 펼침
- 버튼 `.evidence-toggle`: `▶ 근거 보기` ↔ `▼ 근거 접기`(chevron 회전), `aria-expanded` 토글.
- 펼침: CSS `grid-template-rows: 0fr → 1fr` 전환(`.34s cubic-bezier(.22,1,.36,1)`), 내부 wrapper `overflow:hidden`. `.thesis.open`에서 `1fr`.
- 근거 본문: canvas 배경 + 코랄 좌측 보더(3px) + `아티클이 밝힌 것` 라벨. 코드 토큰·수치는 mono 인라인 `<code>`.
- JS는 `.open` 토글 + 라벨/`aria-expanded` 갱신만. 높이는 CSS가 처리.

## 등장 애니메이션 (Motion One)
- 스크립트: `https://cdn.jsdelivr.net/npm/motion@11.18.2/dist/motion.js`(`window.Motion`). `<script>`에 `integrity="sha384-…" crossorigin="anonymous"` 필수(정확 버전 고정 + 해시 일치). 해시: `curl -s <url> | openssl dgst -sha384 -binary | openssl base64 -A`.
- `Motion.inView(el, () => Motion.animate(el, {opacity:[0,1], transform:['translateY(16px)','translateY(0)']}, {duration:.5, easing:[.22,1,.36,1]}), {margin:'0px 0px -12% 0px'})` — 아티클 헤더·발제 카드·교차 밴드(`[data-reveal]`)에 적용.
- 초기 숨김 `opacity:0`은 `.js [data-reveal]`에서만 적용(`<html class="js">`를 head 인라인 스크립트로 추가). JS/Motion 미동작 시 콘텐츠가 보이고, Motion 미로드 시 `opacity:1`로 폴백.

## hover/pressed (CSS만)
- `.thesis:hover` → `translateY(-2px)` + 약한 그림자, `transition:.16s`.
- `.evidence-toggle:hover` → surface-cream-strong 배경 + 코랄 보더, `:active` → `scale(.96)`.
- `.toc a:hover` → surface-card 배경.

## 접근성
- `@media (prefers-reduced-motion: reduce)`: `scroll-behavior:auto`, `.js [data-reveal]{opacity:1}`(등장 끔).
- 토글 버튼 `aria-expanded` 유지, 사이드바는 `<nav>`.

## 자체완결 점검
- 외부 참조는 폰트 CSS 3개 + Motion 스크립트 1개로 한정. 그 외 네트워크 의존 없음.
