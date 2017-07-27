-- Load orders.csv file into relation 'orders'
orders = load 'lumoid1/orders.csv' using PigStorage(',') as (user_id:int, order_id:int, order_value:int, product_id:int); 

-- Load users.csv file into relation 'users'
users = load 'lumoid1/users.csv' using PigStorage(',') as (user_id:int, gender:chararray, log_in_count:int, fraud:int, source:chararray, state:chararray);

-- Process 'users' data to add two new columns to identify users based on gender.
-- These new columns will be used to calculate gender based count for the given product purchase. 
user_details = foreach users generate user_id, state,(gender=='male'? 1.0:0.0) as male, (gender=='female'? 1.0:0.0) as female; 	

-- Join 'orders'and 'users' data.
user_order_join = join orders by user_id, user_details by user_id;

-- Filter 'user_order_join' data based on given product_id.
product_purchase_filter = filter user_order_join by product_id==$PROD_ID;

-- Group 'product_purchase_filter' data by state.
state_group = group product_purchase_filter by state;

-- calculate total product purchased as well as the gender distribution(in percentage) in each state.
state_purchase_count = foreach state_group generate group as state, COUNT(product_purchase_filter) as product_purchase_count, (SUM(product_purchase_filter.male)/COUNT(product_purchase_filter))*100 as male_count_percent, (SUM(product_purchase_filter.female)/COUNT(product_purchase_filter))*100 as female_count_percent;

-- sort 'state_purchase_count' data by product purchase count in descending order.
sort_by_purchase_count = order state_purchase_count by product_purchase_count desc;

-- find top N states where the given product was most purchased.
top_n = limit sort_by_purchase_count $TOP_N;

STORE top_n INTO 'lumoid1/output' USING PigStorage('\t');
