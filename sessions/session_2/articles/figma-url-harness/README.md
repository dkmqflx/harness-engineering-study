# Figma 페이지 URL 하나로 컴포넌트 전체를 구현하는 하네스

**검증한 주장:**

> Figma 컴포넌트마다 "copy link to selection"을 전달하는 방식과 비교해, 페이지 URL 하나로 하네스를 실행하면 사용자 개입 횟수가 줄어드는가?

결론부터: **N개 컴포넌트에 2N+1번 상호작용하던 것이 1번으로 줄었다.**

---

## 들어가며

Figma와 Claude를 같이 쓰는 일반적인 방식은 이렇다.

1. Figma에서 컴포넌트를 선택하고 "Copy link to selection"으로 링크를 복사한다.
2. Claude에 링크를 붙여넣고 "이 컴포넌트를 HTML로 구현해줘"라고 요청한다.
3. N개 컴포넌트면 이 과정을 N번 반복하고, 결과물을 직접 조립한다.

컴포넌트가 4개라면 상호작용은 최소 9번이다 — 링크 복사 4번, Claude 요청 4번, 조립 1번. 컴포넌트가 많아질수록 선형으로 늘어난다.

Figma MCP를 사용하면 Claude가 Figma 노드 트리를 직접 읽을 수 있다. 그렇다면 링크를 일일이 넘겨줄 필요가 없다. 페이지 URL 하나만 주면 Claude가 내부 프레임을 스스로 탐색하고 병렬로 구현할 수 있지 않을까? 이 아이디어를 하네스로 만들어 검증했다.

---

## Figma MCP

Figma 공식 MCP 서버는 `https://mcp.figma.com/mcp`에서 제공하는 Remote HTTP 서버다. Claude Code에 등록하면 다음 두 도구가 핵심적으로 사용된다.

```
mcp__plugin_figma_figma__get_metadata(fileKey, nodeId?)
mcp__plugin_figma_figma__get_design_context(fileKey, nodeId)
```

| 도구 | 역할 | 반환값 |
|------|------|--------|
| `get_metadata` | 노드 구조 파악 (얕은 탐색) | XML — 노드 ID, 레이어 타입, 이름, 크기 |
| `get_design_context` | 컴포넌트 상세 구현 (깊은 탐색) | 참조 코드 + 스크린샷 + 컨텍스트 메타데이터 |

`get_metadata`의 `nodeId`를 생략하면 파일의 최상위 페이지 목록을 반환한다. `nodeId`를 지정하면 해당 노드의 하위 트리를 XML로 반환한다. `get_design_context`는 단순 노드 데이터가 아닌 이미 코드로 변환된 참조 구현을 반환하는 것이 커뮤니티 패키지와의 핵심 차이점이다.

기존 방식에서 개발자가 수동으로 복사하던 `fileKey`와 `nodeId` 조합을 Claude가 URL에서 직접 파싱해 이 도구에 넘길 수 있다. 이것이 전체 하네스의 핵심 전제다.


---

## 하네스 설계

전체 흐름을 `.claude/skills/figma-to-ui/SKILL.md`에 오케스트레이션 계약으로 정의했다. Claude Code가 `/figma-to-ui` 슬래시 커맨드를 받으면 이 파일을 읽고 단계별로 실행한다. 코드 없이 마크다운 명세만으로 에이전트 파이프라인이 정의된다.

```
/figma-to-ui https://www.figma.com/design/<fileKey>/...?node-id=<nodeId>
```

### 1단계 — URL 파싱

URL에서 두 값을 추출한다. 도구 호출 없이 인라인으로 처리.

- `fileKey`: `/design/<fileKey>/` 세그먼트
- `nodeId`: `?node-id=` 쿼리 파라미터 (`2-17` 형식)

### 2단계 — 얕은 탐색 (shallow discovery)

```
get_metadata(fileKey=<fileKey>, nodeId=<nodeId>)
```

