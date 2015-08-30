-- Use TEC
update tsystem_server set Auto_startup='N' where server_name = '__PP6000MANAGER';
update tsystem_server set Auto_startup='N' where server_name = '__TARR';
update tsystem_server set Auto_startup='Y' where server_name = '__TEC_SERVER';
select * from tsystem_server;