users = load 'users.csv' using PigStorage(',') as (user_id:int, gender:chararray, log_in_count:int, fraud:int, source:chararray, state:chararray); 

source_state_filter = filter users by (source=='$CHANNEL_IN') AND (state=='$STATE_IN');

users_group = group source_state_filter all;

users_count = foreach users_group generate COUNT(source_state_filter) as u_count; 
dump users_count;