Main agent가 MCP를 직접 호출한다. `get_metadata`는 노드 트리의 구조만 XML로 반환하므로 응답이 가볍다. 전체 디자인 데이터를 한 번에 받지 않는 이유가 여기 있다 — 이전 커뮤니티 패키지(`figma-developer-mcp`)로 동일 노드를 호출했을 때 실측 응답이 55–79KB였다. `get_metadata`는 이름, ID, 크기만 포함하므로 탐색 단계에서는 훨씬 효율적이다.

반환된 XML에서 직계 자식 노드 중 `FRAME`, `COMPONENT`, `COMPONENT_SET` 타입만 추출한다. 발견된 프레임 목록을 전체 출력한 뒤 진행한다. 프레임 수가 10개를 초과하면 사용자에게 목록을 제시하고 확인 후 진행하도록 설계했다. 이 실험에서는 4개였으므로 사용자 확인 없이 자동 진행.

### 3단계 — 병렬 구현

발견된 각 FRAME마다 서브에이전트를 생성해 병렬로 실행한다. N개 프레임 = N개 MCP 호출이 동시에 실행된다.

**서브에이전트의 역할:**

1. `get_design_context(fileKey, frameId)` 호출 — 특정 프레임의 참조 코드 + 스크린샷을 가져온다
2. 반환된 참조 코드를 바탕으로 HTML+CSS로 적응(adapt)

커뮤니티 패키지와의 핵심 차이가 여기서 드러난다. `get_design_context`는 raw 노드 데이터(`layoutMode`, `fills`, `textStyle` 등)가 아닌 이미 코드로 변환된 참조 구현을 반환한다. 서브에이전트가 직접 Figma 속성을 CSS로 변환하는 대신, MCP가 제공한 참조 코드를 기반으로 적응하면 된다.

3. 결과를 `.frame--{frameName}` 클래스로 스코프된 CSS + 루트 `<div>`로 반환

스코프 전략이 중요하다. 여러 컴포넌트 스니펫을 하나의 HTML에 합칠 때 스타일 충돌을 막으려면 각 서브에이전트가 자신의 프레임 이름을 클래스 prefix로 사용해야 한다.

### 4단계 — 갤러리 렌더

모든 서브에이전트 결과를 수집한 뒤 `output/{fileKey}-{nodeId}.html`로 조립한다. 갤러리 레이아웃은 `RENDER.md`에 출력 계약으로 분리해뒀다 — CSS 그리드(`repeat(auto-fill, minmax(360px, 1fr))`), 폰트(Pretendard + KoPub Batang), 캔버스 색상(`#faf9f5`) 등.

### 5단계 — 완료 보고

```
발견된 프레임: 4개
구현 완료: 4개
출력 파일: output/ZkTozxBZJC16Us5ivXPYx5-2-17.html
```

---

## 실험 결과

**대상:** CareerMizing Component Library, `node-id=2-17`

이 노드는 CANVAS 타입이며 직계 자식으로 4개의 FRAME을 갖는다:

| 프레임 | 설명 |
|--------|------|
| `focus-ring` | 키보드/보조기기 사용 시 입력 대상 요소 강조 표시 |
| `aspect-ratio` | 비율 그리드 (1:1, 3:2, 5:4, 16:9 등 portrait/landscape 조합) |
| `slot` | 컴포넌트 내부 자리를 비워두고 다른 요소로 교체 가능한 패턴 |
| `overlay` | 모달·드로어와 함께 쓰이는 반투명 배경 레이어 |

### 개입 횟수 비교

| 방식 | 사용자 개입 횟수 | 계산 |
|------|---------------|------|
| 수동 (link to selection) | 9 | 링크 복사 4 + Claude 요청 4 + 조립 1 |
| 하네스 (`/figma-to-ui <url>`) | 1 | URL 하나 |

컴포넌트가 N개일 때 수동 방식은 2N+1번, 하네스는 1번이다.

### 3회 반복 실험 — 서브에이전트 위임 성공 여부

