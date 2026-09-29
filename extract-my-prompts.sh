#!/bin/bash

# 1. 저장할 대상 파일 지정 (현재 프로젝트 루트 내 Prompt.md)
# 만약 환경 변수가 없으면 현재 스크립트 실행 위치 기준 Prompt.md로 지정
OUTPUT_FILE="${CLAUDE_PROJECT_DIR:-$(dirname "$0")}/Prompt.md"

# 2. stdin으로 들어오는 Stop 훅 이벤트 JSON 수신
# 이 JSON에는 대화 내용이 직접 들어있지 않고, transcript_path(jsonl 파일 경로)만 들어있다.
INPUT_JSON=$(cat)

# 3. transcript_path가 가리키는 jsonl 파일을 열어 사용자(user) 프롬프트만 추출
# python3가 없는(또는 Windows Store 스텁만 있는) 환경도 있어 node로 작성한다.
USER_PROMPTS=$(echo "$INPUT_JSON" | node -e '
let raw = "";
process.stdin.on("data", (chunk) => { raw += chunk; });
process.stdin.on("end", () => {
  try {
    const fs = require("fs");
    const data = JSON.parse(raw);
    const transcriptPath = data.transcript_path;
    if (!transcriptPath) process.exit(0);

    const lines = fs.readFileSync(transcriptPath, "utf-8").split("\n");
    for (const line of lines) {
      const trimmed = line.trim();
      if (!trimmed) continue;

      let entry;
      try {
        entry = JSON.parse(trimmed);
      } catch {
        continue;
      }

      // Claude Code transcript jsonl 라인은 {"type": "user", "message": {"role": "user", "content": [...]}} 형태
      if (entry.type !== "user") continue;
      const content = entry.message && entry.message.content;

      let text = "";
      if (typeof content === "string") {
        text = content.trim();
      } else if (Array.isArray(content)) {
        text = content
          .filter((block) => block && block.type === "text" && block.text)
          .map((block) => block.text)
          .join("\n")
          .trim();
      }

      if (text) {
        console.log(`### [User Prompt]\n${text}\n`);
      }
    }
  } catch (e) {
    console.error(`Error parsing Claude transcript: ${e.message}`);
  }
});
')

# 4. 추출된 프롬프트가 존재할 경우 Prompt.md 파일의 맨 뒤에 이어붙이기(Append)
if [ ! -z "$USER_PROMPTS" ]; then
    echo -e "## 기록 일시: $(date '+%Y-%m-%d %H:%M:%S')\n" >> "$OUTPUT_FILE"
    echo "$USER_PROMPTS" >> "$OUTPUT_FILE"
    echo -e "---\n" >> "$OUTPUT_FILE"
fi

# 5. Claude 훅 프로세스가 정상 종료되도록 exit code 0 반환
exit 0
