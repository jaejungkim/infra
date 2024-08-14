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

###인증서 만료일 알림
# 인증서 만료일을 가져와서 Unix 타임스탬프로 변환
cert_expiry=$(curl -v --connect-timeout 7 --max-time 7 https://tt.inclunet.com 2>&1 | grep -i "expire date" | awk '{print substr($0, index($0,$4))}' | xargs -I {} date -d "{}" +"%s")

# 현재 날짜의 Unix 타임스탬프
current_date=$(date +"%s")

# 7일(7 * 24 * 60 * 60초)을 Unix 타임스탬프로 계산
seven_days=$((7 * 24 * 60 * 60))

# 만료일까지 남은 시간 계산 (초 단위)
time_until_expiry=$((cert_expiry - current_date))

# 남은 시간을 일 단위로 변환
days_until_expiry=$((time_until_expiry / 86400))

# 만료일이 7일 이내인지 확인
if [ "$time_until_expiry" -le "$seven_days" ]; then
  echo "ALERT: *.inclunet.com TLS인증서가 $days_until_expiry일 이내에 만료됩니다. 인증서를 갱신하세요!"
else
  echo "*.inclunet.com TLS인증서 유효기한 $days_until_expiry일 남아 있습니다."
fi
echo ""

system_release=$(cat /etc/system-release)
printf "%s\n" "${system_release}"
