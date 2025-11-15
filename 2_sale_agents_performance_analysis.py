#################################
#         Objective 2           #
#################################
import pandas as pd  # noqa: PyUnresolvedReferences

pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', None)
pd.set_option('display.width', 1000)

pipeline_df = pd.read_csv("Dataset/sales_pipeline.csv")
team_df = pd.read_csv("Dataset/sales_teams.csv")

pipeline_df["deal_stage"] = pipeline_df["deal_stage"].str.lower().str.strip()

agent_stats = (
    pipeline_df.groupby("sales_agent", as_index=False)
    .agg(
        win_count=("deal_stage", lambda x: (x == 'won').sum()),
        total_count=("deal_stage", "count"),
        total_revenue=("close_value", "sum")
    )
)
agent_stats['win_rate'] = (agent_stats['win_count'] * 100 / agent_stats['total_count']).round(2)
agent_stats = agent_stats.sort_values('win_rate', ascending=False)

print("#1 Calculate the win rate for each sales agent, and find the top performer")
print(agent_stats.head(5))
print()

df_won_deals = pipeline_df[pipeline_df["deal_stage"] == 'won']
df_won_deals = (
    df_won_deals.groupby("sales_agent")["close_value"]
    .sum()
    .reset_index(name="total_revenue")
    .sort_values('total_revenue', ascending=False)
)
print("#2 Calculate the total revenue by agent, and see who generated the most")
print(df_won_deals.head(5))
print()

# Inner join with sales_team on sales_agent
merged_df = pd.merge(agent_stats, team_df, on="sales_agent", how="inner")

manager_stats = (
    merged_df.groupby("manager", as_index=False)
    .agg(
        member_count=("sales_agent", "nunique"),
        total_wins=("win_count", "sum"),
        total_deals=("total_count", "sum"),
        total_revenue=("total_revenue", "sum"),
    )
)

manager_stats['win_rate'] = (manager_stats['total_wins'] * 100 / manager_stats['total_deals']).round(2)
manager_stats['total_revenue'] = manager_stats['total_revenue'].round(2)
manager_stats = manager_stats.sort_values('win_rate', ascending=False)

print("#3 Calculate win rates by manager to determine which manager’s team performed best")
print(manager_stats)
print()

gtx_product_won_deal_df = pipeline_df[
    (pipeline_df["product"].str.lower().str.strip() == "gtx plus pro") &
    (pipeline_df["deal_stage"].str.lower().str.strip() == "won")].copy()

reginal_product_stats = (
    pd.merge(gtx_product_won_deal_df, team_df, on="sales_agent", how="inner")
    .groupby("regional_office", as_index=False)
    .agg(
        total_units_sold=("sales_agent","count"),
        total_sold_value=("close_value", "sum")
    )
    .sort_values("total_units_sold", ascending=False)
)

print("#4 For the product GTX Plus Pro, find which regional office sold the most units")
print(reginal_product_stats)
print()