@echo off
color 0E
title LinkTree
pushd "%~dp0"
mode con cols=100 lines=50
:Menu
set userinp=
cls
Echo -----------------------------
echo+
echo  W. Reset Wlan
echo  L. Reset Lan
echo  F. Flush DNS and ARP
echo  D. Use DHCP on LAN
echo  T. Trace Ping and DNS 8.8.8.8
echo  I. IP Defaults 192.168.1.10/24
echo  M. Manual IP Config
echo  X. Exit
echo+
Echo -----------------------------
set /p userinp= ^> Select Your Option : 
set userinp=%userinp:~0,3%
if /i "%userinp%"=="W" goto :Wlan
if /i "%userinp%"=="L" goto :Lan
if /i "%userinp%"=="F" goto :DNS
if /i "%userinp%"=="D" goto :DHCP
if /i "%userinp%"=="T" goto :Trace
if /i "%userinp%"=="I" goto :Default
if /i "%userinp%"=="M" goto :Manual
if /i "%userinp%"=="X" goto :Exit
goto :Menu

:Wlan
echo "WLan reset in progress..."
ipconfig /release
netsh interface set interface name="WiFi" admin=disable
netsh interface set interface name="WiFi" admin=enable
netsh interface set interface name="Drahtlosnetzwerkverbindung" admin=disable
netsh interface set interface name="Drahtlosnetzwerkverbindung" admin=enable
ipconfig /renew
goto :DNS

:Lan
echo "Lan reset in progress..."
ipconfig /release
netsh interface set interface name="Local Area Connection" admin=disable
netsh interface set interface name="Local Area Connection" admin=enable
netsh interface set interface name="LAN-Verbindung" admin=disable
netsh interface set interface name="LAN-Verbindung" admin=enable
netsh interface set interface name="Ethernet" admin=disable
netsh interface set interface name="Ethernet" admin=enable
ipconfig /renew
goto :DNS

:DHCP
echo "Setting DHCP"
ipconfig /release
netsh interface ipv4 set address name="Local Area Connection" source=dhcp
netsh interface ipv4 set dnsservers name="Local Area Connection" source=dhcp
netsh interface ipv4 set address name="LAN-Verbindung" source=dhcp
netsh interface ipv4 set dnsservers name="LAN-Verbindung" source=dhcp
netsh interface ipv4 set address name="Ethernet" source=dhcp
netsh interface ipv4 set dnsservers name="Ethernet" source=dhcp
ipconfig /renew
goto :DNS

:Trace
echo "Trace"
ping 8.8.8.8
nslookup www.google.de
ping www.google.de 
tracert -d 8.8.8.8
pause
goto Exit

:Default
echo "Default" 
ipconfig /release
netsh interface ip set address "Local Area Connection" static 192.168.1.10 255.255.255.0 192.168.1.1 1 
netsh interface ip set address "LAN-Verbindung" static 192.168.1.10 255.255.255.0 192.168.1.1 1
netsh interface ip set address "Ethernet" static 192.168.1.10 255.255.255.0 192.168.1.1 1
netsh interface ip add dns "Local Area Connection" 192.168.1.1
netsh interface ip add dns "LAN-Verbindung" 192.168.1.1
netsh interface ip add dns "Ethernet" 192.168.1.1
netsh int ip show config 
goto Exit

:Manual
echo "Please enter Static IP Address Information" 
echo "Static IP Address:" 
set /p IP_Addr=

echo "Default Gateway:" 
set /p D_Gate=

echo "Subnet Mask:" 
set /p Sub_Mask=

echo "Setting Static IP Information" 
netsh interface ip set address "Local Area Connection" static %IP_Addr% %Sub_Mask% %D_Gate% 1 
netsh interface ip set address "LAN-Verbindung" static %IP_Addr% %Sub_Mask% %D_Gate% 1 
netsh interface ip add dns "Local Area Connection" %D_Gate%
netsh interface ip add dns "LAN-Verbindung" %D_Gate%
netsh int ip show config 
pause 
goto Exit

:DNS
ipconfig /flushdns
ipconfig /registerdns
arp -d
cls
ipconfig
echo Reset done

:Exit