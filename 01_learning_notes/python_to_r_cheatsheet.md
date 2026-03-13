# Python to R Cheat Sheet

## Data frame

Python pandas DataFrame -\> R tibble / data.frame

## Select columns

Python: df[["col"]] R: df %\>% select(col)

## Filter rows

Python: df[df["x"] \> 5] R: df %\>% filter(x \> 5)

## Create/modify column

Python: df["y"] = df["x"] \* 2 R: df %\>% mutate(y = x \* 2)

## Group and aggregate

Python: df.groupby("segment")["claim"].mean() R: df %\>% group_by(segment) %\>% summarise(avg_claim = mean(claim))

## Sort

Python: df.sort_values("x", ascending=False) R: df %\>% arrange(desc(x))

## Missing values

Python: df["x"].fillna(0) R: mutate(x = replace_na(x, 0))

## Plotting

Python: matplotlib / seaborn R: ggplot2