동일한 URL로 하네스를 3회 실행하고 각 서브에이전트의 위임 성공(HTML 반환) / 실패(idle notification 반환) 여부를 기록했다.

**먼저 짚어둘 것:** ❌ fallback이 "구현 실패"를 의미하지 않는다. 서브에이전트가 idle notification만 반환하면 main agent가 해당 프레임의 `get_design_context`를 직접 호출해 구현한다. **3회 모두, 4개 컴포넌트는 항상 갤러리에 출력됐다.** 이 표가 측정하는 건 구현 커버리지가 아니라 **병렬 위임의 효율** — 서브에이전트가 성공하면 main agent 컨텍스트를 아끼고, 실패하면 main agent가 직접 처리하면서 컨텍스트를 더 소비한다.

| 프레임 | Run 1 | Run 2 | Run 3 |
|--------|-------|-------|-------|
| `focus-ring` | ✅ sub-agent | ❌ fallback | ✅ sub-agent |
| `aspect-ratio` | ❌ fallback | ✅ sub-agent | ❌ fallback |
| `slot` | ❌ fallback | ❌ fallback | ✅ sub-agent |
| `overlay` | ❌ fallback | ❌ fallback | ✅ sub-agent |
| **위임 성공** | 1/4 | 1/4 | 3/4 |
| **구현 완료** | 4/4 | 4/4 | 4/4 |

12개 서브에이전트 호출 중 5개(42%)가 HTML을 반환했고, 7개(58%)는 `{"type":"idle_notification","idleReason":"available"}` 만 반환하고 종료했다. 매 실행마다 어떤 프레임이 위임에 성공하는지는 달랐다.

### 출력

4개 컴포넌트를 하나의 HTML 갤러리로 조립해 `output/{fileKey}-{nodeId}.html`로 출력했다. 각 컴포넌트는 독립 카드로 배치되며 스타일은 `.frame--{name}` 클래스로 격리되어 있다. 카드 헤더에 sub-agent / fallback 배지가 표시된다.

- `output/run1-ZkTozxBZJC16Us5ivXPYx5-2-17.html`
- `output/run2-ZkTozxBZJC16Us5ivXPYx5-2-17.html`
- `output/run3-ZkTozxBZJC16Us5ivXPYx5-2-17.html`

---

## 관찰 — 잘 된 것과 안 된 것

### 관찰: 서브에이전트 silent fail — 비결정적 패턴

3회 실험에서 12개 서브에이전트 중 8개가 HTML 없이 idle notification만 반환하고 종료했다.

```json
{"type":"idle_notification","from":"impl-slot","idleReason":"available"}
```

주목할 점은 **패턴의 비결정성**이다. 동일 URL, 동일 프레임, 동일 SKILL.md로 실행했음에도 어떤 서브에이전트가 성공하는지 매번 달랐다. `focus-ring`은 Run 1과 3에서 성공했고 Run 2에서 실패했다. `aspect-ratio`는 Run 2에서만 성공했다. `slot`은 Run 1, 2에서는 idle로 종료됐지만 Run 3에서는 HTML을 반환했다 — 동일 프레임이 같은 하네스 실행 내에서도 결과가 다를 수 있음을 보여준다.

SKILL.md에 명시적인 fallback 절을 추가한 덕분에 하네스 자체는 멈추지 않았다 — main agent가 silent fail을 감지하고 `get_design_context`를 직접 호출해 구현했다. 사용자 관점에서 4개 컴포넌트는 매 실행에서 모두 출력됐다.

이 실패는 서브에이전트 런타임의 특성 문제로 보인다. Claude Code 내부에서 서브에이전트가 idle 상태를 보고하는 조건이 prompt 내용이 아닌 런타임 상태(큐 크기, 컨텍스트 용량 등)에 의해 결정되는 것으로 추정된다.

### 관찰: 응답 크기와 2단계 탐색의 이유

