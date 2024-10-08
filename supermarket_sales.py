# -*- coding: utf-8 -*-
"""supermarket_sales.ipynb

Automatically generated by Colab.

Original file is located at
    https://colab.research.google.com/drive/1vcGMvPI04ijxE0PuN0uGBBSL8MBgVfYr
"""

import pandas as pd

# Load the CSV file
file_path = '/content/supermarket_sales.csv'
data = pd.read_csv(file_path)

# Display the first few rows and the column names to understand the structure
data.head(), data.columns.tolist()

# Extract unique customer data
customers_df = data[['Invoice ID', 'Customer type', 'Gender']].drop_duplicates()
customers_df['Customer ID'] = customers_df['Invoice ID']
customers_df = customers_df[['Customer ID', 'Customer type', 'Gender']]

# Extract unique product data
products_df = data[['Product line', 'Unit price']].drop_duplicates()
products_df['Product ID'] = products_df['Product line']
products_df = products_df[['Product ID', 'Product line', 'Unit price']]

# Extract unique branch data
branches_df = data[['Branch', 'City']].drop_duplicates()
branches_df['Branch ID'] = branches_df['Branch']
branches_df = branches_df[['Branch ID', 'Branch', 'City']]

# Extract unique date data and derive additional columns
date_df = pd.to_datetime(data['Date'])
dates_df = pd.DataFrame({
    'Date': date_df,
    'Day': date_df.dt.day,
    'Month': date_df.dt.month,
    'Year': date_df.dt.year,
    'Weekday': date_df.dt.weekday
}).drop_duplicates()

# Extract unique time data and derive additional columns
time_df = pd.to_datetime(data['Time'], format='%H:%M')
times_df = pd.DataFrame({
    'Time': time_df.dt.time,
    'Hour': time_df.dt.hour,
    'Minute': time_df.dt.minute
}).drop_duplicates()

# Display the first few rows of each dimension table
customers_df.head(), products_df.head(), branches_df.head(), dates_df.head(), times_df.head()

# Create the Sales Transactions Fact Table
fact_sales_df = data[[
    'Invoice ID', 'Branch', 'City', 'Customer type', 'Gender', 'Product line', 'Unit price',
    'Quantity', 'Tax 5%', 'Total', 'Date', 'Time', 'Payment', 'cogs',
    'gross margin percentage', 'gross income', 'Rating'
]]

# Merge with Customers Dimension
fact_sales_df = fact_sales_df.merge(customers_df, left_on=['Invoice ID'], right_on=['Customer ID'], how='left')
# Merge with Products Dimension
fact_sales_df = fact_sales_df.merge(products_df, left_on=['Product line', 'Unit price'], right_on=['Product line', 'Unit price'], how='left')
# Merge with Branches Dimension
fact_sales_df = fact_sales_df.merge(branches_df, left_on=['Branch', 'City'], right_on=['Branch', 'City'], how='left')

# Drop the original non-ID columns now that we have IDs
fact_sales_df = fact_sales_df.drop(columns=['Customer type_x', 'Gender_x', 'Product line', 'Branch', 'City'])
fact_sales_df = fact_sales_df.rename(columns={
    'Customer type_y': 'Customer type',
    'Gender_y': 'Gender'
})

# Display the first few rows of the fact table
fact_sales_df.head()

customers_df.to_csv('customers.csv', index=False)
products_df.to_csv('products.csv', index=False)
branches_df.to_csv('branches.csv', index=False)
dates_df.to_csv('dates.csv', index=False)
times_df.to_csv('times.csv', index=False)
fact_sales_df.to_csv('fact_sales.csv', index=False)