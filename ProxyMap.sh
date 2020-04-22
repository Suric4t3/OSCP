#!/bin/bash

ss=$(grep -v "#" /etc/proxychains.conf | grep socks)

echo "[ ------------------------- ]"
echo "[ ProxyMap v0.1 ... Suric4t3]"
echo "[ ------------------------- ]"
echo "[                           ]"
echo "[      Config Socks         ]"
echo "["      $ss "    ]"
echo "[ ------------------------- ]"

read -p '[*] IP: ' ip_map
echo "[*] Would you like top-port : y/n?"
read answer

if [ $answer == 'y' ]
then
	read -p '[*] top-port ? : ' topport_map
else
	read -p '[*] port 1 n ? : ' sport_map
fi

echo "[!] Top Port " $topport_map
echo "[!] Sel Port " $sport_map
echo "[!] IP " $ip_map

if [[ ! -d $ip_map ]]; then
	        mkdir "$ip_map"
fi
	
date >> $ip_map/ProxyMap_$ip_map.txt	
if [ $answer == 'y' ]
then
	echo "[+] Generating Port "
	nmap -sT --top-ports $topport_map localhost -v -oG - | grep "TCP" | sed  's/# Ports scanned: TCP(//g' | sed 's/) UDP(0;) SCTP(0;) PROTOCOLS(0;)//g' | sed 's/\,/\n/g' | sed 's/\-/\n/g' | sed 's/\;/\n/g' > _tmp_proxymap.txt
	ss=$(wc -l _tmp_proxymap.txt)
	echo "[+] $ss Port selected"
	head _tmp_proxymap.txt
	echo "[........]"
	tail _tmp_proxymap.txt
	echo "[+] Scan launched .. "
	sleep 3
	cat  _tmp_proxymap.txt | xargs -P 50 -I{} proxychains nmap -p {} -sT -Pn --open -n -T4 --min-parallelism 100 --min-rate 1 --oG $ip_map/ProxyMap_$ip_map --append-output $ip_map
else
	seq $sport_map| xargs -P 50 -I{} proxychains nmap -p {} -sT -Pn --open -n -T4 --min-parallelism 100 --min-rate 1 --oG $ip_map/ProxyMap_$ip_map --append-output $ip_map
fi

date >> $ip_map/ProxyMap_$ip_map.txt
echo "[+] Generating Repport .."
grep open/tcp $ip_map/ProxyMap_$ip_map
grep open/tcp $ip_map/ProxyMap_$ip_map >> $ip_map/ProxyMap_$ip_map.txt

rm _tmp_proxymap.txt
