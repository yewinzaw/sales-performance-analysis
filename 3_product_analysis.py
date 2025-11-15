#################################
#         Objective 3           #
#################################

import pandas as pd  # noqa:

pd.set_option("display.width", 1000)
pd.set_option("display.max_columns", None)
pd.set_option("display.max_colwidth", None)

pipeline_df = pd.read_csv("Dataset/sales_pipeline.csv")
product_df = pd.read_csv("Dataset/products.csv")

# region region#1 march deals
march_deals_df = (
    pipeline_df[
        (pd.to_datetime(pipeline_df["engage_date"]).dt.month == 3) &
        (pipeline_df["deal_stage"].str.lower().str.strip() == "won")
        ]
    .groupby("product", as_index=False)
    .agg(
        total_revenue=("close_value", "sum"),
        total_units_sold=("close_value", "count")
    )
)
march_deals_df["revenue_rank"] = march_deals_df["total_revenue"].rank(method="dense", ascending=False).astype(int)
march_deals_df["units_rank"] = march_deals_df["total_units_sold"].rank(method="dense", ascending=False).astype(int)

# Filter top performers by revenue or units
top_performer_products_df = march_deals_df[
    (march_deals_df["revenue_rank"] == 1) | (march_deals_df["units_rank"] == 1)].copy()

print("#1 For March deals, identify the top product by revenue and compare it to the top by units sold")
print(top_performer_products_df)
print()
# endregion

# region region#2 price stats
merged_df = pipeline_df.merge(product_df, on="product", how="inner")
filtered_df = merged_df[
    (merged_df["deal_stage"].str.lower().str.strip() == "won")
    & (merged_df["close_value"].notna())
    & (merged_df["close_value"] > 0)
    ].copy()

filtered_df["price_category"] = filtered_df.apply(
    lambda x: "Discounted" if x["close_value"] < x["sales_price"] else "Normal", axis=1)

price_stats_df = (
    filtered_df.groupby("product", as_index=False)
    .agg(
        avg_discounted_price_diff=(
            "close_value",
            lambda x: round(
                (x[filtered_df.loc[x.index, "price_category"] == "Discounted"]
                 - filtered_df.loc[x.index, "sales_price"]).mean(), 2)
        ),
        avg_discounted_diff_percent=(
            "close_value",
            lambda x: round(
                ((x[filtered_df.loc[x.index, "price_category"] == "Discounted"]
                  - filtered_df.loc[x.index, "sales_price"])
                 / filtered_df.loc[x.index, "sales_price"] * 100).mean(), 2)
        ),
        avg_normal_price_diff=(
            "close_value",
            lambda x: round(
                (x[filtered_df.loc[x.index, "price_category"] == "Normal"]
                 - filtered_df.loc[x.index, "sales_price"]).mean(), 2)
        ),
        avg_normal_diff_percent=(
            "close_value",
            lambda x: round(
                ((x[filtered_df.loc[x.index, "price_category"] == "Normal"]
                  - filtered_df.loc[x.index, "sales_price"])
                 / filtered_df.loc[x.index, "sales_price"] * 100).mean(), 2)
        ),
        discounted_deals=("price_category", lambda x: (x == "Discounted").sum()),
        normal_deals=("price_category", lambda x: (x == "Normal").sum()),
        total_deals=("price_category", "count")
    )
    .sort_values("product")
)
print("#2 Calculate the average difference between 'sales_price' and 'close_value' for each product.")
print(price_stats_df.drop(columns=["total_deals"]))
print()
# endregion

#region region#3 series stats
series_stats_df  = (
    filtered_df.groupby("series", as_index=False)
    .agg(
        total_revenue=("close_value", lambda x: round(x.sum(), 2)),
        total_deals=("close_value", "count"),
        avg_deal_value=("close_value", lambda x: round(x.mean(), 2))
    )
    .sort_values("total_revenue", ascending=False)
)

print("#3 Calculate total revenue by product series and compare their performance")
print(series_stats_df)
#endregion

