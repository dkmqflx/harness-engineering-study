# figma-to-ui HTML 갤러리 렌더 계약

## 역할
구현된 컴포넌트 스니펫들을 받아 단일 자급자족 HTML 갤러리 파일로 조립한다.

## 출력 경로
```
output/<fileKey>-<nodeId>.html
```

---

## 디자인 시스템

기존 `discussion.html`과 동일한 크림 캔버스 토큰 사용:

```css
:root {
  --canvas:              #faf9f5;
  --surface-soft:        #f5f0e8;
  --surface-card:        #efe9de;
  --surface-cream-strong:#e8e0d2;
  --ink:                 #141413;
  --body:                #3d3d3a;
  --muted:               #6c6a64;
  --primary:             #cc785c;
}
```

폰트:
- 제목/레이블: KoPub Batang (CDN: `cdn.jsdelivr.net/npm/font-kopubworld@1.0.3`)
- 본문: Pretendard (CDN: `cdn.jsdelivr.net/gh/orioncactus/pretendard`)

---

## HTML 구조

```html
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{파일명} — Figma → HTML</title>
  <!-- 폰트 CDN -->
  <!-- :root CSS 변수 -->
  <!-- 갤러리 레이아웃 스타일 -->
  <!-- 각 컴포넌트의 <style> 블록 (순서대로 삽입) -->
</head>
<body>
  <header class="gallery-header">
    <p class="gallery-kicker">FIGMA → HTML 자동 구현</p>
    <h1 class="gallery-title">{파일명}</h1>
    <p class="gallery-meta">node-id: {nodeId} · 프레임 {N}개</p>
  </header>

  <main class="gallery-grid">
    <!-- 프레임당 카드 반복 -->
    <div class="gallery-card">
      <p class="gallery-card-label">{frameName}</p>
      <div class="gallery-card-body">
        <!-- 해당 프레임의 <div class="frame frame--..."> 삽입 -->
      </div>
    </div>
  </main>
</body>
</html>
```

---

## 갤러리 레이아웃 스타일 규칙

```css
body {
  background: var(--canvas);
  font-family: 'Pretendard', sans-serif;
  color: var(--ink);
  margin: 0;
  padding: 0;
}

.gallery-header {
  padding: 60px 40px 40px;
  border-bottom: 1px solid var(--surface-cream-strong);
}

.gallery-kicker {
  font-size: 11px;
  letter-spacing: 1.2px;
  text-transform: uppercase;
  color: var(--muted);
  margin: 0 0 12px;
  font-family: 'JetBrains Mono', monospace; /* 없으면 monospace */
}

.gallery-title {
  font-family: 'KoPub Batang', serif;
  font-size: 40px;
  font-weight: 700;
  letter-spacing: -0.4px;
  margin: 0 0 8px;
}

.gallery-meta {
  font-size: 13px;
  color: var(--muted);
  margin: 0;
}

.gallery-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(360px, 1fr));
  gap: 32px;
  padding: 40px;
}

.gallery-card {
  background: var(--surface-card);
  border-radius: 12px;
  overflow: hidden;
}

.gallery-card-label {
  font-size: 11px;
  letter-spacing: 1.2px;
  text-transform: uppercase;
  color: var(--muted);
  padding: 12px 16px 0;
  margin: 0;
  font-family: monospace;
}

.gallery-card-body {
  padding: 16px;
  overflow: auto;  /* 넓은 모바일 프레임이 그리드를 깨지 않도록 */
}
```

---

## 스타일 충돌 방지

- 각 컴포넌트 `<style>`은 이미 `.frame--<name>`으로 스코프되어 있음
- 갤러리 자체 스타일은 `.gallery-*` 네임스페이스만 사용
- 컴포넌트 `<style>` 블록들은 `<head>` 안에 순서대로 삽입

---

## 외부 의존성 (CDN만, 외부 JS 없음)

```html
<link rel="preconnect" href="https://cdn.jsdelivr.net">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/font-kopubworld@1.0.3/dist/font-kopubworld.min.css">
<link rel="preconnect" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css">
```

JavaScript 없음. 완전 자급자족 HTML.

---

## 완료 조건

렌더 에이전트는 파일을 작성한 후 다음을 확인한다:
- [ ] 모든 컴포넌트 스니펫이 갤러리 카드에 포함됨
- [ ] 외부 의존성이 CDN 폰트 2개뿐임
- [ ] `<style>` 블록이 `.frame--*`으로 스코프되어 충돌 없음
- [ ] 브라우저에서 열면 크림 배경 위에 컴포넌트 갤러리가 표시됨
