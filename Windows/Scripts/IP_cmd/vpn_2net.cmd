rem ----------------------Readme----------------------------
rem replace REALGW with the real gateway!
rem replace VPNGW with the dynamic vpn gateway!
rem replace REALMETRIC with the original real gateway metric for Network Destination 0.0.0.0.
rem --------------------------------------------------
set "VPNGW=172.24.253.173"
set "REALGW=192.168.3.109"
rem set "REALMETRIC=25"
route delete 0.0.0.0
route add 172.0.0.0 mask 255.0.0.0 %VPNGW% metric 1
route add 135.0.0.0 mask 255.0.0.0 %VPNGW% metric 1
route add 139.0.0.0 mask 255.0.0.0 %VPNGW% metric 1
route add 192.168.50.0 mask 255.255.255.0 %VPNGW% metric 1
rem for MSN alcanet proxy
route add 192.11.0.0 mask 255.255.0.0 %VPNGW% metric 1
rem route add 0.0.0.0 mask 0.0.0.0 %REALGW% metric %REALMETRIC%
route add 0.0.0.0 mask 0.0.0.0 %REALGW%
rem --------------------------------------------------
rem set dns for outlook problem in Beijing.
rem netsh interface ip set dns "本地连接" static 135.251.34.36 primary