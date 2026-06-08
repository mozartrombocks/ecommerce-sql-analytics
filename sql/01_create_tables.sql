DROP TABLE IF EXISTS order_reviews; 
DROP TABLE IF EXISTS order_payments; 
DROP TABLE IF EXISTS order_items; 
DROP TABLE IF EXISTS orders; 
DROP TABLE IF EXISTS products; 
DROP TABLE IF EXISTS sellers; 
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS product_category_translation; 

CREATE TABLE customers (
	customer_id TEXT PRIMARY KEY, 
	customer_unique_id TEXT,
	customer_zip_code_prefix INTEGER,
	customer_city TEXT,
	customer_state TEXT
); 

CREATE TABLE sellers (
	seller_id TEXT PRIMARY KEY, 
	seller_zip_code_prefix INTEGER,
	seller_city TEXT,
	seller_state TEXT
); 

CREATE TABLE products (
	product_id TEXT PRIMARY KEY, 
	product_category_name TEXT,
	product_name_lenght FLOAT,
	product_description_lenght FLOAT,
	product_photos_qty FLOAT,
	product_weight_g FLOAT,
	product_length_cm FLOAT,
	product_height_cm FLOAT,
	product_width_cm FLOAT
); 

CREATE TABLE orders (
	order_id TEXT PRIMARY KEY, 
	customer_id TEXT,
	order_status TEXT,
	order_purchase_timestamp TIMESTAMP,
	order_approved_at TIMESTAMP,
	order_delivered_carrier_date TIMESTAMP,
	order_delivered_customer_date TIMESTAMP,
	order_estimated_delivery_date TIMESTAMP,
	FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
	order_id TEXT, 
	order_item_id INTEGER,
	product_id TEXT,
	seller_id TEXT,
	shipping_limit_date TIMESTAMP,
	price NUMERIC(10, 2),
	freight_value NUMERIC(10,2),
	PRIMARY KEY (order_id, order_item_id),
	FOREIGN KEY (order_id) REFERENCES orders(order_id),
	FOREIGN KEY (product_id) REFERENCES products(product_id),
	FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

CREATE TABLE order_payments (
	order_id TEXT, 
	payment_sequential INTEGER,
	payment_type TEXT,
	payment_installments INTEGER,
	payment_value NUMERIC(10, 2),
	FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE order_reviews (
	review_id TEXT PRIMARY KEY,
	order_id TEXT,
	review_score INTEGER,
	review_comment_title TEXT,
	review_comment_message TEXT,
	review_creation_date TIMESTAMP,
	review_answer_timestamp TIMESTAMP,
	FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE product_category_translation (
	product_category_name TEXT PRIMARY KEY,
	product_category_name_english TEXT
);


