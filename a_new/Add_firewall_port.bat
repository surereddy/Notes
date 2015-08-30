for /L %i in (6000,1,6019) do netsh firewall add portopening UDP %i "UDP %i"
netsh firewall add portopening UDP 5060 "UDP 5060"
netsh firewall add portopening UDP 2427 "UDP 2427"
netsh firewall add portopening UDP 2727 "UDP 2727"