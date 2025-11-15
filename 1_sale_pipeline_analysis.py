#################################
#         Objective 1           #
#################################
import pandas as pd # noqa: PyUnresolvedReferences

df = pd.read_csv("Dataset/sales_pipeline.csv")

# 1 Check Maximum Text Length for each field for create table script
max_len = (
    df.astype(str)
    .apply(lambda col: col.str.len().max())
)
print(max_len)
print()

# 2 Calculate the number of sales opportunities created each month using "engage_date",
# and identify the month with the most opportunities
df["engage_date"] = pd.to_datetime(df["engage_date"], errors="coerce")
cleaned_df = df.dropna(subset=["engage_date"]).copy()
monthly_counts = (
    cleaned_df.groupby(cleaned_df["engage_date"].dt.to_period("M"))
    .size()
    .reset_index(name="opportunity_count")
    .sort_values("engage_date", ascending=False)
)
print("#2 Calculate the number of sales opportunities created each month using 'engage_date'")
print(monthly_counts)
print()

# 3 Find the average time deals stayed open (from "engage_date" to "close_date"),
# and compare closed deals versus won deals.
df["close_date"] = pd.to_datetime(df["close_date"], errors="coerce")
cleaned_df = df.dropna(subset=["engage_date", "close_date"]).copy()
cleaned_df["average_time_deals_stayed_open"] = (cleaned_df["close_date"] - cleaned_df["engage_date"]).dt.days
average_time_deals_stayed_open = (
    cleaned_df.groupby("deal_stage")
    .agg(average_time_deals_stayed_open=("average_time_deals_stayed_open", "mean"),
         deal_count=("deal_stage", "count"))
    .round({"average_time_deals_stayed_open": 0})
    .reset_index()
)
print("#3 Find the average time deals stayed open (from 'engage_date' to 'close_date')")
print(average_time_deals_stayed_open)
print()

# 4 Calculate the percentage of deals in each stage, and determine what share were lost
stage_counts = cleaned_df.groupby("deal_stage").size().reset_index(name="group_count")
total = stage_counts["group_count"].sum()
stage_counts["total"] = total
stage_counts["percentage"] = (stage_counts["group_count"] / total).round(4)
print("#4 Calculate the percentage of deals in each stage, and determine what share were lost")
print(stage_counts)
print()

# 5 Compute the win rate for each product, and identify which one had the highest win rate
win_rate = (
    df.groupby("product")["deal_stage"]
    .apply(lambda x: (x.str.lower() == "won").mean())  # noqa:
    .round(4)
    .reset_index(name="win_rate")
    .sort_values("win_rate", ascending=False)
)
print("#5 Calculate the percentage of deals in each product, and determine what share were lost")
print(win_rate)
print()