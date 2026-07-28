import pandas as pd

# Load all 5 views
monthly = pd.read_csv("vw_monthlysales.csv", sep=';')
channel = pd.read_csv("vw_channelperformance.csv", sep=';')
customer = pd.read_csv("vw_customersegments.csv", sep=';')
product = pd.read_csv("vw_productperformance.csv", sep=';')
order_health = pd.read_csv("vw_orderhealth.csv", sep=';')

# First look at each one
print("MONTHLY SALES")
print(monthly.head())
print(monthly.shape)

print("\nCHANNEL PERFORMANCE")
print(channel.head())
print(channel.shape)

print("\nCUSTOMER SEGMENTS")
print(customer.head())
print(customer.shape)

print("\nPRODUCT PERFORMANCE")
print(product.head())
print(product.shape)

print("\nORDER HEALTH")
print(order_health.head())
print(order_health.shape)

import matplotlib.pyplot as plt

# Combine year and month into a single readable label
monthly['YearMonth'] = monthly['Yr'].astype(str) + '-' + monthly['Mth'].astype(str).str.zfill(2)

plt.figure(figsize=(14, 6))
plt.plot(monthly['YearMonth'], monthly['Revenue'], label='Revenue', marker='o')
plt.plot(monthly['YearMonth'], monthly['Profit'], label='Profit', marker='o')
plt.xticks(rotation=45)
plt.title('Monthly Revenue vs Profit (2023-2024)')
plt.xlabel('Month')
plt.ylabel('Amount (₹)')
plt.legend()
plt.tight_layout()
plt.savefig('monthly_revenue_profit.png', dpi=300, bbox_inches='tight')
plt.show()

# Calculate profit margin % for each channel
channel['Profit_Margin_Pct'] = (channel['Profit'] / channel['Revenue']) * 100

# Sort by revenue for a cleaner chart
channel_sorted = channel.sort_values('Revenue', ascending=False)

fig, ax1 = plt.subplots(figsize=(12, 6))

# Bar chart for Revenue
ax1.bar(channel_sorted['ChannelName'], channel_sorted['Revenue'], color='steelblue', label='Revenue')
ax1.set_xlabel('Channel')
ax1.set_ylabel('Revenue (₹)', color='steelblue')
ax1.tick_params(axis='x', rotation=45)

# Second y-axis for Profit Margin %
ax2 = ax1.twinx()
ax2.plot(channel_sorted['ChannelName'], channel_sorted['Profit_Margin_Pct'], color='darkorange', marker='o', linewidth=2, label='Profit Margin %')
ax2.set_ylabel('Profit Margin (%)', color='darkorange')

plt.title('Channel Revenue vs Profit Margin %')
fig.tight_layout()
plt.savefig('channel_performance.png', dpi=300, bbox_inches='tight')
plt.show()

# Group by segment (since vw_customersegments has segment+ageband+tier combos, we need to aggregate up to segment level)
segment_revenue = customer.groupby('Segment')['Revenue'].sum().sort_values(ascending=False)

plt.figure(figsize=(10, 6))
plt.bar(segment_revenue.index, segment_revenue.values, color='mediumseagreen')
plt.title('Revenue by Customer Segment')
plt.xlabel('Segment')
plt.ylabel('Revenue (₹)')
plt.xticks(rotation=30)
plt.tight_layout()
plt.savefig('customer_segment_revenue.png', dpi=300, bbox_inches='tight')
plt.show()

top_products = product.groupby('ProductName')['Revenue'].sum().sort_values(ascending=False).head(10)

plt.figure(figsize=(10, 6))
plt.barh(top_products.index, top_products.values, color='coral')
plt.title('Top 10 Products by Revenue')
plt.xlabel('Revenue (₹)')
plt.ylabel('Product')
plt.gca().invert_yaxis()  # highest value at top
plt.tight_layout()
plt.savefig('top_products.png', dpi=300, bbox_inches='tight')
plt.show()

# Load Sales_Data directly for this one, since festival info isn't in our current views
# (we'll reuse the order_health-style approach with a fresh aggregation)

festival_data = {
    'Period': ['Non-Festival', 'Big Festive Sale', 'Summer Sale', 'Monsoon Deals', 'Year End Sale',
               'Holi Sale', 'Raksha Bandhan Sale', 'Republic Day Sale', 'New Year Sale', 'Independence Day Sale'],
    'Profit_Margin_Pct': [22.76, -2.34, -1.99, -2.25, -2.18, -2.16, -2.42, -2.32, -2.14, -2.11]
}

festival_df = pd.DataFrame(festival_data)
festival_df = festival_df.sort_values('Profit_Margin_Pct', ascending=False)

# Color bars: green for positive margin, red for negative
colors = ['seagreen' if x > 0 else 'indianred' for x in festival_df['Profit_Margin_Pct']]

plt.figure(figsize=(11, 6))
plt.barh(festival_df['Period'], festival_df['Profit_Margin_Pct'], color=colors)
plt.axvline(0, color='black', linewidth=0.8)
plt.title('Profit Margin %: Non-Festival vs Every Festival Period')
plt.xlabel('Profit Margin (%)')
plt.tight_layout()
plt.savefig('festival_margin_comparison.png', dpi=300, bbox_inches='tight')
plt.show()