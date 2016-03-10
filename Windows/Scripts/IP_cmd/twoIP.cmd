rem To verify
rem http://www.howtogeek.com/51741/how-to-quickly-add-multiple-ip-addresses-to-windows-servers/

rem netsh interface ipv4 set address "Local Area Connection 3" static 10.242.0.109 255.255.255.254 10.242.0.253 1
netsh interface ip set address "Local Area Connection 3" static 10.242.0.109 255.255.255.254 10.242.0.253 1
netsh interface ipv4 add address "Local Area Connection 3" 192.168.1.2 255.255.255.0