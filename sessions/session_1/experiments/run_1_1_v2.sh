#!/bin/bash
# Fat v2 vs Docs 실험
# 실행 방법: bash run_1_1_v2.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TASKS_DIR="$SCRIPT_DIR/tasks"
RESULTS_DIR="$TASKS_DIR/results"
FAT_DIR="$SCRIPT_DIR/exp_fat_v2"
DOCS_DIR="$SCRIPT_DIR/exp_docs"

TASK1_CODE=$(cat "$TASKS_DIR/task1.py")
TASK2_CODE=$(cat "$TASKS_DIR/task2.py")
TASK3_CODE=$(cat "$TASKS_DIR/task3.py")

PROMPT1="다음 함수에 입력값 검증을 추가해줘:

$TASK1_CODE"

PROMPT2="다음 코드를 리팩토링해줘:

$TASK2_CODE"

PROMPT3="다음 함수에 로깅을 추가해줘:

$TASK3_CODE"

run_task() {
  local condition=$1
  local task_num=$2
  local prompt=$3
  local work_dir=$4
  local out_file="$RESULTS_DIR/${condition}_task${task_num}.json"

  echo "▶ Running [${condition}] task${task_num}..."
  cd "$work_dir" && claude --print "$prompt" --output-format json > "$out_file" 2>&1
  echo "  저장됨: $out_file"
}

mkdir -p "$RESULTS_DIR"

echo "=== FAT_V2 조건 실행 ==="
run_task "fat_v2" 1 "$PROMPT1" "$FAT_DIR"
run_task "fat_v2" 2 "$PROMPT2" "$FAT_DIR"
run_task "fat_v2" 3 "$PROMPT3" "$FAT_DIR"

echo ""
echo "=== DOCS 조건 실행 ==="
run_task "docs" 1 "$PROMPT1" "$DOCS_DIR"
run_task "docs" 2 "$PROMPT2" "$DOCS_DIR"
run_task "docs" 3 "$PROMPT3" "$DOCS_DIR"

echo ""
echo "=== 토큰 비교 ==="
for task_num in 1 2 3; do
  python3 -c "
import json

def summary(path, label):
    data = json.load(open(path))
    u = data.get('usage', {})
    new_tokens   = u.get('input_tokens', 0) + u.get('cache_creation_input_tokens', 0)
    cache_tokens = u.get('cache_read_input_tokens', 0)
    total        = new_tokens + cache_tokens
    print(f'  [{label}] new={new_tokens:,}  cache_read={cache_tokens:,}  total={total:,}')

print('Task${task_num}:')
summary('$RESULTS_DIR/fat_v2_task${task_num}.json', 'fat_v2')
summary('$RESULTS_DIR/docs_task${task_num}.json',   'docs  ')
"
done

echo ""
echo "=== 응답 요약 ==="
for task_num in 1 2 3; do
  echo "--- Task${task_num} ---"
  for condition in fat_v2 docs; do
    result=$(python3 -c "
import json
data = json.load(open('$RESULTS_DIR/${condition}_task${task_num}.json'))
print(data.get('result','')[:300])
" 2>/dev/null)
    echo "[$condition] $result"
    echo ""
  done
done
