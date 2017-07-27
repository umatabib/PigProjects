users = load 'users.csv' using PigStorage(',') as (user_id:int, gender:chararray, log_in_count:int, fraud:int, source:chararray, state:chararray); 

gender_state_filter = filter users by (gender=='$GENDER_IN') AND ((state=='$STATE_IN_1') OR (state=='$STATE_IN_2') OR (state=='$STATE_IN_3'));

channel_group = group gender_state_filter by source;

users_per_channel_count = foreach channel_group generate group as channel, COUNT(gender_state_filter) as u_count; 

sort_by_user_count = order users_per_channel_count by u_count desc;

top_channel = limit sort_by_user_count 1;
dump top_channel;
