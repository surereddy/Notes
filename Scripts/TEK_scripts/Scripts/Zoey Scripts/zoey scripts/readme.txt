It is from wang lu.

Note the default zoey_2.scr in the installation package is incorrect. Replace with Lu's.
The difference is in line 10.
In installation package: digits <6>;
Lu's: digits <9>;

Key commands:
voxload zoey_4.scr
voxstart -p6 -c zoey_4 -b 3001000  // -p specify the ORU port on which to run the test, -c specify a script to run, -b represents the called number
voxget -c zoey // to see all the results (identified by test id)
voxget -c zoey --ack // all results associate with this zoey context will be eliminated

See FAQ\A Summary of Zoey Test.msg for more.
