-- Author:             Maris Elsins (elmaris@gmail.com), 2016
-- Copyright:          (c) Maris Elsins - https://me-dba.com - All rights reserved.
-- Usage:              @rt_wait_perf "waitevent", after which you just keep hitting "/" to re-run the last query
-- Note:               The script can be used to observe the wait event perfomrance online for the current database instance
-- Example:
--   SQL> @rt_wait_perf "log file sync"
--   
--   TSTAMP                      INTERVAL_SECS EVENT                                    TOTAL_WAITS     TIME_WAITED_MIC          D_WTS          D_TWM    D_AVG_MS_WT
--   -------------------------- -------------- ---------------------------------------- --------------- --------------- -------------- -------------- --------------
--   14.04.2016 18:07:25.055984                log file sync                            137478504       1096070215896        137478504  1096070215896          7.973
--   SQL> /
--   
--   TSTAMP                      INTERVAL_SECS EVENT                                    TOTAL_WAITS     TIME_WAITED_MIC          D_WTS          D_TWM    D_AVG_MS_WT
--   -------------------------- -------------- ---------------------------------------- --------------- --------------- -------------- -------------- --------------
--   14.04.2016 18:07:45.189085         20.133 log file sync                            137478672       1096070457766              168         241870          1.440

set lines 300 ver off feed off
def v_tst=""
def v_wts="0"
def v_twm="0"
def v_event="&1"
col TIME_WAITED_MICRO for a15 new_value v_twm
col TOTAL_WAITS for a15 new_value v_wts
col TSTAMP for a26 new_value v_tst
col D_WTS for 9999999999999 
col D_TWM for 9999999999999 
col D_AVG_MS_WT for 999999999.999 
col INTERVAL_SECS for 999999999.999
col EVENT for a40
select to_char(systimestamp,'DD.MM.YYYY HH24:MI:SSXFF') TSTAMP,
       round(sysdate+(86400*(systimestamp-to_timestamp('&&v_tst','DD.MM.YYYY HH24:MI:SSXFF')))-sysdate,3) interval_secs,
       event, 
       to_char(TOTAL_WAITS) TOTAL_WAITS, 
       to_char(TIME_WAITED_MICRO) TIME_WAITED_MICRO, 
       sum(TOTAL_WAITS)-&&v_wts D_WTS, 
       (TIME_WAITED_MICRO)-&&v_twm D_TWM, 
       round((sum(TIME_WAITED_MICRO)-&&v_twm)/decode(sum(TOTAL_WAITS)-&&v_wts,0,null,sum(TOTAL_WAITS)-&&v_wts)/1000,3) D_AVG_MS_WT 
from v$system_event 
where event='&&v_event';
