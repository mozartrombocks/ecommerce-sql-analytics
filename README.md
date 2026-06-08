# E-Commerce Analytics Platform

### PostgreSQL • SQL • Python • Power BI

---

## Overview

This project is an end-to-end business intelligence and analytics platform built using PostgreSQL, SQL, Python, and Power BI.

The objective of this project was to transform raw e-commerce marketplace data into actionable business insights through relational database design, analytical SQL, and interactive dashboard development.

The project analyzes more than 100,000 marketplace transactions and covers multiple business domains including:

* Revenue Performance
* Product Analytics
* Customer Retention
* Delivery Operations
* Seller Performance
* Customer Satisfaction

This repository demonstrates the complete analytics workflow from raw data ingestion to executive-level reporting.

---

## Full Technical Report

A complete technical report documenting the project methodology, database design, analytical framework, dashboard development process, and business findings is available in:

```text
report/ecommerce_analytics_report.pdf
```

The report includes:

* Relational database design
* Data quality validation
* SQL analytics pipeline
* Customer retention analysis
* Product performance analysis
* Delivery and review analytics
* Seller performance analysis
* Power BI dashboard development
* Business recommendations

---

## Project Architecture

```text
Raw CSV Files
        |
        v
PostgreSQL Database
        |
        v
Data Quality Validation
        |
        v
Analytical SQL Views
        |
        v
Dashboard Views
        |
        v
Power BI Dashboard
        |
        v
Business Insights & Reporting
```

---

## Dataset

This project uses the Brazilian Olist E-Commerce Dataset.

The dataset contains information regarding:

* Customers
* Orders
* Products
* Sellers
* Payments
* Reviews
* Product Categories

### Dataset Scale

| Metric      |   Count |
| ----------- | ------: |
| Customers   |  99,441 |
| Orders      |  99,441 |
| Order Items | 112,650 |
| Payments    | 103,886 |
| Reviews     |  99,224 |
| Sellers     |   3,095 |

---

## Technologies Used

### Database & Analytics

* PostgreSQL
* SQL
* Common Table Expressions (CTEs)
* Window Functions
* Aggregate Analysis
* Cohort Analysis

### Data Processing

* Python
* Pandas
* SQLAlchemy

### Business Intelligence

* Power BI

### Development Tools

* Git
* GitHub

---

## Database Design

The PostgreSQL database was designed using a relational schema consisting of:

* customers
* orders
* order_items
* order_payments
* order_reviews
* products
* sellers
* product_category_translation

Primary and foreign key relationships were implemented to ensure referential integrity and support analytical workloads.

---

## SQL Analytics Pipeline

The project was developed through a sequence of analytical SQL modules.

### 1. Database Construction

* Table creation
* Primary keys
* Foreign keys
* Schema validation

### 2. Data Quality Validation

* Missing value analysis
* Referential integrity checks
* Duplicate detection
* Record count validation

### 3. Analytical Views

Reusable SQL views were constructed to support downstream reporting.

Examples include:

* Revenue metrics
* Product category performance
* Customer retention metrics
* Delivery performance metrics
* Seller performance metrics

### 4. Dashboard Views

Specialized dashboard views were created to serve as the semantic layer between PostgreSQL and Power BI.

---

## Power BI Dashboard

The dashboard consists of five analytical sections.

### Executive Overview

Provides a high-level summary of:

* Total Revenue
* Delivered Orders
* Average Order Value
* Average Review Score
* Late Delivery Rate
* Repeat Customer Rate

### Product Analysis

Analyzes:

* Revenue by Category
* Units Sold by Category
* Revenue Concentration
* Freight Cost Burden

### Customer Retention

Analyzes:

* One-Time vs Repeat Customers
* Orders per Customer
* New Customer Growth
* Cohort Retention

### Delivery & Reviews

Analyzes:

* Review Score Distribution
* Delivery Speed Performance
* Delivery Delays
* Customer Satisfaction

### Seller Analysis

Analyzes:

* Top Sellers by Revenue
* Revenue Concentration
* Seller Satisfaction Metrics
* Operational Performance

---

## Dashboard Screenshots

### Executive Overview

![Executive Overview](https://chatgpt.com/c/screenshots/powerbi_results/executive_overview.png)

### Product Analysis

![Product Analysis](https://chatgpt.com/c/screenshots/powerbi_results/product_analysis.png)

### Customer Retention

![Customer Retention](https://chatgpt.com/c/screenshots/powerbi_results/customer_retention.png)

### Delivery & Reviews

![Delivery & Reviews](https://chatgpt.com/c/screenshots/powerbi_results/delivery_and_reviews.png)

### Seller Analysis

![Seller Analysis](https://chatgpt.com/c/screenshots/powerbi_results/seller_analysis.png)

---

## Key Findings

### Customer Retention

Only approximately 3% of customers placed multiple orders.

This suggests that customer acquisition is strong while customer retention remains a significant opportunity for improvement.

### Delivery Performance

Approximately 8% of orders were delivered late.

Delivery delays were strongly associated with lower customer satisfaction scores.

### Customer Satisfaction

Orders delivered on time received substantially higher review scores than delayed orders.

This demonstrates the importance of logistics performance in shaping customer experience.

### Product Performance

Product categories exhibited significant variation in freight-to-revenue ratios.

Certain categories generated strong revenue while also carrying disproportionately high shipping costs, suggesting opportunities for logistics optimization and pricing strategy improvements.

### Seller Performance

Marketplace revenue was distributed across more than 3,000 sellers, reducing concentration risk while highlighting a small group of high-performing sellers responsible for a disproportionate share of total revenue.

---

## Skills Demonstrated

### SQL

* Complex JOIN Operations
* Window Functions
* Common Table Expressions (CTEs)
* Aggregations
* Analytical Queries
* View Construction

### Data Engineering

* Relational Database Design
* Data Quality Validation
* ETL Workflows
* Schema Development

### Business Analytics

* Revenue Analysis
* Customer Retention Analysis
* Cohort Analysis
* Operational Analytics
* Customer Satisfaction Analysis

### Business Intelligence

* KPI Development
* Dashboard Design
* Data Visualization
* Executive Reporting
* Business Storytelling

---

## Repository Structure

```text
ecommerce-sql-analytics/

├── report/
│   ├── ecommerce_analytics_report.pdf
│   └── ecommerce_analytics_report.tex
│
├── sql/
│   ├── 01_create_tables.sql
│   ├── 02_data_quality_checks.sql
│   ├── 03_analytics_views.sql
│   ├── 04_revenue_analysis.sql
│   ├── 05_product_analysis.sql
│   ├── 06_customer_retention_analysis.sql
│   ├── 07_delivery_review_analysis.sql
│   ├── 08_seller_analysis.sql
│   └── 09_dashboard_views.sql
│
├── python/
│   └── load_reviews.py
│
├── powerbi/
│   └── ecommerce_analytics_dashboard.pbix
│
├── screenshots/
│   └── powerbi_results/
│       ├── executive_overview.png
│       ├── product_analysis.png
│       ├── customer_retention.png
│       ├── delivery_and_reviews.png
│       └── seller_analysis.png
│
└── README.md
```

---

## Future Enhancements

Potential future extensions include:

* Customer Lifetime Value (CLV) Modeling
* Churn Prediction
* Product Recommendation Systems
* Revenue Forecasting
* Automated ETL Pipelines
* Cloud Deployment
* Real-Time Analytics

---

## Author

**Mohammed Rahman**

Mathematics Student | Data Analytics | Data Science | Business Intelligence

Passionate about applying mathematics, statistics, and data-driven decision-making to solve real-world business problems.
