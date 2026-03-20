## ggplot2

-   R's main plotting package

data = dataset

aes() = set variables to x, y; color, fill

geom() = what kind of chart to draw

labs() = labels, title, axes

theme() = appearance

## Core Pattern for ggplot2

ggplot(data = my_data, aes(x = variable1, y = variable2)) + geom_col()

another way to write it:

some_data %\>% ggplot(aes(x = variable1, y = variable2)) + geom_col()

## Before we plot:

clean data

group and summarize

plot summary

interpret results

\^\^ workflow

## day_04_ggplot_basics

## Plot 1

Manufacturers are not represented equally in the dataset. Some appear much more often than others, which matters because larger groups can dominate summaries. For my analysis this means that I have to be careful when I make conclusions and statements that compare manufacturers. Also any machine learning models will have biased results if imbalanced data is used.

## Plot 2

Smaller vehicle classes tend to have higher average highway mileage, while larger classes tend to have lower efficiency.

## Plot 3

There appears to be a negative relationship between engine displacement and highway mileage. Larger engines generally correspond to lower fuel efficiency.

## Plot 4

Drive type may help explain some of the variation in mileage. This shows how adding a grouping variable can improve interpretation. Using color to group instead of groupby()

## Plot 5

The boxplot shows both central tendency and spread. This is useful because averages alone can hide variation inside groups. For example, 2seater and midsize have low variation while subcompact has high variation. And the averages of these groups are similar. Dispersion vs. averages

## day_04_reporting_exercise notes

01 Manufacturer Comparison

Some manufacturers show higher average highway mileage than others, which suggests differences in vehicle mix, class composition, or engine characteristics. Have to use group_by to remove the aggregations and see differences

2.  City vs highway relationship

Manufacturers with stronger city mileage also tend to perform better on highway mileage, showing a positive relationship between the two efficiency measures.

2.  City vs highway relationship

Manufacturers with stronger city mileage also tend to perform better on highway mileage, showing a positive relationship between the two efficiency measures.

3.  Year comparison

If one year appears to have higher average mileage, that may reflect either technological changes or differences in the sample composition of vehicles included in the dataset. Once again, have to group by to removew aggregations and see what's causing the difference

4.  Why this matters analytically

This kind of grouped summary plus charting is exactly the workflow used in reporting: calculate segment-level metrics, visualize them, and explain what decision-makers should notice.



## Extra Review

# notes_day4

## Main topic
Basics of ggplot2 and how analyst-style reporting works in R

## Key concepts
- ggplot2 uses a grammar of data, aesthetics, and geoms.
- In analyst work, summaries usually come before plots.
- Bar charts are useful for comparing categories.
- Scatterplots are useful for relationships between numeric variables.
- Boxplots are useful for distributions and spread.

## What is important
The most important shift today was understanding that plotting is not just about visualization. It is part of a reporting workflow: clean data, summarize it, plot it, and explain the result.

## What I practiced
- grouped summaries with dplyr
- plotting grouped summaries
- interpreting charts in words
- comparing categories and relationships visually

## What I want to remember
Good analysis is not just making a chart. It is choosing the right chart for the business question and explaining what it means clearly.