#!/bin/bash
# 1-2 실험: 부정형 vs 긍정형 지시어
# 실행 방법: bash run_1_2.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TASKS_DIR="$SCRIPT_DIR/tasks"
RESULTS_DIR="$TASKS_DIR/results"
NEG_DIR="$SCRIPT_DIR/exp_negative"
POS_DIR="$SCRIPT_DIR/exp_positive"

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

echo "=== NEGATIVE 조건 실행 ==="
run_task "negative" 1 "$PROMPT1" "$NEG_DIR"
run_task "negative" 2 "$PROMPT2" "$NEG_DIR"
run_task "negative" 3 "$PROMPT3" "$NEG_DIR"

echo ""
echo "=== POSITIVE 조건 실행 ==="
run_task "positive" 1 "$PROMPT1" "$POS_DIR"
run_task "positive" 2 "$PROMPT2" "$POS_DIR"
run_task "positive" 3 "$PROMPT3" "$POS_DIR"

echo ""
echo "=== 결과 요약 ==="
for task_num in 1 2 3; do
  echo "--- Task${task_num} ---"
  for condition in negative positive; do
    result=$(python3 -c "
import json
data = json.load(open('$RESULTS_DIR/${condition}_task${task_num}.json'))
print(data.get('result','')[:300])
" 2>/dev/null)
    echo "[$condition] $result"
    echo ""
  done
done
