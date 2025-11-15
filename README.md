# Data Analytics Portfolio – Sales Performance Project

> “As software becomes a commodity, so do common practices — but craftsmanship and software quality do not follow.”  
> — Jonathan YE


## 📌 Overview
This project evaluates company sales performance across regions and product lines using **PostgreSQL**, **Pandas**, and **Power BI**.  
Each tool applied independently to reproduce the same analytical objectives.It showcases how consistent business insights can be achieved across different analytical environments using SQL queries, Python logic, and DAX measures.

## ⚙️ Tools & Technologies
- **Python (Pandas, PyCharm)** – Data cleaning, transformation, and exploratory computation
- **PostgreSQL (pgAdmin 4)** – Data storage, joins, and aggregation
- **Power BI Desktop** – Visualization, DAX measures, and KPI reporting
- **GitHub** – Version control and project documentation
- **Anaconda Environment (Sherlock)** — Python 3.11.14 running in a controlled environment
- **DAX Formatter** – https://www.daxformatter.com/ provided by SQLBI

## 🗂️ Data Sources
- `sales_pipeline.csv` – Sales deals and outcomes  
- `sales_team.csv` – Sales agents and reporting managers info
- `product_master.csv` – Product catalog with pricing  
- `account_master.csv` – Company and subsidiary information  

## 📊 Key Insights
- Identified top-performing product series and sales agents  
- Compared regional performance  
- Detect discount patterns   
- Evaluated parent vs subsidiary company revenue contribution  

## 🧠 Learning Objectives
- Implement identical business logic across SQL, Pandas, and DAX
- Compare analytical methodologies between relational, procedural, and visual tools
- Translate SQL queries into equivalent Pandas operations
- Produce portfolio-ready analytical documentation

## ⚠️ Data Notes
The product name **"GTXPro"** in the pipeline table does not match **"GTX Pro"** in the master table due to a missing space. This original mismatch was intentionally left unchanged, and some discrepancies in query results from others are expected as a result.

## 🏁 Untold Stories
- The highest win rate among sales agents does not guarantee the highest revenue.
- High-priced products often require strong negotiation skills to close, yet deliver higher profit margins.
- As a rule of thumb, always check the maximum data length in CSV files with Pandas to ensure enough room for database columns before running the CREATE TABLE script.
- DAX measures should always be cross-checked with SQL queries to confirm accuracy and improve data quality — it is like washing hands: the left hand washes the right, and the right hand washes the left.
- Knowing **where and why** to fix GPT-generated code is a critical skill — understanding the business logic matters more than copying code.  
- **Example:** In Power BI → *Pipeline Matrix Page* → *Win Rate DAX Measure* → Understanding the business rule to include *all deal stages* in the denominator is important whereas GPT failed to address the business logic. 

👤 **Author:** Jonathan YE  
📬 **Contact:** [yewinzaw@gmail.com](mailto:yewinzaw@gmail.com)  
🔗 **Reference**: mavenanalytics.io/guided_projects



