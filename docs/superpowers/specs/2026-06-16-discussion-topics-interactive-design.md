# discussion-topics: 가벼운 발제 추출 + 인터랙티브 진행보조 HTML

- 날짜: 2026-06-16
- 상태: 승인됨 (구현 계획 대기)
- 대상 스킬: `.claude/skills/discussion-topics/`

## 배경

`discussion-topics` 스킬은 `sessions/session_N/articles/`의 아티클에서 논제·질문을 뽑아 `sessions/session_N/discussion.html`(자체완결 단일 HTML)로 렌더한다. 현재 구조:

- 아티클당 서브에이전트 1개가 본문을 읽어 `검증 주장 / 논제 3~5 / 질문 2~3 / 요약` 반환 (컨텍스트 격리)
- 메인 에이전트가 `요약`+`검증 주장`만으로 교차 논제 종합
- 렌더 서브에이전트 1개가 `DESIGN.md`(크림/라이트 디자인 시스템)를 읽고 HTML 작성
- 폰트: KoPub Batang(명조/디스플레이) + Pretendard(본문) + JetBrains Mono(코드). 다크 표면 없음.

## 문제

1. 현재 논제는 아티클의 구체 수치·실험조건에 묶여 있어, 토론하려면 글 전체를 이해해야 한다. 스터디 현실(많은 참가자가 글을 다 못 읽고 옴)에서 진입 장벽이 높다.
2. 정적 문서라 스터디 진행을 거드는 역할을 못 한다.

## 목표

스터디원이 공유 화면을 함께 보며 토론을 진행하도록 돕는, 가벼운 톤의 인터랙티브 진행보조 HTML을 만든다.

검증 가능한 주장: **발제를 가벼운 높이로 뽑고 구체 근거를 펼침 뒤에 숨기면, 글을 다 읽지 않은 참가자도 토론에 진입할 수 있다.**

## 브레인스토밍 결정사항

| 항목 | 결정 |
|---|---|
| 발제 높이 | **C(가벼움)** — 숫자·실험조건 없이 누구나 입을 떼는 질문 |
| 사용 방식 | **공유 화면 1개, 진행자 주도** (개인별 저장 불필요) |
| 목차 구조 | **고정 사이드바 목차** (아티클→발제, scrollspy, 클릭 점프) |
| 진행보조 기능 | 사이드바 목차 + 근거 펼침 + Motion 등장/hover/pressed |
| 제외 | 스테퍼, 다룬 발제 체크, 타이머, 점투표, 개인 상태 저장 |

## 설계

### 1. 발제 추출 변경

기존의 `논제`(구체) + `질문` 분리는 단일 **`발제`** 목록으로 대체한다. 아티클당 서브에이전트(컨텍스트 격리 유지)가 토픽마다 **두 필드**를 반환한다:

- `발제`: C 높이의 가벼운 질문. 숫자·실험조건 없이도 토론에 진입 가능. 찬반·경험 공유가 갈리는 형태.
- `근거`: 그 발제를 뒷받침하는 아티클의 구체 사실(수치·시나리오). 1~2문장.

아티클당 발제 3~5개. 교차 논제도 동일 형태(가벼운 질문 + 세 글에서 모은 근거) 2~4개. 모든 `발제`·`근거` 문장은 기존 `CLARITY.md` 규칙을 따른다. 근거는 아티클에 실재하는 사실만 쓰고 지어내지 않는다.

반환 스키마(서브에이전트 출력):
```
검증 주장: <한 문장>
발제:
  - 질문: <가벼운 질문>
    근거: <구체 사실>
  (3~5개)
요약: <교차 종합용 한 문장>
```

### 2. HTML 출력 구조

자체완결 단일 `.html`. 기존 크림/라이트 디자인(KoPub Batang + Pretendard + JetBrains Mono, 다크 없음) 유지.

레이아웃: `grid-template-columns: 264px minmax(0,1fr)` (사이드바 + 본문, 본문 max-width ~820px).

