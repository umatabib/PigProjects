-- Load users.csv file into relation 'users'
users = load 'lumoid1/users.csv' using PigStorage(',') as (user_id:int, gender:chararray, log_in_count:int, fraud:int, source:chararray, state:chararray); 

-- Filter 'users' data based on given source and state.
source_state_filter = filter users by (source=='$CHANNEL_IN') AND (state=='$STATE_IN');

users_group = group source_state_filter all;

-- calculate count of number of users acquired through given source.
users_count = foreach users_group generate COUNT(source_state_filter) as u_count; 

STORE users_count  INTO 'lumoid1/output2a' USING PigStorage('\t');
