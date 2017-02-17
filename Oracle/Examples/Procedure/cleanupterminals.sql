set serveroutput on
set echo off
set verify off

declare
	v_update_id number(10);
	v_category varchar2(255);
	v_version  varchar2(255);
	v_terminal_id  varchar2(10);
--------------------------------------------------------------------------------	
	cursor terminal_list
	is 
	select 	t.terminal_id_long
	from 	arcos_config.terminal t
	left join 	arcos_log.operation_log ol on ol.terminal=t.terminal_id_long
	where 	1=1
		and substr(t.terminal_id_long,0,1) = '9'
    and t.terminal_type in ('CVMm' ,'FPDt')
		and ol.operation_log_id is null -- This is to ensure no oplogs
		and t.is_active = 0
    and t.LAST_CHANGE < sysdate -60
	order by 	t.terminal_id_long;
	
--------------------------------------------------------------------------------	
	cursor all_jobs_for_terminal( pi_terminal VARCHAR2)
	is
	select 	distinct update_id
	from 	arcos_file_manager.distribution_job_terminal djt
	inner join 	arcos_config.terminal t on t.terminal_id_long=djt.terminal_id
	where 	terminal_id_long in (pi_terminal)
	order by 	update_id;
--------------------------------------------------------------------------------	
	/* NOT NEED AT THIS POINT IN TIME
  cursor empty_group
	is 
	select 	group_id 
	from 	arcos_config.terminal_group	
	where 	group_id not in 	(select 	group_id 
				from 	arcos_config.terminal_in_group 
				union
				select 	parent_id group_id 
				from 	arcos_config.terminal_group	)
		and type_id in 	(select 	type_id 
				from 	arcos_config.group_type
				where 	group_type in ('bus','tram')
				)
	order by 	terminal_group_id desc;
  */
--------------------------------------------------------------------------------	
--------------------------------------------------------------------------------
begin
	open terminal_list;
	loop
		fetch terminal_list into v_terminal_id;
		exit when terminal_list%notfound or terminal_list%notfound is null;
		begin
			dbms_output.put_line('TerminalId: ' || v_terminal_id || ' ');
			--------------------------------------------------------------------------------
			--Delete FileManager Jobs for Terminal:BEGIN
			--------------------------------------------------------------------------------
			open all_jobs_for_terminal(v_terminal_id );
			loop
				fetch all_jobs_for_terminal into v_update_id;
				exit when all_jobs_for_terminal%notfound or all_jobs_for_terminal%notfound is null;
				begin --delete file manager distribution jobs against the terminal
					dbms_output.put_line('Deleting update_id: ' || v_update_id || ' from arcos_file_manager.converted_file table');
					delete from arcos_file_manager.converted_file where update_id =  v_update_id;
					dbms_output.put_line('Deleting update_id: ' || v_update_id || ' from arcos_file_manager.distribution_job_terminal table');
					delete from arcos_file_manager.distribution_job_terminal where update_id = v_update_id;
					dbms_output.put_line('Deleting update_id: ' || v_update_id || ' from arcos_file_manager.distribution_job_package table');
					delete from arcos_file_manager.distribution_job_package where update_id =  v_update_id;
					dbms_output.put_line('Deleting update_id: ' || v_update_id || ' from arcos_file_manager.distribution_job table');
					delete from arcos_file_manager.distribution_job where update_id = v_update_id;
					commit;
					exception when others then null;
				end;
			end loop;
			close all_jobs_for_terminal;
			--------------------------------------------------------------------------------
			--Delete FileManager Jobs for Terminal:END
			--------------------------------------------------------------------------------
			
			
			dbms_output.put_line('deleteing from alrmviewr table for terminal '|| v_terminal_id);				

			delete from arcos_base.alarm_alarm where terminal_id in 
				(select terminal_id from arcos_config.terminal where terminal_id_long = v_terminal_id);
        
			delete from ARCOS_BASE.ALARM_TERMINAL_MUTEX where terminal_id in 
				(select terminal_id from arcos_config.terminal where terminal_id_long = v_terminal_id);
        
			
			dbms_output.put_line('deleteing arcos_report for terminal '|| v_terminal_id);				
			delete from arcos_config.ALV_MONEY_MONITOR where terminal_id = v_terminal_id;			
			delete from arcos_config.alv_paper_monitor where terminal_id = v_terminal_id;			
			delete from arcos_config.ALV_POLLING_MONITOr where terminal_id = v_terminal_id;			
			delete from arcos_config.alv_selling_monitor where terminal_id = v_terminal_id;			
			delete from arcos_config.ALV_TECHNICAL_MONITOR where terminal_id = v_terminal_id;			
			
			dbms_output.put_line('deleteing arcos_report for terminal '|| v_terminal_id);				
			delete from arcos_report.activated_status where terminal_id = v_terminal_id;			
			
			
			dbms_output.put_line('deleteing service_terminal for terminal '|| v_terminal_id);
			delete from arcos_config.service_terminal where terminal_id = v_terminal_id;
			
			dbms_output.put_line('deleteing networkConfig for terminal '|| v_terminal_id);
			delete from Arcos_Config.Network_Configuration where Network_Configuration_Id in 
				(select network_configurations from arcos_config.terminal where terminal_id_long = v_terminal_id);
			
			dbms_output.put_line('deleteing gprsconfig for terminal '|| v_terminal_id);
			delete from arcos_config.gprs_configuration where gprs_configuration_id in 
				(select gprs_configuration_id from arcos_config.terminal where terminal_id_long = v_terminal_id);

			dbms_output.put_line('deleteing wlan for terminal '|| v_terminal_id);				
			delete from arcos_config.wlan_configuration where wlan_configuration_id in 
				(select wlan_configuration_id from arcos_config.terminal where terminal_id_long = v_terminal_id);

			dbms_output.put_line('deleteing terminal_in_group for terminal '|| v_terminal_id);				
			delete from arcos_config.terminal_in_group where terminal_id = v_terminal_id;			
			
			dbms_output.put_line('deleteing terminal_add_info for terminal '|| v_terminal_id);				
			delete from arcos_config.terminal_add_info where terminal_id = v_terminal_id;			


			dbms_output.put_line('deleteing terminal for terminal '|| v_terminal_id);				
			delete from arcos_config.terminal where terminal_id_long = v_terminal_id;
				
			commit;
			exception when others then null;
		end;
	end loop;
	close terminal_list;
--rollback;
end;
