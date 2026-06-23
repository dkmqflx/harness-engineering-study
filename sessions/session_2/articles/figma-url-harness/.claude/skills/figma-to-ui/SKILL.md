---
name: figma-to-ui
description: Figma URL을 받아 내부 프레임을 자동 탐색하고 병렬로 HTML로 구현합니다
---

# figma-to-ui

## 호출
```
/figma-to-ui <figma_url>
```

예시:
```
/figma-to-ui https://www.figma.com/design/Zf1uM7B85Yqhz4b0j0uNke/...?node-id=8007-41525
```

---

## 실행 단계

### 1단계 — URL 파싱 (인라인)

주어진 URL에서 두 값을 추출한다:
- **fileKey**: URL 경로의 `/design/<fileKey>/` 세그먼트
  - 예: `https://www.figma.com/design/Zf1uM7B85Yqhz4b0j0uNke/...` → `Zf1uM7B85Yqhz4b0j0uNke`
- **nodeId**: 쿼리 파라미터 `node-id`의 값 (`-`를 `:`로 변환)
  - 예: `?node-id=2-17` → `2:17`

---

### 2단계 — 얕은 탐색 (main agent가 MCP 직접 호출)

`mcp__plugin_figma_figma__get_metadata`를 다음 파라미터로 호출한다:
- `fileKey`: 1단계에서 추출한 값
- `nodeId`: 1단계에서 추출한 값
- `clientLanguages`: `"html,css"`
- `clientFrameworks`: `"unknown"`

반환된 XML에서:
- 직계 자식 노드 중 type이 `FRAME`, `COMPONENT`, `COMPONENT_SET`인 것만 추출
- **발견된 프레임 목록 전체를 사용자에게 출력** (이름, id, 크기) — 절대 숨기거나 필터링하지 않음

프레임 수가 10개 초과 시: 목록을 제시하고 사용자에게 어떤 것을 구현할지 확인한 후 진행.

---

### 3단계 — 병렬 구현 (프레임당 서브에이전트)

발견된 각 프레임마다 서브에이전트를 병렬로 실행한다.

**서브에이전트 프롬프트 템플릿:**

```
fileKey: {fileKey}
frameId: {frameId}
frameName: {frameName}

다음 순서로 작업하세요:

1. mcp__plugin_figma_figma__get_design_context를 호출하세요:
   - fileKey: "{fileKey}"
   - nodeId: "{frameId}"
   - clientLanguages: "html,css"
   - clientFrameworks: "unknown"
   - excludeScreenshot: false

2. 반환된 참조 코드와 메타데이터를 바탕으로 HTML+CSS를 작성하세요:
   - MCP가 반환한 참조 코드를 기반으로 적응(adapt)한다
   - 스타일은 .frame--{frameName} 클래스로 스코프 (공백은 -로 치환)
   - 루트 wrapper: <div class="frame frame--{frameName}">
   - 자식 요소에 재귀적으로 동일 스코프 적용
   - 설명 텍스트, 마크다운 펜스 없이 HTML만 반환
   - 시작: <style>, 그 다음 <div class="frame frame--{frameName}">
   - 응답이 비어있거나 오류가 발생하면 반드시 오류 메시지를 반환할 것 (빈 응답 금지)
```

**서브에이전트 반환값:** raw HTML 문자열 (style 블록 + div wrapper)

**실패 처리:** 서브에이전트가 빈 응답이나 idle 상태만 반환한 경우, main agent가 해당 프레임에 대해 `get_design_context`를 직접 호출하고 구현한다.

---

### 4단계 — HTML 갤러리 렌더 (렌더 서브에이전트)

모든 서브에이전트 결과를 수집한 후 렌더 서브에이전트를 실행:
1. 이 폴더의 `.claude/skills/figma-to-ui/RENDER.md`를 읽는다
2. 수집된 모든 컴포넌트 스니펫과 메타데이터(파일명, nodeId, 프레임 목록)를 전달한다
3. `output/{fileKey}-{nodeId}.html`로 갤러리 HTML을 작성한다

---

### 5단계 — 완료 보고

```
발견된 프레임: N개
구현 완료: M개
출력 파일: output/{fileKey}-{nodeId}.html
```