- **고정 사이드바 목차** (`position:sticky; top:0; height:100vh`): `SESSION N · 논제` 제목, 아티클 그룹(번호·이름)별로 발제 짧은 라벨 링크. 현재 위치 scrollspy 강조(IntersectionObserver), 클릭 시 해당 발제로 스무스 스크롤.
- **본문**: 히어로(eyebrow + 디스플레이 H1 + 한 줄 안내) → 아티클 섹션(번호 배지 + serif 타이틀 + 이름) → 발제 카드들 → 교차 논제 밴드(cream-strong).
- **발제 카드**: 가벼운 질문이 헤드라인. 아래 `▸ 근거 보기` 버튼.
- **근거 펼침**: 버튼 클릭 시 카드의 `근거` 패널이 펼쳐짐(접기/펼치기 토글, `aria-expanded` 갱신, 라벨 `근거 보기`↔`근거 접기`).

### 3. 인터랙션

- **근거 펼침**: CSS `grid-template-rows: 0fr → 1fr` 전환(자연스러운 높이 애니메이션), chevron 회전. JS는 `.open` 토글만.
- **등장 애니메이션**: Motion One(`window.Motion`의 `inView`+`animate`)으로 카드·섹션이 스크롤 진입 시 `opacity 0→1` + `translateY(16px)→0`.
- **scrollspy**: IntersectionObserver로 현재 발제에 대응하는 사이드바 링크 강조.
- **hover/pressed**: CSS만. 카드 hover 시 살짝 떠오름(translateY -2px + 약한 그림자), 버튼 `:active`에서 `scale(.96)`.
- **접근성**: `prefers-reduced-motion: reduce`면 등장 애니메이션과 `scroll-behavior:smooth`를 끈다. JS 미동작 시 콘텐츠가 보이도록 초기 `opacity:0`은 `.js` 클래스 하위에서만 적용한다. 토글 버튼은 `aria-expanded` 유지.

### 4. 자체완결/CDN

- 폰트: 기존 CDN 유지(KoPub Batang `font-kopubworld@1.0.3`, Pretendard `orioncactus/pretendard`, JetBrains Mono Google Fonts).
- Motion One: `https://cdn.jsdelivr.net/npm/motion@11/dist/motion.js` (`<script>`, `window.Motion`). **SRI `integrity` + `crossorigin` 추가.**
- 토큰은 인라인 hex 대신 `:root` CSS 변수로 선언. 외부 참조는 폰트 CSS + Motion 스크립트로 한정.

### 5. 렌더 파이프라인

렌더 서브에이전트 1개가 `DESIGN.md`(시각 시스템) + SKILL.md의 인터랙션/렌더 계약을 받아 `discussion.html`을 쓴다. 메인 에이전트는 아티클 본문도 `DESIGN.md`도 직접 읽지 않는다(오케스트레이션 + 교차 종합만).

### 6. 스킬 파일 변경

- `SKILL.md`: 추출 계약(발제+근거 2필드)과 렌더 계약(사이드바 목차·근거 펼침·Motion·hover/pressed·접근성·Motion CDN+SRI)을 갱신. 100줄 초과 시 인터랙션 상세를 `INTERACTIONS.md`로 분리.
- `CLARITY.md`: 변경 없음(발제·근거 문장에 그대로 적용).
- `DESIGN.md`: 변경 없음(시각 시스템 유지).

## 범위 밖

스테퍼/현재발제 포커스 모드, 다룬 발제 체크, 타이머, 점투표, 개인별 상태 저장(localStorage).

## 검증

`/discussion-topics 1` 재실행 후 브라우저로 확인:

- 발제가 C 높이(숫자·조건 없이 읽힘), 근거 펼침에 구체 사실이 들어감
- 사이드바 scrollspy가 스크롤에 따라 현재 발제를 강조, 클릭 점프 동작
- 근거 펼침이 열리고 닫힘(높이 전환), `aria-expanded` 갱신
- Motion 등장 동작, `prefers-reduced-motion`에서 비활성
- 콘솔 에러 없음(favicon 제외), 외부 참조는 폰트+Motion만
- 전 밴드 라이트 팔레트(다크 잔재 없음), 폰트 KoPub Batang/Pretendard 적용
