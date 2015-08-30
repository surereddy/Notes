for /L %i in (6020,1,6021) do netsh firewall add portopening UDP %i "UDP %i"
