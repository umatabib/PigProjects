-- Load orders.csv file into relation 'orders'
orders = load 'lumoid1/orders.csv' using PigStorage(',') as (user_id:int, order_id:int, order_value:int, product_id:int); 

-- Load users.csv file into relation 'users'
users = load 'lumoid1/users.csv' using PigStorage(',') as (user_id:int, gender:chararray, log_in_count:int, fraud:int, source:chararray, state:chararray);

-- Filter 'users' data based on given state.
user_state_filter = filter users by state=='$STATE_IN';

-- Join 'orders'and 'user_state_filter' data.
user_order_join = join orders by user_id, user_state_filter by user_id;

-- group user orders by source
channel_group = group user_order_join by source;

-- calculate revenue for each channel in given state.
channel_state_revenue = foreach channel_group generate group as channel, SUM(user_order_join.order_value) as revenue;

sort_by_revenue = order channel_state_revenue by revenue desc;

-- rank the channels for the given state based on sorted revenue
rank_by_revenue = rank sort_by_revenue;

-- identify rank for given channel for given state.
rank_by_revenue_filter = filter rank_by_revenue by channel=='$CHANNEL_IN';

STORE rank_by_revenue_filter  INTO 'lumoid1/output2b' USING PigStorage('\t');
