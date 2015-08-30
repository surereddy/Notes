netsh interface ip set address name="Local Area Connection" static 134.64.223.67 255.255.255.128  134.64.223.1 1
rem netsh interface ip add address name="Local Area Connection" 192.168.50.2 255.255.255.0
netsh interface ip set dns "Local Area Connection" static 192.158.120.14 primary
netsh interface ip add dns "Local Area Connection" 128.181.8.62
netsh interface ip add dns "Local Area Connection" 193.221.132.199
