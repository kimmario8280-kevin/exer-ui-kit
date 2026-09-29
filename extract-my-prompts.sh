#!/bin/bash

# 1. 저장할 대상 파일 지정 (현재 프로젝트 루트 내 Prompt.md)
# 만약 환경 변수가 없으면 현재 스크립트 실행 위치 기준 상위 폴더의 Prompt.md로 지정
OUTPUT_FILE="${CLAUDE_PROJECT_DIR:-$(dirname "$0")/..}/Prompt.md"

# 2. stdin으로 들어오는 Claude Code의 이벤트 JSON 수신
# Stop 훅 이벤트 발생 시 대화 원장(Transcript) 정보가 JSON 형태로 전달됩니다.
INPUT_JSON=$(cat)

# 3. Python 스크립트를 이용해 JSON 배열 내부의 사용자(user) 프롬프트만 안전하게 추출
# 대화 기록 중 'user'가 입력한 메시지만 골라내어 시간 정보와 함께 포맷팅합니다.
USER_PROMPTS=$(echo "$INPUT_JSON" | python3 -c '
import sys, json, os

try:
    data = json.load(sys.stdin)
    # Claude Code 버전에 따라 transcript가 들어오는 키 경로를 탐색합니다.
    # 일반적으로 inputs 혹은 transcript 배열 내에 메시지들이 축적됩니다.
    messages = data.get("transcript", data.get("inputs", []))
    
    if not messages and "hookSpecificOutput" in data:
        # 다른 형태의 입력 구조 방어 코드
        messages = data.get("hookSpecificOutput", [])

    for msg in messages:
        # 역할이 user(사용자)인 메시지의 텍스트만 추출
        if isinstance(msg, dict) and msg.get("role") == "user":
            content = msg.get("text", msg.get("content", ""))
            if content:
                print(f"### [User Prompt]\n{content.strip()}\n")
except Exception as e:
    # 파싱 실패 시 디버깅을 위해 표준 에러 출력
    print(f"Error parsing Claude prompt JSON: {e}", file=sys.stderr)
')

# 4. 추출된 프롬프트가 존재할 경우 Prompt.md 파일의 맨 뒤에 이어붙이기(Append)
if [ ! -z "$USER_PROMPTS" ]; then
    echo -e "## 기록 일시: $(date '+%Y-%m-%d %H:%M:%S')\n" >> "$OUTPUT_FILE"
    echo "$USER_PROMPTS" >> "$OUTPUT_FILE"
    echo -e "---\n" >> "$OUTPUT_FILE"
fi

# 5. Claude 훅 프로세스가 정상 종료되도록 exit code 0 반환
exit 0
