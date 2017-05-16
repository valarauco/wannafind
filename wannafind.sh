#!/bin/bash

# @author valarauco

which masscan &> /dev/null
if [[ $? -ne 0 ]]; then
  echo "mascan not found: apt install masscan ?"
  exit 1 
fi

which nmap &> /dev/null
if [[ $? -ne 0 ]]; then
  echo "nmap not found: apt install nmap ?"
  exit 1 
fi

subnet=$1
tmp_subnet_list=$(mktemp)
script_file="/usr/share/nmap/scripts/smb-vuln-ms17-010.nse"

if [[ ! -f  "$script_file" ]] ; then
  echo "Updating nmap scripts..."
  sudo wget -O "$script_file" https://raw.githubusercontent.com/cldrn/nmap-nse-scripts/master/scripts/smb-vuln-ms17-010.nse
  sudo chown root:root "$script_file"
  sudo nmap --script-updatedb
fi

echo "Scanning $subnet"
sudo masscan -p445  $subnet > $tmp_subnet_list
nmap -Pn -oA results -p445 --script smb-vuln-ms17-010 -iL $tmp_subnet_list | grep -B7 -A13 "VULNERABLE:"
rm $tmp_subnet_list

exit 0

