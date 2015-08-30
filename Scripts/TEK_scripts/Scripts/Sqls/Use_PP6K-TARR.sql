--update tsystem_server set host_name = 'W-SHPD-JXIE';
update tsystem_server set host_name = 'W-SHPD-JXIE', Auto_startup='Y' where server_name = '__PP6000MANAGER';
update tsystem_server set host_name = 'W-SHPD-JXIE', Auto_startup='Y' where server_name = '__TARR';
update tsystem_server set host_name = '127.0.0.1', Auto_startup='N' where server_name = '__TEC_SERVER';
select * from tsystem_server;

-- Use TEC
--update tsystem_server set host_name = 'QASVR6', Auto_startup='N' where server_name = '__PP6000MANAGER';
--update tsystem_server set host_name = 'QASVR6', Auto_startup='N' where server_name = '__TARR';
--update tsystem_server set Auto_startup='Y' where server_name = '__TEC_SERVER';