-- Load orders.csv file into relation 'orders'
orders = load 'lumoid1/orders.csv' using PigStorage(',') as (user_id:int, order_id:int, order_value:int, product_id:int); 

---- Load users.csv file into relation 'users'
users = load 'lumoid1/users.csv' using PigStorage(',') as (user_id:int, gender:chararray, log_in_count:int, fraud:int, source:chararray, state:chararray); 

-- Join 'orders'and 'users' data.
user_order_join = join orders by user_id, users by user_id;

-- Filter 'filter user_order_join' data based on given 3 states.
state_filter = filter user_order_join by (state=='$STATE_IN_1') OR (state=='$STATE_IN_2') OR (state=='$STATE_IN_3');

-- group by product.
product_group = group state_filter by product_id;

-- find revenue for each product in all 3 states.
product_revenue = foreach product_group generate group as product, SUM(state_filter.order_value) as order_value_sum; 

sort_by_product_revenue = order product_revenue by order_value_sum desc;

-- find highest revenue making product across all 3 states.
top_product_by_revenue = limit sort_by_product_revenue 1;

STORE top_product_by_revenue INTO 'lumoid1/output3b' USING PigStorage('\t');
