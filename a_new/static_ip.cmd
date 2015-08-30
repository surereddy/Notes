netsh interface ip set address name="Corporate Network" static  192.158.127.55 255.255.255.0
rem netsh interface ip set address name="Corporate Network" static  192.158.127.55 255.255.252.0  192.158.124.1 1
netsh interface ip add address name="Corporate Network" 192.168.50.2 255.255.255.0
rem netsh interface ip set dns "Corporate Network" static 192.158.120.14 primary
rem netsh interface ip add dns "Corporate Network" 128.181.2.62