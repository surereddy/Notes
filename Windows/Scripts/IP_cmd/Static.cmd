rem netsh interface ip set address "本地连接 7" static 192.168.5.77 255.255.255.0  
netsh interface ip set address "本地连接 5" static 192.168.50.77 255.255.255.0  
 
rem netsh interface ip set address "本地连接 7" static 172.24.252.152 255.255.255.0 172.24.252.1 1
rem route add 172.24.0.0 mask 255.255.0.0 172.24.252.1 metric 1
rem netsh interface ip add dns "本地连接 7" 172.24.192.4


rem 3GRC
rem netsh interface ip set address "本地连接 5" static 172.18.11.228 255.255.255.0 172.18.11.2 1
rem netsh interface ip set dns "本地连接 5" static 202.97.224.69 primary

