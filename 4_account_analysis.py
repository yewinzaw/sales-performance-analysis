import pandas as pd  # noqa:

pd.set_option("display.width", 1000)
pd.set_option("display.max_columns", None)
pd.set_option("display.max_rows", None)
pd.set_option("display.max_colwidth", None)

account_df = pd.read_csv("Dataset/accounts.csv")
pipeline_df = pd.read_csv("Dataset/sales_pipeline.csv")

office_location_df = (
    account_df.groupby("office_location", as_index=False)
    .agg(total_revenue=("revenue", lambda x: round(x.sum(), 2)))
)

office_location_df["least_revenue_rank"] = office_location_df["total_revenue"].rank(method="dense", ascending=True).astype(int)
office_location_df = office_location_df.sort_values(by="least_revenue_rank", ascending=True)

print("#1 Calculate revenue by office location, and identify the lowest performer")
print(office_location_df)
print()

min_year = account_df["year_established"].min()
max_year = account_df["year_established"].max()

oldest_newest_df = (
    account_df[account_df["year_established"].isin([min_year, max_year])]
    .loc[:, ["account", "year_established"]]
    .sort_values("year_established")
)

print("#2 Find the gap in years between the oldest and newest customer, and name those companies")
print(oldest_newest_df)
print()

merged_df = pipeline_df.merge(account_df, on="account", how="inner")
lost_subsidiaries_df = merged_df[
    (merged_df["deal_stage"].str.lower().str.strip() == "lost")
    & (merged_df["subsidiary_of"].notna())
    ]

lost_subsidiaries_df = (
    lost_subsidiaries_df.groupby("account", as_index=False)
    .agg(lost_deals=("opportunity_id", "count"))
    .sort_values("lost_deals", ascending=False)
)

print("#3 Which accounts that were subsidiaries had the most lost sales opportunities?")
print(lost_subsidiaries_df)
print()

won_df = merged_df[merged_df["deal_stage"].str.lower().str.strip() == "won"].copy()
won_df["company"] = won_df["subsidiary_of"].fillna(won_df["account"])

parent_revenue_df = (
    won_df.groupby("company", as_index=False)
    .agg(total_revenue=("close_value", lambda x: round(x.sum(), 2)))
    .sort_values("total_revenue", ascending=False)
)
print("#4 Join the companies to their subsidiaries. Which one had the highest total revenue?")
print(parent_revenue_df)
