orders = load 'orders.csv' using PigStorage(',') as (user_id:int, order_id:int, order_value:int, product_id:int); 

users = load 'users.csv' using PigStorage(',') as (user_id:int, gender:chararray, log_in_count:int, fraud:int, source:chararray, state:chararray); 

user_order_join = join orders by user_id, users by user_id;

state_filter = filter user_order_join by (state=='$STATE_IN_1') OR (state=='$STATE_IN_2') OR (state=='$STATE_IN_3');

product_group = group state_filter by product_id;

product_revenue = foreach product_group generate group as product, SUM(state_filter.order_value) as order_value_sum; 

sort_by_product_revenue = order product_revenue by order_value_sum desc;

top_product_by_revenue = limit sort_by_product_revenue 1;
dump top_product_by_revenue;


