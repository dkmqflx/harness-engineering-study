---
name: discussion-topics
description: Extract light discussion prompts(발제) — open questions that probe each article's findings, each with a tucked 근거 — from a study session's articles, then render a standalone interactive HTML facilitation aid (sticky sidebar TOC, click-to-reveal 근거, Motion entrance, hover/pressed). Use when the user wants to generate 발제/토론 주제 for a sessions/session_N folder, prep a harness-engineering-study discussion, or build/refresh a session's discussion HTML. Invoke with the session number (e.g. /discussion-topics 1).
---

# Discussion Topics

각 아티클에서 가벼운 발제(아티클의 발견을 출발점으로 한 열린 질문 + 근거)를 뽑고, 세션 교차 발제를 더해 `sessions/session_N/discussion.html`로 출력한다. HTML은 [DESIGN.md](DESIGN.md)(시각)와 [INTERACTIONS.md](INTERACTIONS.md)(구조·인터랙션)를 따르는 자체완결 단일 파일이다.

## 핵심 규칙

- **아티클별 발제는 아티클마다 별도 서브에이전트**(아티클 1개당 Agent 호출 1개)로 뽑는다. 한 아티클이 다른 아티클의 발제 생성에 섞이지 않게 하기 위함이다.
- **HTML 렌더는 별도 렌더 서브에이전트 1개**가 맡는다. [DESIGN.md](DESIGN.md)와 [INTERACTIONS.md](INTERACTIONS.md)를 읽고 적용한다.
- 메인 에이전트는 아티클 본문도, 디자인/인터랙션 계약 파일도 직접 읽지 않는다 — 오케스트레이션과 교차 종합만 한다.
- 발제·근거 문장은 [CLARITY.md](CLARITY.md)를 따른다.

## 워크플로우

1. **세션 결정.** 번호/경로를 주면 `sessions/session_N`. 없으면 `sessions/session_*`를 나열해 묻는다.
2. **아티클 수집.** `sessions/session_N/articles/**/*.md` Glob, `.gitkeep` 제외. 없으면 알리고 멈춘다.
3. **아티클별 추출 — 아티클당 서브에이전트 1개, 병렬 실행**(한 메시지에 Agent 여러 개, `subagent_type: general-purpose`). 각 에이전트에 아티클 경로 1개, [CLARITY.md](CLARITY.md) 전문, 출력 계약을 준다. 그 파일 하나만 읽으라 지시한다. 반환: `검증 주장` 1개 / `발제` 3~5개(각 발제 = `질문`[아티클이 이미 밝힌 내용을 되묻지 말고, 그 발견을 출발점으로 아직 안 풀린 점을 던지는 열린 질문] + `근거`[그 질문의 배경이 되는 아티클의 구체 사실 1~2문장, 수치·시나리오 포함]) / `요약`(교차 종합용 한 문장). 근거는 아티클에 실재하는 사실만 쓰고 지어내지 않는다.
4. **교차 종합.** 반환된 `요약`+`검증 주장`만으로(전체 본문 아님) 아티클 2개 이상을 잇는 `교차 발제` 2~4개를 만든다(각 발제 = 열린 질문 + 세 글에서 모은 근거).
5. **HTML 렌더 — 렌더 서브에이전트 1개.** 콘텐츠 데이터 전부(아티클별 타이틀·이름·발제[질문+근거] + 교차 발제), DESIGN.md 경로(`.claude/skills/discussion-topics/DESIGN.md`)와 INTERACTIONS.md 경로(`.claude/skills/discussion-topics/INTERACTIONS.md`), 출력 경로를 준다. 에이전트가 `sessions/session_N/discussion.html`을 쓴다. **파일이 이미 있으면 덮어쓰기 전 사용자에게 확인받는다.**
6. **보고.** 파일 경로, 아티클 수, 발제 수를 알린다. 요청받기 전에는 커밋하지 않는다.

## 렌더 계약 (요약 — 상세는 [INTERACTIONS.md](INTERACTIONS.md))

- **자체완결 단일 .html**, 크림/라이트 팔레트(다크 표면 금지). 토큰은 DESIGN.md 값을 `:root` CSS 변수로(인라인 hex 금지).
- 좌측 **고정 사이드바 목차**(아티클→발제, scrollspy, 클릭 점프) + 본문 **발제 카드** + `▸ 근거 보기` 펼침.
- **Motion One**(`motion@11`, SRI `integrity` 필수)으로 스크롤 등장, hover 떠오름·pressed는 CSS. `prefers-reduced-motion`이면 끔.
- 폰트: KoPub Batang(명조/디스플레이) + Pretendard(본문) + JetBrains Mono(코드), CDN+폴백. 디스플레이 음수 letter-spacing -0.5px 이내.
- 콘텐츠→컴포넌트: 발제 질문 = 카드 헤드라인, 근거 = 펼침 패널(코드·수치 mono), 교차 발제 = surface-cream-strong 밴드, 푸터 = 라이트.
- **금지**: dark navy 표면, 쿨 그레이·순백 canvas, serif 디스플레이 굵게, 코랄 남용, serif 자리에 sans.

## 명료성

발제·근거·교차 발제의 모든 문장은 [CLARITY.md](CLARITY.md)를 따른다(비유 금지, 표준 용어만, 본문 밖 참조 금지, 정보 없는 문장 제거). 규칙 전문을 추출 서브에이전트 프롬프트에 그대로 넣는다.
