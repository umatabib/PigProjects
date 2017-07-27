orders = load 'orders.csv' using PigStorage(',') as (user_id:int, order_id:int, order_value:int, product_id:int); 

users = load 'users.csv' using PigStorage(',') as (user_id:int, gender:chararray, log_in_count:int, fraud:int, source:chararray, state:chararray); 

user_details = foreach users generate user_id, state,(gender=='male'? 1.0:0.0) as male, (gender=='female'? 1.0:0.0) as female; 				

user_order_join = join orders by user_id, user_details by user_id;

product_purchase_filter = filter user_order_join by product_id==$PROD_ID;

state_group = group product_purchase_filter by state;

state_purchase_count = foreach state_group generate group, COUNT(product_purchase_filter) as purchase_count, (SUM(product_purchase_filter.male)/COUNT(product_purchase_filter))*100 as male_count_percent, (SUM(product_purchase_filter.female)/COUNT(product_purchase_filter))*100 as female_count_percent;

sort_by_purchase_count = order state_purchase_count by purchase_count desc;

top_n = limit sort_by_purchase_count $TOP_N;
dump top_n;

