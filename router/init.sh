#! /bin/bash

sed -i 's/ripd=no/ripd=yes/' /etc/frr/daemons

# 設定ファイルの設定
echo "hostname $HOSTNAME" >> /etc/frr/vtysh.conf

/etc/init.d/frr start

echo "configure terminal
router rip
version 1
timers basic 10 60 40" > /home/commands # 実験のため通常よりタイマーを早くする

# コンテナごとのRIPの設定コマンド
if [ "$HOSTNAME" == "router0" ]; then
  echo "network 10.0.0.0/24
network 10.0.1.0/24
network 10.0.2.0/24" >> /home/commands

elif  [ "$HOSTNAME" == "router1" ]; then
  echo "network 10.0.1.0/24
network 10.0.3.0/24" >> /home/commands

elif  [ "$HOSTNAME" == "router2" ]; then
  echo "network 10.0.2.0/24
network 10.0.4.0/24" >> /home/commands

elif  [ "$HOSTNAME" == "router3" ]; then
    echo "network 10.0.3.0/24
network 10.0.4.0/24
network 10.0.5.0/24" >> /home/commands
fi

vtysh="vtysh"

while read line; do
  vtysh="$vtysh -c '$line'"
done < /home/commands

eval $vtysh

tail -f /dev/null

exit 0