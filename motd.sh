#cat /etc/profile.d/motd.sh
echo ""
#!/bin/bash

# 현재 접속한 터미널의 IP 주소 확인
current_ip=$(ip -4 --oneline a s scope global | awk '{print $4}' | awk -F'/' '{print $1}' | head -1)

# GitHub에서 server.txt 파일의 내용을 가져옴
Server=$(curl -sf https://raw.githubusercontent.com/jaejungkim/infra/main/server.txt)

# 파일을 성공적으로 가져왔는지 확인
if [ $? -eq 0 ]; then
  # 각 줄을 반복하면서 처리
  while IFS= read -r line; do
    # 라인이 IP 주소를 포함하고 있는지 확인
    if [[ $line == " $current_ip"* ]]; then
      # 깜박이는 텍스트 추가 (ANSI escape code 사용)
     printf -- "->%s\n" "$line"
    else
      printf "%s\n" "$line"
    fi
  done <<< "$Server"
else
  echo "failed fetch"
fi

echo ""
