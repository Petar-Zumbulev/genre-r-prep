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








