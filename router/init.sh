#! /bin/bash

sed -i 's/ripd=no/ripd=yes/' /etc/frr/daemons

# 設定ファイルの設定
echo "hostname $HOSTNAME" >> /etc/frr/vtysh.conf

/etc/init.d/frr start

echo "configure terminal
router rip
version $RIP_VERSION
timers basic 10 60 40" > /home/commands # 実験のため通常よりタイマーを早くする

# ホスト内のIFとIPアドレスを取得
ip address show | grep "scope global" | while read line; do
  # それぞれのインタフェースでRIPを有効化
  ifname=$(echo "$line" | grep -oE '[A-Za-z0-9]*$')
  echo "network $ifname" >> /home/commands
done
# コンテナごとのRIPの設定コマンドはここでif文で分岐して設定したほうがいいかも

echo "#! /bin/bash 
vtysh \\" > /home/frr.sh

cat /home/commands | while read line; do
  echo " -c '$line' \\" >> /home/frr.sh
done

chmod +x /home/frr.sh
/home/frr.sh

tail -f /dev/null

exit 0