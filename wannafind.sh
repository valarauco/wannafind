#!/bin/bash

# @author valarauco

which masscan &> /dev/null
if [[ $? -ne 0 ]]; then
  echo "masscan not found: apt install masscan ?"
  exit 1 
fi

which nmap &> /dev/null
if [[ $? -ne 0 ]]; then
  echo "nmap not found: apt install nmap ?"
  exit 1 
fi

subnet=$1
tmp_subnet_list=$(mktemp)
script_file_ms17_010="/usr/share/nmap/scripts/smb-vuln-ms17-010.nse"
script_file_cve_2017_7494="/usr/share/nmap/scripts/samba-vuln-cve-2017-7494.nse"


if [[ ! -f  "$script_file_ms17_010" ]] ; then
  echo "Updating nmap scripts for ms17-010..."
  sudo wget -O "$script_file_ms17_010" https://raw.githubusercontent.com/cldrn/nmap-nse-scripts/master/scripts/smb-vuln-ms17-010.nse
  sudo chown root:root "$script_file_ms17_010"
  sudo nmap --script-updatedb
fi

if [[ ! -f  "$script_file_cve_2017_7494" ]] ; then
  echo "Updating nmap scripts for cve-2017-7494..."
  sudo wget -O "$script_file_cve_2017_7494" https://gist.githubusercontent.com/wongwaituck/62c863ba7aa28a2d22d0fe9cbe14a18b/raw/056e217a955d8fff985a4dde001f9f937fa9c543/samba-vuln-cve-2017-7494.nse
  sudo chown root:root "$script_file_cve_2017_7494"
  sudo nmap --script-updatedb
fi

echo "Scanning $subnet"
sudo masscan -p445  $subnet > $tmp_subnet_list
nmap -Pn -oA results -p445 --script smb-vuln-ms17-010 --script samba-vuln-cve-2017-7494 -iL $tmp_subnet_list | grep -B7 -A13 "VULNERABLE:"
rm $tmp_subnet_list

exit 0

