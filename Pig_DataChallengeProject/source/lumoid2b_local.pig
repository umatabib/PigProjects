orders = load 'orders.csv' using PigStorage(',') as (user_id:int, order_id:int, order_value:int, product_id:int); 

users = load 'users.csv' using PigStorage(',') as (user_id:int, gender:chararray, log_in_count:int, fraud:int, source:chararray, state:chararray);

user_state_filter = filter users by state=='$STATE_IN';

user_order_join = join orders by user_id, user_state_filter by user_id;

channel_group = group user_order_join by source;

channel_state_revenue = foreach channel_group generate group as channel, SUM(user_order_join.order_value) as revenue;

sort_by_revenue = order channel_state_revenue by revenue desc;

rank_by_revenue = rank sort_by_revenue;

rank_by_revenue_filter = filter rank_by_revenue by channel=='$CHANNEL_IN';

dump rank_by_revenue_filter;
