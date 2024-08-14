#cat /etc/profile.d/motd.sh
Server=$(curl -sf https://raw.githubusercontent.com/jaejungkim/infra/main/server.txt)
if [ $? -eq 0 ]; then
 printf "%s\n" "$Server"
else
 echo "failed fetch"
fi