2단계(얕은 탐색)에서 `node-id=2-17`로 MCP를 호출했더니 응답이 55KB였다. 이걸 하나의 에이전트 컨텍스트에서 전부 처리하면 4개 프레임의 상세 데이터가 뒤섞여 들어온다. 3단계에서 프레임별로 분리해 다시 호출하는 이유가 여기 있다 — 각 서브에이전트는 자신의 프레임 데이터만 처리하므로 컨텍스트가 깔끔하고 병렬 실행이 가능하다.

### 관찰: get_design_context가 반환하는 참조 코드

커뮤니티 패키지(`figma-developer-mcp`)는 `layoutMode`, `fills`, `textStyle` 같은 raw 노드 속성을 반환했다. 에이전트가 이를 CSS로 직접 변환해야 했다.

공식 MCP의 `get_design_context`는 다르다. 이미 코드로 변환된 참조 구현을 반환한다 — React 컴포넌트 + Tailwind 클래스 형태로. 예를 들어 overlay 프레임에 대한 응답에는 다음과 같은 코드가 포함됐다:

```jsx
<div className="w-[1920px] h-[1080px] bg-[var(--bg/dim,rgba(0,0,0,0.5))]" />
```

에이전트는 `layoutMode: HORIZONTAL` → `flex-row` 변환을 직접 추론할 필요 없이, Tailwind fallback hex 값(`rgba(0,0,0,0.5)`)을 CSS로 추출하는 작업만 하면 된다. 변환의 책임이 MCP 레이어로 이동한다.

단, 이 참조 코드는 React+Tailwind 기준이라 HTML+CSS 목표와 간극이 있다. 서브에이전트는 Tailwind 유틸리티 클래스를 plain CSS로, JSX 문법을 HTML로 변환하는 추가 추론을 수행해야 한다. 복잡한 컴포넌트(variant가 많거나 constraint 기반 레이아웃)에서는 이 변환이 완전하지 않을 수 있다.

---

## 결론

검증 결과: **사용자 개입 1회로 N개 컴포넌트 자동 구현**이 가능하다.

하네스가 작동한 이유는 두 가지다.

첫째, 공식 Figma MCP가 링크가 아닌 구조화된 데이터와 참조 코드를 반환하기 때문에 모델이 직접 구현에 착수할 수 있다. `get_design_context`는 단순 노드 속성이 아닌 이미 코드로 변환된 참조 구현을 반환한다. 개발자가 "어떤 컴포넌트"를 지정하지 않아도 모델이 스스로 트리를 탐색해 대상을 찾고 구현까지 완료한다.

둘째, `get_metadata`(얕은 탐색) → `get_design_context`(깊은 탐색) 2단계 구조가 응답 크기 문제를 회피한다. 전체 파일을 한 번에 받지 않고, 먼저 프레임 목록만 확인한 뒤 각 프레임을 서브에이전트에 분산시킨다. 결과적으로 컨텍스트가 격리되고 병렬 실행이 가능해진다.

### 남은 문제

현재 설계에서 보완이 필요한 부분은 명확하다.

- **서브에이전트 실패 감지:** idle notification과 빈 응답을 하네스가 탐지하고 재시도해야 한다
- **렌더 컨텍스트 정규화:** absoluteBoundingBox 크기가 뷰포트를 초과하는 경우 처리
- **variant 처리:** 컴포넌트 변형이 많은 경우 COMPONENT_SET 자식을 어떻게 선별할지
- **토큰 비용 실측:** 수동 방식 대비 하네스의 실제 토큰 소비량 비교

### 더 넓은 의미

이 하네스는 특정 Figma 파일에 의존하지 않는다. `fileKey`와 `nodeId`만 다르면 어떤 Figma 페이지에도 동일하게 실행된다. SKILL.md라는 마크다운 명세 하나가 에이전트 파이프라인의 계약이 되는 구조 — 이 패턴이 Figma에만 국한되지 않는다는 점이 핵심이다. MCP를 통해 외부 데이터 소스를 읽을 수 있다면, 동일한 구조로 탐색-병렬구현-조립 파이프라인을 만들 수 있다.
